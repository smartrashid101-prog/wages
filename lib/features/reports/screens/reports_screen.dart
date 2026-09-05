import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:io';
import 'package:wages/services/pdf_service.dart';  // ✅ Fixed

// Simple Employee class for reports
class ReportEmployee {
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
  
  ReportEmployee({
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

// Simple WorkRecord class for reports
class ReportWorkRecord {
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
  
  ReportWorkRecord({
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
class ReportMoneyUtils {
  static String formatCurrency(int cents, {String currencySymbol = '£'}) {
    final pounds = cents / 100;
    return '$currencySymbol${pounds.toStringAsFixed(2)}';
  }
}

// Simple Time Utils
class ReportTimeUtils {
  static String formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours == 0) return '${mins}m';
    if (mins == 0) return '${hours}h';
    return '${hours}h ${mins}m';
  }
}

// Report Summary Card - Dashboard Style
class ReportSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  final Color? color;
  final Color? backgroundColor;
  
  const ReportSummaryCard({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (color ?? Colors.blue).withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (color ?? Colors.blue).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: color ?? Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Report Chart - Dashboard Style
class ReportChart extends StatelessWidget {
  final List<ChartData> data;
  final ReportPeriod period;
  
  const ReportChart({
    super.key,
    required this.data,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
        ),
        child: const Center(
          child: Text(
            'No data to display',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      );
    }
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.show_chart,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Earnings Overview',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxY(),
                  barGroups: _getBarGroups(),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: _leftTitles,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: _bottomTitles,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return const FlLine(
                        color: Colors.grey,
                        strokeWidth: 0.5,
                      );
                    },
                  ),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '£${rod.toY.toStringAsFixed(2)}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  double _getMaxY() {
    if (data.isEmpty) return 100;
    final maxPay = data.map((e) => e.totalPay.toDouble()).reduce((a, b) => a > b ? a : b);
    return (maxPay * 1.2).ceilToDouble();
  }
  
  List<BarChartGroupData> _getBarGroups() {
    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: item.totalPay.toDouble(),
            color: Colors.blue,
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }
  
  Widget _leftTitles(double value, TitleMeta meta) {
    final style = TextStyle(
      fontSize: 10,
      color: Colors.grey.shade600,
    );
    
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        '£${value.toInt()}',
        style: style,
      ),
    );
  }
  
  Widget _bottomTitles(double value, TitleMeta meta) {
    final style = TextStyle(
      fontSize: 10,
      color: Colors.grey.shade600,
    );
    
    final index = value.toInt();
    if (index < 0 || index >= data.length) {
      return const SizedBox.shrink();
    }
    
    String label = data[index].label;
    
    if (period == ReportPeriod.weekly) {
      label = label.substring(0, 3);
    }
    
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        label,
        style: style,
      ),
    );
  }
}

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  // ✅ Default to Monthly
  ReportPeriod _selectedPeriod = ReportPeriod.monthly;
  String? _selectedEmployeeId;
  DateTime _referenceDate = DateTime.now();
  
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  
  List<ReportWorkRecord> _records = [];
  List<ReportEmployee> _employees = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  // ✅ Pagination variables for detailed breakdown
  int _breakdownPageSize = 5;
  int _breakdownCurrentPage = 0;
  List<ReportWorkRecord> _breakdownDisplayed = [];
  bool _breakdownHasMore = true;
  bool _breakdownLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
      // Reset pagination
      _breakdownCurrentPage = 0;
      _breakdownDisplayed = [];
      _breakdownHasMore = true;
    });

    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        setState(() {
          _records = [];
          _employees = [];
          _isLoading = false;
        });
        return;
      }

      final empResponse = await Supabase.instance.client
          .from('employees')
          .select()
          .eq('user_id', session.user.id);

      _employees = (empResponse as List)
          .where((json) => json['deleted_at'] == null)
          .map((json) => ReportEmployee(
            id: json['id'],
            userId: json['user_id'],
            name: json['name'],
            hourlyRateCents: json['hourly_rate_cents'],
            overtimeRateCents: json['overtime_rate_cents'],
            overtimeMultiplier: (json['overtime_multiplier'] as num).toDouble(),
            active: json['active'],
            createdAt: DateTime.parse(json['created_at']),
            updatedAt: DateTime.parse(json['updated_at']),
            deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
          ))
          .toList();

      final recResponse = await Supabase.instance.client
          .from('work_records')
          .select()
          .eq('user_id', session.user.id)
          .order('work_date', ascending: false);

      _records = (recResponse as List)
          .where((json) => json['deleted_at'] == null)
          .map((json) => ReportWorkRecord(
            id: json['id'],
            userId: json['user_id'],
            employeeId: json['employee_id'],
            workDate: DateTime.parse(json['work_date']),
            startTime: json['start_time'],
            endTime: json['end_time'],
            breakMinutes: json['break_minutes'],
            overtimeMode: json['overtime_mode'],
            regularMinutes: json['regular_minutes'],
            overtimeMinutes: json['overtime_minutes'],
            totalMinutes: json['total_minutes'],
            hourlyRateCents: json['hourly_rate_cents'],
            overtimeRateCents: json['overtime_rate_cents'],
            bonusCents: json['bonus_cents'],
            deductionsCents: json['deductions_cents'],
            regularPayCents: json['regular_pay_cents'],
            overtimePayCents: json['overtime_pay_cents'],
            grossPayCents: json['gross_pay_cents'],
            netPayCents: json['net_pay_cents'],
            notes: json['notes'],
            createdAt: DateTime.parse(json['created_at']),
            updatedAt: DateTime.parse(json['updated_at']),
            deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
          ))
          .toList();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading data: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  // ✅ Load breakdown page with pagination
  void _loadBreakdownPage(List<ReportWorkRecord> allRecords, {bool isLoadMore = false}) {
    if (allRecords.isEmpty) {
      setState(() {
        _breakdownDisplayed = [];
        _breakdownHasMore = false;
      });
      return;
    }

    final start = _breakdownCurrentPage * _breakdownPageSize;
    final end = (start + _breakdownPageSize) > allRecords.length 
        ? allRecords.length 
        : start + _breakdownPageSize;
    
    if (start >= allRecords.length) {
      setState(() {
        _breakdownHasMore = false;
        _breakdownLoadingMore = false;
      });
      return;
    }

    final newRecords = allRecords.sublist(start, end);
    
    setState(() {
      if (isLoadMore) {
        _breakdownDisplayed.addAll(newRecords);
      } else {
        _breakdownDisplayed = newRecords;
      }
      _breakdownCurrentPage++;
      _breakdownHasMore = end < allRecords.length;
      _breakdownLoadingMore = false;
    });
  }

  // ✅ Load more records
  void _loadMoreBreakdown() {
    if (_breakdownLoadingMore || !_breakdownHasMore) return;
    
    setState(() {
      _breakdownLoadingMore = true;
    });
    
    final filtered = _filterRecords(_records);
    _loadBreakdownPage(filtered, isLoadMore: true);
  }

  Future<void> _selectCustomDateRange() async {
    final now = DateTime.now();
    final initialRange = DateTimeRange(
      start: _customStartDate ?? DateTime(now.year, now.month, 1),
      end: _customEndDate ?? now,
    );

    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: initialRange,
    );

    if (pickedRange != null) {
      setState(() {
        _selectedPeriod = ReportPeriod.custom;
        _customStartDate = pickedRange.start;
        _customEndDate = pickedRange.end;
        // Reset pagination
        _breakdownCurrentPage = 0;
        _breakdownDisplayed = [];
        _breakdownHasMore = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reports',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF4c5b92),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _breakdownCurrentPage = 0;
                _breakdownDisplayed = [];
                _breakdownHasMore = true;
              });
              _loadData();
            },
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _generatePDF,
            tooltip: 'Export PDF',
          ),
          PopupMenuButton<ReportPeriod>(
            initialValue: _selectedPeriod,
            onSelected: (period) {
              if (period == ReportPeriod.custom) {
                _selectCustomDateRange();
              } else {
                setState(() {
                  _selectedPeriod = period;
                  if (period == ReportPeriod.monthly) {
                    _referenceDate = DateTime.now();
                  }
                  // Reset pagination
                  _breakdownCurrentPage = 0;
                  _breakdownDisplayed = [];
                  _breakdownHasMore = true;
                });
              }
            },
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: ReportPeriod.monthly,
                child: Text('Monthly'),
              ),
              PopupMenuItem(
                value: ReportPeriod.weekly,
                child: Text('Weekly'),
              ),
              PopupMenuItem(
                value: ReportPeriod.yearly,
                child: Text('Yearly'),
              ),
              PopupMenuItem(
                value: ReportPeriod.custom,
                child: Text('Custom Date Range'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.error_outline, size: 64, color: Colors.red),
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading data',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: const Color(0xFF4c5b92),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final filtered = _filterRecords(_records);
    
    if (filtered.isEmpty) {
      return _buildEmptyState();
    }
    
    // ✅ Initialize breakdown if empty
    if (_breakdownDisplayed.isEmpty) {
      _loadBreakdownPage(filtered);
    }
    
    final reportData = _generateReportData(filtered);
    final chartData = _getChartData(filtered);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date selector - Dashboard Style
          Container(
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.purple.shade200,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  if (_selectedPeriod != ReportPeriod.custom)
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        setState(() {
                          _referenceDate = _getPreviousPeriodDate(_referenceDate);
                          // Reset pagination
                          _breakdownCurrentPage = 0;
                          _breakdownDisplayed = [];
                          _breakdownHasMore = true;
                        });
                      },
                    ),
                  Expanded(
                    child: InkWell(
                      onTap: _selectCustomDateRange,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.calendar_today,
                                color: Colors.purple,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _getPeriodTitle(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_selectedPeriod != ReportPeriod.custom)
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        setState(() {
                          _referenceDate = _getNextPeriodDate(_referenceDate);
                          // Reset pagination
                          _breakdownCurrentPage = 0;
                          _breakdownDisplayed = [];
                          _breakdownHasMore = true;
                        });
                      },
                    ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Employee filter
          Container(
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.orange.shade200,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              child: DropdownButtonFormField<String>(
                initialValue: _selectedEmployeeId,
                decoration: const InputDecoration(
                  labelText: 'Employee',
                  labelStyle: TextStyle(fontSize: 12, color: Colors.grey),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.person, color: Colors.orange, size: 20),
                ),
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
                dropdownColor: Colors.white,
                iconEnabledColor: Colors.orange,
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('All Employees'),
                  ),
                  ..._employees.map((employee) {
                    return DropdownMenuItem(
                      value: employee.id,
                      child: Text(employee.name),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedEmployeeId = value;
                    // Reset pagination on filter change
                    _breakdownCurrentPage = 0;
                    _breakdownDisplayed = [];
                    _breakdownHasMore = true;
                  });
                },
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: ReportSummaryCard(
                  title: 'Total Hours',
                  value: ReportTimeUtils.formatDuration(reportData.totalMinutes),
                  icon: Icons.timer,
                  color: Colors.blue,
                  backgroundColor: Colors.blue.shade50,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ReportSummaryCard(
                  title: 'Regular Hours',
                  value: ReportTimeUtils.formatDuration(reportData.regularMinutes),
                  icon: Icons.check_circle,
                  color: Colors.green,
                  backgroundColor: Colors.green.shade50,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ReportSummaryCard(
                  title: 'Overtime Hrs',
                  value: ReportTimeUtils.formatDuration(reportData.overtimeMinutes),
                  icon: Icons.star,
                  color: Colors.orange,
                  backgroundColor: Colors.orange.shade50,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ReportSummaryCard(
                  title: 'Gross Pay',
                  value: ReportMoneyUtils.formatCurrency(reportData.grossPayCents),
                  icon: Icons.currency_pound,
                  color: Colors.purple,
                  backgroundColor: Colors.purple.shade50,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ReportSummaryCard(
            title: 'Net Pay',
            value: ReportMoneyUtils.formatCurrency(reportData.netPayCents),
            icon: Icons.attach_money,
            color: Colors.green,
            backgroundColor: Colors.green.shade50,
          ),
          
          const SizedBox(height: 16),
          
          // Chart
          ReportChart(
            data: chartData,
            period: _selectedPeriod,
          ),
          
          const SizedBox(height: 16),
          
          // ✅ Detailed Breakdown with Pagination
          Container(
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.teal.shade200,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.list_alt,
                          color: Colors.teal,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Detailed Breakdown',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildDetailedBreakdown(filtered),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Export Button
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue.shade200,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: _generatePDF,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text(
                'Export as PDF',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                foregroundColor: const Color(0xFF4c5b92),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<ReportWorkRecord> _filterRecords(List<ReportWorkRecord> records) {
    var filtered = records;
    
    if (_selectedEmployeeId != null) {
      filtered = filtered.where((record) {
        return record.employeeId == _selectedEmployeeId;
      }).toList();
    }
    
    final (start, end) = _getPeriodRange();
    filtered = filtered.where((record) {
      final recordDate = DateTime(record.workDate.year, record.workDate.month, record.workDate.day);
      final startDate = DateTime(start.year, start.month, start.day);
      final endDate = DateTime(end.year, end.month, end.day, 23, 59, 59);
      return (recordDate.isAfter(startDate) || recordDate.isAtSameMomentAs(startDate)) &&
             (recordDate.isBefore(endDate) || recordDate.isAtSameMomentAs(endDate));
    }).toList();
    
    return filtered;
  }

  (DateTime, DateTime) _getPeriodRange() {
    switch (_selectedPeriod) {
      case ReportPeriod.weekly:
        final start = _referenceDate.subtract(Duration(days: _referenceDate.weekday - 1));
        final end = start.add(const Duration(days: 6));
        return (start, end);
      case ReportPeriod.monthly:
        final start = DateTime(_referenceDate.year, _referenceDate.month, 1);
        final end = DateTime(_referenceDate.year, _referenceDate.month + 1, 0);
        return (start, end);
      case ReportPeriod.yearly:
        final start = DateTime(_referenceDate.year, 1, 1);
        final end = DateTime(_referenceDate.year, 12, 31);
        return (start, end);
      case ReportPeriod.custom:
        final start = _customStartDate ?? DateTime.now();
        final end = _customEndDate ?? DateTime.now();
        return (start, end);
    }
  }

  String _getPeriodTitle() {
    switch (_selectedPeriod) {
      case ReportPeriod.weekly:
        final start = _referenceDate.subtract(Duration(days: _referenceDate.weekday - 1));
        final end = start.add(const Duration(days: 6));
        return '${DateFormat('dd MMM').format(start)} - ${DateFormat('dd MMM yyyy').format(end)}';
      case ReportPeriod.monthly:
        return DateFormat('MMMM yyyy').format(_referenceDate);
      case ReportPeriod.yearly:
        return DateFormat('yyyy').format(_referenceDate);
      case ReportPeriod.custom:
        if (_customStartDate == null || _customEndDate == null) return 'Custom Range';
        return '${DateFormat('dd MMM yyyy').format(_customStartDate!)} - ${DateFormat('dd MMM yyyy').format(_customEndDate!)}';
    }
  }

  DateTime _getPreviousPeriodDate(DateTime date) {
    switch (_selectedPeriod) {
      case ReportPeriod.weekly:
        return date.subtract(const Duration(days: 7));
      case ReportPeriod.monthly:
        return DateTime(date.year, date.month - 1, 1);
      case ReportPeriod.yearly:
        return DateTime(date.year - 1, 1, 1);
      case ReportPeriod.custom:
        return date;
    }
  }

  DateTime _getNextPeriodDate(DateTime date) {
    switch (_selectedPeriod) {
      case ReportPeriod.weekly:
        return date.add(const Duration(days: 7));
      case ReportPeriod.monthly:
        return DateTime(date.year, date.month + 1, 1);
      case ReportPeriod.yearly:
        return DateTime(date.year + 1, 1, 1);
      case ReportPeriod.custom:
        return date;
    }
  }

  ReportData _generateReportData(List<ReportWorkRecord> records) {
    int totalMinutes = 0;
    int regularMinutes = 0;
    int overtimeMinutes = 0;
    int regularPay = 0;
    int overtimePay = 0;
    int bonus = 0;
    int deductions = 0;
    int grossPay = 0;
    int netPay = 0;
    
    for (final record in records) {
      totalMinutes += record.totalMinutes;
      regularMinutes += record.regularMinutes;
      overtimeMinutes += record.overtimeMinutes;
      regularPay += record.regularPayCents;
      overtimePay += record.overtimePayCents;
      bonus += record.bonusCents;
      deductions += record.deductionsCents;
      grossPay += record.grossPayCents;
      netPay += record.netPayCents;
    }
    
    return ReportData(
      totalMinutes: totalMinutes,
      regularMinutes: regularMinutes,
      overtimeMinutes: overtimeMinutes,
      regularPayCents: regularPay,
      overtimePayCents: overtimePay,
      bonusCents: bonus,
      deductionsCents: deductions,
      grossPayCents: grossPay,
      netPayCents: netPay,
      recordCount: records.length,
    );
  }

  List<ChartData> _getChartData(List<ReportWorkRecord> records) {
    final Map<String, ChartData> dataMap = {};
    
    for (final record in records) {
      String key;
      switch (_selectedPeriod) {
        case ReportPeriod.weekly:
          key = DateFormat('EEE').format(record.workDate);
          break;
        case ReportPeriod.monthly:
          key = DateFormat('dd').format(record.workDate);
          break;
        case ReportPeriod.yearly:
          key = DateFormat('MMM').format(record.workDate);
          break;
        case ReportPeriod.custom:
          key = DateFormat('dd MMM').format(record.workDate);
          break;
      }
      
      if (dataMap.containsKey(key)) {
        dataMap[key]!.totalPay += record.netPayCents;
        dataMap[key]!.totalHours += record.totalMinutes;
      } else {
        dataMap[key] = ChartData(
          label: key,
          totalPay: record.netPayCents,
          totalHours: record.totalMinutes,
        );
      }
    }
    
    return dataMap.values.toList();
  }

  // ✅ Updated Detailed Breakdown with Pagination
  Widget _buildDetailedBreakdown(List<ReportWorkRecord> records) {
    if (records.isEmpty) {
      return const Text('No records found');
    }
    
    final employeeMap = {for (var e in _employees) e.id: e.name};
    
    // Show loading indicator while loading more
    if (_breakdownLoadingMore) {
      return Column(
        children: [
          _buildBreakdownList(employeeMap),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      );
    }
    
    return Column(
      children: [
        // Show record count and pagination info
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Showing ${_breakdownDisplayed.length} of ${records.length} records',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Row(
                children: [
                  // Page info
                  if (_breakdownDisplayed.isNotEmpty)
                    Text(
                      'Page ${_breakdownCurrentPage}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  const SizedBox(width: 8),
                  // Load More button
                  if (_breakdownHasMore)
                    TextButton.icon(
                      onPressed: _loadMoreBreakdown,
                      icon: const Icon(Icons.expand_more, size: 18),
                      label: Text(
                        'Load More (${records.length - _breakdownDisplayed.length})',
                        style: const TextStyle(fontSize: 12),
                      ),
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        
        // Display records
        _buildBreakdownList(employeeMap),
        
        // Load More button at bottom (alternative)
        if (_breakdownHasMore && _breakdownDisplayed.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _loadMoreBreakdown,
                icon: const Icon(Icons.expand_more, size: 18),
                label: Text(
                  'Load ${_breakdownPageSize} More (${records.length - _breakdownDisplayed.length} remaining)',
                ),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        
        // Show all button if records are too many
        if (records.length > 50)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton.icon(
              onPressed: () {
                _showAllRecordsDialog(records);
              },
              icon: const Icon(Icons.view_list, size: 16),
              label: Text('View All ${records.length} Records'),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ✅ Extract list builder to avoid duplication
  Widget _buildBreakdownList(Map<String, String> employeeMap) {
    if (_breakdownDisplayed.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No records to display'),
        ),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _breakdownDisplayed.length,
      itemBuilder: (context, index) {
        final record = _breakdownDisplayed[index];
        final employeeName = employeeMap[record.employeeId] ?? 'Unknown';
        
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Text(
                employeeName[0].toUpperCase(),
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              employeeName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${DateFormat('dd MMM yyyy').format(record.workDate)} '
              '• ${ReportTimeUtils.formatDuration(record.totalMinutes)}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            trailing: Text(
              ReportMoneyUtils.formatCurrency(record.netPayCents),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
                fontSize: 15,
              ),
            ),
          ),
        );
      },
    );
  }

  // ✅ Show all records in a modal bottom sheet with pagination
  void _showAllRecordsDialog(List<ReportWorkRecord> records) {
    final employeeMap = {for (var e in _employees) e.id: e.name};
    int pageSize = 20;
    int currentPage = 0;
    List<ReportWorkRecord> displayedRecords = [];
    bool hasMore = true;
    
    // Initial load
    void loadPage() {
      final start = currentPage * pageSize;
      final end = (start + pageSize) > records.length ? records.length : start + pageSize;
      
      if (start >= records.length) {
        hasMore = false;
        return;
      }
      
      final newRecords = records.sublist(start, end);
      displayedRecords.addAll(newRecords);
      currentPage++;
      hasMore = end < records.length;
    }
    
    loadPage();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateBottomSheet) {
            return DraggableScrollableSheet(
              initialChildSize: 0.85,
              maxChildSize: 0.95,
              minChildSize: 0.5,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'All Records',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${records.length} records',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: displayedRecords.length + (hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            // Load more indicator
                            if (index == displayedRecords.length && hasMore) {
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Loading more...',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            
                            final record = displayedRecords[index];
                            final employeeName = employeeMap[record.employeeId] ?? 'Unknown';
                            
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.blue.shade200,
                                  width: 1,
                                ),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue.shade100,
                                  child: Text(
                                    employeeName[0].toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  employeeName,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  '${DateFormat('dd MMM yyyy').format(record.workDate)} '
                                  '• ${ReportTimeUtils.formatDuration(record.totalMinutes)}',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      ReportMoneyUtils.formatCurrency(record.netPayCents),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade700,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      '${record.startTime} - ${record.endTime}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Load more button in dialog
                      if (hasMore)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                setStateBottomSheet(() {
                                  loadPage();
                                });
                              },
                              icon: const Icon(Icons.expand_more),
                              label: Text('Load More (${records.length - displayedRecords.length} remaining)'),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _generatePDF() async {
    final filteredRecordsList = _filterRecords(_records);

    if (filteredRecordsList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data to export')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        throw Exception('User not authenticated');
      }

      final pdfEmployees = _employees
          .where((e) => _selectedEmployeeId == null || e.id == _selectedEmployeeId)
          .map((e) => PdfEmployee(
                id: e.id,
                userId: e.userId,
                name: e.name,
                hourlyRateCents: e.hourlyRateCents,
                overtimeRateCents: e.overtimeRateCents,
                overtimeMultiplier: e.overtimeMultiplier,
                active: e.active,
                createdAt: e.createdAt,
                updatedAt: e.updatedAt,
                deletedAt: e.deletedAt,
              ))
          .toList();

      final pdfRecords = filteredRecordsList.map((r) => PdfWorkRecord(
        id: r.id,
        userId: r.userId,
        employeeId: r.employeeId,
        workDate: r.workDate,
        startTime: r.startTime,
        endTime: r.endTime,
        breakMinutes: r.breakMinutes,
        overtimeMode: r.overtimeMode,
        regularMinutes: r.regularMinutes,
        overtimeMinutes: r.overtimeMinutes,
        totalMinutes: r.totalMinutes,
        hourlyRateCents: r.hourlyRateCents,
        overtimeRateCents: r.overtimeRateCents,
        bonusCents: r.bonusCents,
        deductionsCents: r.deductionsCents,
        regularPayCents: r.regularPayCents,
        overtimePayCents: r.overtimePayCents,
        grossPayCents: r.grossPayCents,
        netPayCents: r.netPayCents,
        notes: r.notes,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
        deletedAt: r.deletedAt,
      )).toList();

      final periodTitle = _getPeriodTitle();
      final (start, end) = _getPeriodRange();

      String? employeeName;
      if (_selectedEmployeeId != null) {
        final emp = _employees.firstWhere(
          (e) => e.id == _selectedEmployeeId,
          orElse: () => ReportEmployee(
            id: '',
            userId: '',
            name: '',
            hourlyRateCents: 0,
            overtimeRateCents: 0,
            overtimeMultiplier: 1,
            active: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        if (emp.name.isNotEmpty) {
          employeeName = emp.name;
        }
      }

      final pdfService = PdfService();
      final file = await pdfService.generateReport(
        records: pdfRecords,
        employees: pdfEmployees,
        periodTitle: periodTitle,
        periodType: _selectedPeriod.toString(),
        startDate: start,
        endDate: end,
        employeeName: employeeName,
      );

      if (mounted) {
        _showPDFOptionsDialog(file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showPDFOptionsDialog(File file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PDF Generated'),
        content: const Text('What would you like to do with the PDF?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final pdfService = PdfService();
                await pdfService.sharePdf(file, message: 'WAGES Report - ${_getPeriodTitle()}');
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to share: $e')),
                  );
                }
              }
            },
            child: const Text('Share'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final pdfService = PdfService();
                await pdfService.printPdf(file);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to print: $e')),
                  );
                }
              }
            },
            child: const Text('Print'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.assessment_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'No Data Available',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Add some work records to see reports',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 16),
        // ✅ Only "Add Record" button, no refresh
        ElevatedButton.icon(
          onPressed: () {
            // Navigate to calculator
            Navigator.pushReplacementNamed(context, '/main');
          },
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Add Work Record',
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: const Color(0xFF4c5b92),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    ),
  );
}
}

enum ReportPeriod {
  weekly,
  monthly,
  yearly,
  custom,
}

class ReportData {
  final int totalMinutes;
  final int regularMinutes;
  final int overtimeMinutes;
  final int regularPayCents;
  final int overtimePayCents;
  final int bonusCents;
  final int deductionsCents;
  final int grossPayCents;
  final int netPayCents;
  final int recordCount;
  
  ReportData({
    required this.totalMinutes,
    required this.regularMinutes,
    required this.overtimeMinutes,
    required this.regularPayCents,
    required this.overtimePayCents,
    required this.bonusCents,
    required this.deductionsCents,
    required this.grossPayCents,
    required this.netPayCents,
    required this.recordCount,
  });
}

class ChartData {
  final String label;
  int totalPay;
  int totalHours;
  
  ChartData({
    required this.label,
    required this.totalPay,
    required this.totalHours,
  });
}