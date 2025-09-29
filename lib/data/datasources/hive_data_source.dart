import 'package:hive_flutter/hive_flutter.dart';
import '../models/fresh_item_model.dart';
import '../../domain/entities/fresh_item.dart';

class HiveDataSource {
  static const String _boxName = 'fresh_items';
  late Box<FreshItemModel> _box;

  Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters if not already registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(FreshItemModelAdapter());
    }

    _box = await Hive.openBox<FreshItemModel>(_boxName);
  }

  Future<List<FreshItem>> getAllItems() async {
    final items = _box.values.map((model) => model.toEntity()).toList();
    // Sort by scan date, newest first
    items.sort((a, b) => b.scanDate.compareTo(a.scanDate));
    return items;
  }

  Future<FreshItem?> getItemById(String id) async {
    final model = _box.get(id);
    return model?.toEntity();
  }

  Future<void> saveItem(FreshItem item) async {
    final model = FreshItemModel.fromEntity(item);
    await _box.put(item.id, model);
  }

  Future<void> updateItem(FreshItem item) async {
    await saveItem(item); // Same as save for Hive
  }

  Future<void> deleteItem(String id) async {
    await _box.delete(id);
  }

  Future<void> deleteAllItems() async {
    await _box.clear();
  }

  Future<void> close() async {
    await _box.close();
  }
}
