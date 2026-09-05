import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_constants.dart';

// Simple Money Utils
class MoneyUtils {
  static String formatCurrency(int cents, {String currencySymbol = '£'}) {
    final pounds = cents / 100;
    return '$currencySymbol${pounds.toStringAsFixed(2)}';
  }
}

// Simple Time Utils
class TimeUtils {
  static String formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours == 0) return '${mins}m';
    if (mins == 0) return '${hours}h';
    return '${hours}h ${mins}m';
  }
}

// Simple Employee class for PDF
class PdfEmployee {
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

  PdfEmployee({
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

// Simple WorkRecord class for PDF
class PdfWorkRecord {
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

  PdfWorkRecord({
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

class PdfService {
  /// Generate a PDF report for the given period
  Future<File> generateReport({
    required List<PdfWorkRecord> records,
    required List<PdfEmployee> employees,
    required String periodTitle,
    required String periodType,
    DateTime? startDate,
    DateTime? endDate,
    String? employeeName,
  }) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return [
              _buildReportHeader(periodTitle, startDate, endDate, employeeName),
              _buildSummarySection(records),
              _buildDetailedRecordsSection(records, employees),
            ];
          },
          footer: (pw.Context context) => _buildFooter(context),
        ),
      );

      final bytes = await pdf.save();
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/wages_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(bytes);

      return file;
    } catch (e) {
      print('❌ PDF Generation Error: $e');
      rethrow;
    }
  }

  /// Generate a single employee report
  Future<File> generateEmployeeReport({
    required PdfEmployee employee,
    required List<PdfWorkRecord> records,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return [
              _buildEmployeeReportHeader(employee, startDate, endDate),
              _buildEmployeeSummary(employee, records),
              _buildDetailedRecordsSection(records, [employee]),
            ];
          },
          footer: (pw.Context context) => _buildFooter(context),
        ),
      );

      final bytes = await pdf.save();
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/employee_${employee.name}_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(bytes);

