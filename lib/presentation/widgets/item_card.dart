import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/fresh_item.dart';

class ItemCard extends StatelessWidget {
  final FreshItem item;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;

  const ItemCard({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStatusIcon(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Scanned: ${DateFormat('MMM dd, yyyy').format(item.scanDate)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onUpdate();
                        break;
                      case 'delete':
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 20),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Status and expiry info
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getStatusColor().withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    _getStatusText(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getStatusColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (item.spoilageDate != null)
                  Expanded(
                    child: Text(
                      'Expires: ${_formatExpiryDate()}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getExpiryTextColor(context),
                      ),
                    ),
                  ),
              ],
            ),

            // Notes if available
            if (item.notes != null && item.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.notes!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],

            // Warning for expired/soon to expire items
            if (item.isExpired || item.isSoonToExpire) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (item.isExpired ? Colors.red : Colors.orange)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: (item.isExpired ? Colors.red : Colors.orange)
                        .withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      item.isExpired ? Icons.error : Icons.warning,
                      size: 16,
                      color: item.isExpired ? Colors.red : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.isExpired
                            ? 'This item has expired'
                            : 'This item expires soon',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: item.isExpired ? Colors.red : Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    IconData iconData;
    Color iconColor = _getStatusColor();

    switch (item.status) {
      case FreshnessStatus.fresh:
        iconData = Icons.check_circle;
        break;
      case FreshnessStatus.useSoon:
        iconData = Icons.warning;
        break;
      case FreshnessStatus.spoiled:
        iconData = Icons.dangerous;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: iconColor, size: 24),
    );
  }

  Color _getStatusColor() {
    switch (item.status) {
      case FreshnessStatus.fresh:
        return Colors.green;
      case FreshnessStatus.useSoon:
        return Colors.orange;
      case FreshnessStatus.spoiled:
        return Colors.red;
    }
  }

  String _getStatusText() {
    switch (item.status) {
      case FreshnessStatus.fresh:
        return 'Fresh';
      case FreshnessStatus.useSoon:
        return 'Use Soon';
      case FreshnessStatus.spoiled:
        return 'Spoiled';
    }
  }

  String _formatExpiryDate() {
    if (item.spoilageDate == null) return 'Unknown';

    final now = DateTime.now();
    final expiry = item.spoilageDate!;
    final difference = expiry.difference(now).inDays;

    if (difference < 0) {
      final daysAgo = -difference;
      return daysAgo == 1 ? '1 day ago' : '$daysAgo days ago';
    } else if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else {
      return DateFormat('MMM dd').format(expiry);
    }
  }

  Color _getExpiryTextColor(BuildContext context) {
    if (item.spoilageDate == null)
      return Theme.of(context).textTheme.bodySmall!.color!;

    if (item.isExpired) {
      return Colors.red;
    } else if (item.isSoonToExpire) {
      return Colors.orange;
    } else {
      return Theme.of(context).textTheme.bodySmall!.color!;
    }
  }
}
