import '../../domain/entities/fresh_item.dart';
import '../../domain/repositories/fresh_item_repository.dart';
import '../datasources/hive_data_source.dart';

class FreshItemRepositoryImpl implements FreshItemRepository {
  final HiveDataSource _dataSource;

  FreshItemRepositoryImpl(this._dataSource);

  @override
  Future<List<FreshItem>> getAllItems() async {
    return await _dataSource.getAllItems();
  }

  @override
  Future<FreshItem?> getItemById(String id) async {
    return await _dataSource.getItemById(id);
  }

  @override
  Future<void> saveItem(FreshItem item) async {
    await _dataSource.saveItem(item);
  }

  @override
  Future<void> updateItem(FreshItem item) async {
    await _dataSource.updateItem(item);
  }

  @override
  Future<void> deleteItem(String id) async {
    await _dataSource.deleteItem(id);
  }

  @override
  Future<void> deleteAllItems() async {
    await _dataSource.deleteAllItems();
  }
}
