import 'package:equatable/equatable.dart';
import 'fresh_item.dart';

class ColorDetectionResult extends Equatable {
  final FreshnessStatus detectedStatus;
  final String colorName;
  final double confidence;
  final DateTime detectionTime;

  const ColorDetectionResult({
    required this.detectedStatus,
    required this.colorName,
    required this.confidence,
    required this.detectionTime,
  });

  DateTime get estimatedSpoilageDate {
    final now = DateTime.now();
    switch (detectedStatus) {
      case FreshnessStatus.fresh:
        return now.add(const Duration(days: 7)); // Fresh items last ~7 days
      case FreshnessStatus.useSoon:
        return now.add(const Duration(days: 2)); // Use soon items last ~2 days
      case FreshnessStatus.spoiled:
        return now; // Already spoiled
    }
  }

  @override
  List<Object?> get props => [
    detectedStatus,
    colorName,
    confidence,
    detectionTime,
  ];
}
