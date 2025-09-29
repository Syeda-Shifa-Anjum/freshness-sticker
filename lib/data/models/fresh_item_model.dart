import 'package:hive/hive.dart';
import '../../domain/entities/fresh_item.dart';

part 'fresh_item_model.g.dart';

@HiveType(typeId: 0)
class FreshItemModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final DateTime scanDate;

  @HiveField(3)
  final DateTime? spoilageDate;

  @HiveField(4)
  final int statusIndex; // Store enum as int

  @HiveField(5)
  final String? notes;

  FreshItemModel({
    required this.id,
    required this.name,
    required this.scanDate,
    this.spoilageDate,
    required this.statusIndex,
    this.notes,
  });

  factory FreshItemModel.fromEntity(FreshItem item) {
    return FreshItemModel(
      id: item.id,
      name: item.name,
      scanDate: item.scanDate,
      spoilageDate: item.spoilageDate,
      statusIndex: item.status.index,
      notes: item.notes,
    );
  }

  FreshItem toEntity() {
    return FreshItem(
      id: id,
      name: name,
      scanDate: scanDate,
      spoilageDate: spoilageDate,
      status: FreshnessStatus.values[statusIndex],
      notes: notes,
    );
  }
}
