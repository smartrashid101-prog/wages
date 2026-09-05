import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Simple Employee class for the card
class CardEmployee {
  final String id;
  final String userId;
  final String name;
  final int hourlyRateCents;
  final int overtimeRateCents;
  final double overtimeMultiplier;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  
  CardEmployee({
    required this.id,
    required this.userId,
    required this.name,
    required this.hourlyRateCents,
    required this.overtimeRateCents,
    required this.overtimeMultiplier,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
}

// Simple WorkRecord class for the card
class CardWorkRecord {
  final String id;
  final String userId;
  final String employeeId;
  final DateTime workDate;
  final String startTime;
  final String endTime;
  final int breakMinutes;
  final String overtimeMode;
  final int regularMinutes;
  final int overtimeMinutes;
  final int totalMinutes;
  final int hourlyRateCents;
  final int overtimeRateCents;
  final int bonusCents;
  final int deductionsCents;
  final int regularPayCents;
  final int overtimePayCents;
  final int grossPayCents;
  final int netPayCents;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  
  CardWorkRecord({
    required this.id,
    required this.userId,
    required this.employeeId,
    required this.workDate,
    required this.startTime,
    required this.endTime,
    required this.breakMinutes,
    required this.overtimeMode,
    required this.regularMinutes,
    required this.overtimeMinutes,
    required this.totalMinutes,
    required this.hourlyRateCents,
    required this.overtimeRateCents,
    required this.bonusCents,
    required this.deductionsCents,
    required this.regularPayCents,
    required this.overtimePayCents,
    required this.grossPayCents,
    required this.netPayCents,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
}

// Simple Money Utils
class CardMoneyUtils {
  static String formatCurrency(int cents, {String currencySymbol = '£'}) {
    final pounds = cents / 100;
    return '$currencySymbol${pounds.toStringAsFixed(2)}';
  }
}

// Simple Time Utils
class CardTimeUtils {
  static String formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours == 0) return '${mins}m';
    if (mins == 0) return '${hours}h';
    return '${hours}h ${mins}m';
  }
}

class WorkRecordCard extends StatelessWidget {
  final CardWorkRecord record;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;
  final String employeeName;
  
  const WorkRecordCard({
    super.key,
    required this.record,
    required this.onEdit,
    required this.onDelete,
    required this.onDuplicate,
    required this.employeeName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          child: Text(
            employeeName.isNotEmpty ? employeeName[0].toUpperCase() : '?',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(employeeName.isNotEmpty ? employeeName : 'Unknown Employee'),
        subtitle: Text(
          '${DateFormat('dd MMM yyyy').format(record.workDate)} '
          '• ${CardTimeUtils.formatDuration(record.totalMinutes)}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              CardMoneyUtils.formatCurrency(record.netPayCents),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    onEdit();
                    break;
                  case 'duplicate':
                    onDuplicate();
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
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'duplicate',
                  child: Row(
                    children: [
                      Icon(Icons.copy),
                      SizedBox(width: 8),
                      Text('Duplicate'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time details
                _buildDetailRow(
                  'Time',
                  '${record.startTime} - ${record.endTime}',
                ),
                _buildDetailRow(
                  'Break',
                  '${record.breakMinutes} min',
                ),
                _buildDetailRow(
                  'Overtime Mode',
                  record.overtimeMode.toUpperCase(),
                ),
                const Divider(),
                
                // Hours
                _buildDetailRow(
                  'Regular Hours',
                  CardTimeUtils.formatDuration(record.regularMinutes),
                ),
                _buildDetailRow(
                  'Overtime Hours',
                  CardTimeUtils.formatDuration(record.overtimeMinutes),
                ),
                _buildDetailRow(
                  'Total Hours',
                  CardTimeUtils.formatDuration(record.totalMinutes),
                ),
                const Divider(),
                
                // Pay
                _buildDetailRow(
                  'Regular Pay',
                  CardMoneyUtils.formatCurrency(record.regularPayCents),
                ),
                _buildDetailRow(
                  'Overtime Pay',
                  CardMoneyUtils.formatCurrency(record.overtimePayCents),
                ),
                if (record.bonusCents > 0)
                  _buildDetailRow(
                    'Bonus',
                    CardMoneyUtils.formatCurrency(record.bonusCents),
                  ),
                if (record.deductionsCents > 0)
                  _buildDetailRow(
                    'Deductions',
                    CardMoneyUtils.formatCurrency(record.deductionsCents),
                  ),
                const Divider(),
                _buildDetailRow(
                  'Gross Pay',
                  CardMoneyUtils.formatCurrency(record.grossPayCents),
                  bold: true,
                ),
                _buildDetailRow(
                  'Net Pay',
                  CardMoneyUtils.formatCurrency(record.netPayCents),
                  bold: true,
                  color: Colors.green,
                ),
                
                if (record.notes != null && record.notes!.isNotEmpty) ...[
                  const Divider(),
                  _buildDetailRow(
                    'Notes',
                    record.notes!,
                  ),
                ],
                
                const SizedBox(height: 8),
                Text(
                  'Rate: ${CardMoneyUtils.formatCurrency(record.hourlyRateCents)}/hr',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  'Overtime: ${CardMoneyUtils.formatCurrency(record.overtimeRateCents)}/hr',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: bold ? null : Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}