      return file;
    } catch (e) {
      print('❌ Employee PDF Generation Error: $e');
      rethrow;
    }
  }

  /// Share PDF via native share sheet
  Future<void> sharePdf(File file, {String? message}) async {
    try {
      await Share.shareXFiles(
        [XFile(file.path)],
        text: message ?? 'WAGES Report',
      );
    } catch (e) {
      throw Exception('Failed to share PDF: $e');
    }
  }

  /// Print PDF
  Future<void> printPdf(File file) async {
    try {
      final bytes = await file.readAsBytes();
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => bytes,
      );
    } catch (e) {
      throw Exception('Failed to print PDF: $e');
    }
  }

  // Private builders

  pw.Widget _buildReportHeader(
    String periodTitle,
    DateTime? startDate,
    DateTime? endDate,
    String? employeeName,
  ) {
    final appName = AppConstants.appName;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          appName,
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Hours & Wages Calculator',
          style: const pw.TextStyle(
            fontSize: 14,
            color: PdfColors.grey600,
          ),
        ),
        pw.Divider(),
        pw.SizedBox(height: 8),
        pw.Text(
          periodTitle.isEmpty ? 'Report' : periodTitle,
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        if (employeeName != null && employeeName.isNotEmpty)
          pw.Text(
            'Employee: $employeeName',
            style: const pw.TextStyle(fontSize: 14),
          ),
        if (startDate != null && endDate != null)
          pw.Text(
            'Period: ${DateFormat('dd MMM yyyy').format(startDate)} - ${DateFormat('dd MMM yyyy').format(endDate)}',
            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
          ),
        pw.Text(
          'Generated: ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}',
          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
        ),
        pw.SizedBox(height: 16),
      ],
    );
  }

  pw.Widget _buildEmployeeReportHeader(PdfEmployee employee, DateTime startDate, DateTime endDate) {
    final appName = AppConstants.appName;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          appName,
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Employee Report',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Name: ${employee.name}',
          style: const pw.TextStyle(fontSize: 14),
        ),
        pw.Text(
          'Rate: ${MoneyUtils.formatCurrency(employee.hourlyRateCents)}/hr',
          style: const pw.TextStyle(fontSize: 14),
        ),
        pw.Text(
          'Overtime Rate: ${MoneyUtils.formatCurrency(employee.overtimeRateCents)}/hr',
          style: const pw.TextStyle(fontSize: 14),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Period: ${DateFormat('dd MMM yyyy').format(startDate)} - ${DateFormat('dd MMM yyyy').format(endDate)}',
          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
        ),
        pw.Text(
          'Generated: ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}',
          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
        ),
        pw.SizedBox(height: 16),
      ],
    );
  }

  pw.Widget _buildSummarySection(List<PdfWorkRecord> records) {
    if (records.isEmpty) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Text(
          'No records found for this period',
          style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey600),
        ),
      );
    }

    int totalMinutes = 0;
    int regularMinutes = 0;
    int overtimeMinutes = 0;
    int totalGrossPay = 0;
    int totalNetPay = 0;
    int totalBonus = 0;
    int totalDeductions = 0;

    for (final record in records) {
      totalMinutes += record.totalMinutes;
      regularMinutes += record.regularMinutes;
      overtimeMinutes += record.overtimeMinutes;
      totalGrossPay += record.grossPayCents;
      totalNetPay += record.netPayCents;
      totalBonus += record.bonusCents;
      totalDeductions += record.deductionsCents;
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Summary',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              _buildSummaryItem('Days Worked', '${records.length}'),
              _buildSummaryItem('Total Hours', TimeUtils.formatDuration(totalMinutes)),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            children: [
              _buildSummaryItem('Regular Hours', TimeUtils.formatDuration(regularMinutes)),
              _buildSummaryItem('Overtime Hours', TimeUtils.formatDuration(overtimeMinutes)),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            children: [
              _buildSummaryItem('Gross Pay', MoneyUtils.formatCurrency(totalGrossPay)),
              _buildSummaryItem('Net Pay', MoneyUtils.formatCurrency(totalNetPay)),
            ],
          ),
          if (totalBonus > 0 || totalDeductions > 0) ...[
            pw.SizedBox(height: 4),
            pw.Row(
              children: [
                if (totalBonus > 0)
                  _buildSummaryItem('Total Bonus', MoneyUtils.formatCurrency(totalBonus)),
                if (totalDeductions > 0)
                  _buildSummaryItem('Total Deductions', MoneyUtils.formatCurrency(totalDeductions)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildSummaryItem(String label, String value) {
    return pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(
              fontSize: 11,
              color: PdfColors.grey600,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildEmployeeSummary(PdfEmployee employee, List<PdfWorkRecord> records) {
    if (records.isEmpty) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Text(
          'No records found for this period',
          style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey600),
        ),
      );
    }

    int totalMinutes = 0;
    int regularMinutes = 0;
    int overtimeMinutes = 0;
    int totalRegularPay = 0;
    int totalOvertimePay = 0;
    int totalGrossPay = 0;
    int totalNetPay = 0;
    int totalBonus = 0;
    int totalDeductions = 0;

    for (final record in records) {
      totalMinutes += record.totalMinutes;
      regularMinutes += record.regularMinutes;
      overtimeMinutes += record.overtimeMinutes;
      totalRegularPay += record.regularPayCents;
      totalOvertimePay += record.overtimePayCents;
      totalGrossPay += record.grossPayCents;
      totalNetPay += record.netPayCents;
      totalBonus += record.bonusCents;
      totalDeductions += record.deductionsCents;
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Summary for ${employee.name}',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              _buildSummaryItem('Shifts', '${records.length}'),
              _buildSummaryItem('Total Hours', TimeUtils.formatDuration(totalMinutes)),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            children: [
              _buildSummaryItem('Regular Hours', TimeUtils.formatDuration(regularMinutes)),
              _buildSummaryItem('Overtime Hours', TimeUtils.formatDuration(overtimeMinutes)),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            children: [
              _buildSummaryItem('Regular Pay', MoneyUtils.formatCurrency(totalRegularPay)),
              _buildSummaryItem('Overtime Pay', MoneyUtils.formatCurrency(totalOvertimePay)),
            ],
          ),
          if (totalBonus > 0 || totalDeductions > 0) ...[
            pw.SizedBox(height: 4),
            pw.Row(
              children: [
                if (totalBonus > 0)
                  _buildSummaryItem('Total Bonus', MoneyUtils.formatCurrency(totalBonus)),
                if (totalDeductions > 0)
                  _buildSummaryItem('Total Deductions', MoneyUtils.formatCurrency(totalDeductions)),
              ],
            ),
          ],
          pw.SizedBox(height: 4),
          pw.Row(
            children: [
              _buildSummaryItem('Gross Pay', MoneyUtils.formatCurrency(totalGrossPay)),
              _buildSummaryItem('Net Pay', MoneyUtils.formatCurrency(totalNetPay)),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildDetailedRecordsSection(
    List<PdfWorkRecord> records, 
    List<PdfEmployee> employees,
  ) {
    if (records.isEmpty) {
      return pw.Container();
    }

    final employeeMap = {for (var e in employees) e.id: e.name};

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 16),
        pw.Text(
          'Detailed Records',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: const {
            0: pw.FixedColumnWidth(30),   // #
            1: pw.FixedColumnWidth(90),   // Employee
            2: pw.FixedColumnWidth(80),   // Date
            3: pw.FixedColumnWidth(55),   // Start
            4: pw.FixedColumnWidth(55),   // End
            5: pw.FixedColumnWidth(50),   // Break
            6: pw.FixedColumnWidth(55),   // Hours
            7: pw.FixedColumnWidth(60),   // Gross
            8: pw.FixedColumnWidth(60),   // Net
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(
                color: PdfColors.blue100,
              ),
              children: [
                _buildTableCell('#', bold: true),
                _buildTableCell('Employee', bold: true),
                _buildTableCell('Date', bold: true),
                _buildTableCell('Start', bold: true),
                _buildTableCell('End', bold: true),
                _buildTableCell('Break', bold: true),
                _buildTableCell('Hours', bold: true),
                _buildTableCell('Gross', bold: true),
                _buildTableCell('Net', bold: true),
              ],
            ),
            ...List.generate(records.length, (index) {
              final record = records[index];
              final employeeName = employeeMap[record.employeeId] ?? 'Unknown';

              return pw.TableRow(
                children: [
                  _buildTableCell('${index + 1}'),
                  _buildTableCell(employeeName),
                  _buildTableCell(DateFormat('dd MMM').format(record.workDate)),
                  _buildTableCell(record.startTime),
                  _buildTableCell(record.endTime),
                  _buildTableCell('${record.breakMinutes}m'),
                  _buildTableCell(TimeUtils.formatDuration(record.totalMinutes)),
                  _buildTableCell(MoneyUtils.formatCurrency(record.grossPayCents)),
                  _buildTableCell(MoneyUtils.formatCurrency(record.netPayCents)),
                ],
              );
            }),
          ],
        ),
        if (records.any((r) => employeeMap[r.employeeId] == null)) ...[
          pw.SizedBox(height: 8),
          pw.Text(
            'Note: Some employee names could not be found',
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.orange,
            ),
          ),
        ],
      ],
    );
  }

  pw.Widget _buildTableCell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildFooter(pw.Context context) {
    final appName = AppConstants.appName;

    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 8),
      child: pw.Column(
        children: [
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 4),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Generated by $appName',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
              ),
              pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}