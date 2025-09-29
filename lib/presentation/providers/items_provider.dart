import 'package:flutter/material.dart';
import '../../domain/entities/fresh_item.dart';
import '../../domain/repositories/fresh_item_repository.dart';
import '../../core/services/notification_service.dart';

class ItemsProvider with ChangeNotifier {
  final FreshItemRepository _repository;

  List<FreshItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  ItemsProvider(this._repository);

  // Getters
  List<FreshItem> get allItems => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<FreshItem> get freshItems =>
      _items.where((item) => item.status == FreshnessStatus.fresh).toList();

  List<FreshItem> get useSoonItems =>
      _items.where((item) => item.status == FreshnessStatus.useSoon).toList();

  List<FreshItem> get spoiledItems =>
      _items.where((item) => item.status == FreshnessStatus.spoiled).toList();

  List<FreshItem> get expiredItems =>
      _items.where((item) => item.isExpired).toList();

  List<FreshItem> get soonToExpireItems =>
      _items.where((item) => item.isSoonToExpire && !item.isExpired).toList();

  Future<void> loadItems() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await _repository.getAllItems();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load items: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addItem(FreshItem item) async {
    try {
      await _repository.saveItem(item);

      // Schedule notification if item will expire
      if (item.spoilageDate != null &&
          item.spoilageDate!.isAfter(DateTime.now())) {
        await NotificationService.scheduleExpirationNotification(item);
      }

      await loadItems(); // Refresh the list
    } catch (e) {
      _errorMessage = 'Failed to add item: $e';
      notifyListeners();
    }
  }

  Future<void> updateItem(FreshItem item) async {
    try {
      await _repository.updateItem(item);

      // Cancel existing notification and reschedule if needed
      await NotificationService.cancelNotification(item.id);
      if (item.spoilageDate != null &&
          item.spoilageDate!.isAfter(DateTime.now())) {
        await NotificationService.scheduleExpirationNotification(item);
      }

      await loadItems(); // Refresh the list
    } catch (e) {
      _errorMessage = 'Failed to update item: $e';
      notifyListeners();
    }
  }

  Future<void> deleteItem(String itemId) async {
    try {
      await _repository.deleteItem(itemId);
      await NotificationService.cancelNotification(itemId);
      await loadItems(); // Refresh the list
    } catch (e) {
      _errorMessage = 'Failed to delete item: $e';
      notifyListeners();
    }
  }

  Future<void> deleteAllItems() async {
    try {
      // Cancel all notifications
      for (final item in _items) {
        await NotificationService.cancelNotification(item.id);
      }

      await _repository.deleteAllItems();
      await loadItems(); // Refresh the list
    } catch (e) {
      _errorMessage = 'Failed to delete all items: $e';
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
