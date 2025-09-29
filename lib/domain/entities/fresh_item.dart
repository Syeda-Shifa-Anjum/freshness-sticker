import 'package:equatable/equatable.dart';

enum FreshnessStatus { fresh, useSoon, spoiled }

class FreshItem extends Equatable {
  final String id;
  final String name;
  final DateTime scanDate;
  final DateTime? spoilageDate;
  final FreshnessStatus status;
  final String? notes;

  const FreshItem({
    required this.id,
    required this.name,
    required this.scanDate,
    this.spoilageDate,
    required this.status,
    this.notes,
  });

  FreshItem copyWith({
    String? id,
    String? name,
    DateTime? scanDate,
    DateTime? spoilageDate,
    FreshnessStatus? status,
    String? notes,
  }) {
    return FreshItem(
      id: id ?? this.id,
      name: name ?? this.name,
      scanDate: scanDate ?? this.scanDate,
      spoilageDate: spoilageDate ?? this.spoilageDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  bool get isExpired {
    if (spoilageDate == null) return false;
    return DateTime.now().isAfter(spoilageDate!);
  }

  bool get isSoonToExpire {
    if (spoilageDate == null) return false;
    final daysDiff = spoilageDate!.difference(DateTime.now()).inDays;
    return daysDiff <= 1 && daysDiff >= 0;
  }

  @override
  List<Object?> get props => [id, name, scanDate, spoilageDate, status, notes];
}