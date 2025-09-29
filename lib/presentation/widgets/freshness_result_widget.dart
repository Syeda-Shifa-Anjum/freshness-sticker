import 'package:flutter/material.dart';
import '../../domain/entities/fresh_item.dart';
import '../../domain/entities/color_detection_result.dart';

class FreshnessResultWidget extends StatelessWidget {
  final ColorDetectionResult result;
  final VoidCallback onSave;
  final VoidCallback onDismiss;

  const FreshnessResultWidget({
    super.key,
    required this.result,
    required this.onSave,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _buildStatusIcon(context),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getStatusTitle(),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(context),
                            ),
                      ),
                      Text(
                        'Color detected: ${result.colorName}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        'Confidence: ${(result.confidence * 100).toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(onPressed: onDismiss, icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDismiss,
                    child: const Text('Scan Again'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: onSave,
                    child: const Text('Save Item'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(BuildContext context) {
    IconData iconData;
    Color iconColor;

    switch (result.detectedStatus) {
      case FreshnessStatus.fresh:
        iconData = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case FreshnessStatus.useSoon:
        iconData = Icons.warning;
        iconColor = Colors.orange;
        break;
      case FreshnessStatus.spoiled:
        iconData = Icons.dangerous;
        iconColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: iconColor, size: 32),
    );
  }

  String _getStatusTitle() {
    switch (result.detectedStatus) {
      case FreshnessStatus.fresh:
        return 'Fresh';
      case FreshnessStatus.useSoon:
        return 'Use Soon';
      case FreshnessStatus.spoiled:
        return 'Spoiled';
    }
  }

  Color _getStatusColor(BuildContext context) {
    switch (result.detectedStatus) {
      case FreshnessStatus.fresh:
        return Colors.green;
      case FreshnessStatus.useSoon:
        return Colors.orange;
      case FreshnessStatus.spoiled:
        return Colors.red;
    }
  }
}
