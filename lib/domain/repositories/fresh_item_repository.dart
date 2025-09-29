import '../entities/fresh_item.dart';

abstract class FreshItemRepository {
  Future<List<FreshItem>> getAllItems();
  Future<FreshItem?> getItemById(String id);
  Future<void> saveItem(FreshItem item);
  Future<void> updateItem(FreshItem item);
  Future<void> deleteItem(String id);
  Future<void> deleteAllItems();
}
