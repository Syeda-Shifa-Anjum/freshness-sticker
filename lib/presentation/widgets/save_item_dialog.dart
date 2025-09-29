import 'package:flutter/material.dart';
import '../../domain/entities/color_detection_result.dart';
import '../../domain/entities/fresh_item.dart';

class SaveItemDialog extends StatefulWidget {
  final ColorDetectionResult detectionResult;
  final Function(String name, String? notes) onSave;

  const SaveItemDialog({
    super.key,
    required this.detectionResult,
    required this.onSave,
  });

  @override
  State<SaveItemDialog> createState() => _SaveItemDialogState();
}

class _SaveItemDialogState extends State<SaveItemDialog> {
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Save Food Item'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Detection result summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _getStatusColor().withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(_getStatusIcon(), color: _getStatusColor()),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getStatusText(),
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(),
                              ),
                        ),
                        Text(
                          'Expires: ${_formatDate(widget.detectionResult.estimatedSpoilageDate)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Name field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Item Name *',
                hintText: 'e.g., Milk, Bread, Vegetables',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an item name';
                }
                return null;
              },
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Notes field
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'Additional information...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _saveItem, child: const Text('Save')),
      ],
    );
  }

  void _saveItem() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSave(
        _nameController.text.trim(),
        _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
    }
  }

  Color _getStatusColor() {
    switch (widget.detectionResult.detectedStatus) {
      case FreshnessStatus.fresh:
        return Colors.green;
      case FreshnessStatus.useSoon:
        return Colors.orange;
      case FreshnessStatus.spoiled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.detectionResult.detectedStatus) {
      case FreshnessStatus.fresh:
        return Icons.check_circle_outline;
      case FreshnessStatus.useSoon:
        return Icons.warning_amber_outlined;
      case FreshnessStatus.spoiled:
        return Icons.dangerous_outlined;
    }
  }

  String _getStatusText() {
    switch (widget.detectionResult.detectedStatus) {
      case FreshnessStatus.fresh:
        return 'Fresh';
      case FreshnessStatus.useSoon:
        return 'Use Soon';
      case FreshnessStatus.spoiled:
        return 'Spoiled';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference > 1) {
      return 'In $difference days';
    } else {
      return 'Already expired';
    }
  }
}
