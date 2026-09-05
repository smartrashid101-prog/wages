import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Simple Employee class for history
class HistoryEmployee {
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
  
  HistoryEmployee({
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

// Simple WorkRecord class for history
class HistoryWorkRecord {
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
  
  HistoryWorkRecord({
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
  
  HistoryWorkRecord copyWith({
    String? id,
    String? userId,
    String? employeeId,
    DateTime? workDate,
    String? startTime,
    String? endTime,
    int? breakMinutes,
    String? overtimeMode,
    int? regularMinutes,
    int? overtimeMinutes,
    int? totalMinutes,
    int? hourlyRateCents,
    int? overtimeRateCents,
    int? bonusCents,
    int? deductionsCents,
    int? regularPayCents,
    int? overtimePayCents,
    int? grossPayCents,
    int? netPayCents,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return HistoryWorkRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      employeeId: employeeId ?? this.employeeId,
      workDate: workDate ?? this.workDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      breakMinutes: breakMinutes ?? this.breakMinutes,
      overtimeMode: overtimeMode ?? this.overtimeMode,
      regularMinutes: regularMinutes ?? this.regularMinutes,
      overtimeMinutes: overtimeMinutes ?? this.overtimeMinutes,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      hourlyRateCents: hourlyRateCents ?? this.hourlyRateCents,
      overtimeRateCents: overtimeRateCents ?? this.overtimeRateCents,
      bonusCents: bonusCents ?? this.bonusCents,
      deductionsCents: deductionsCents ?? this.deductionsCents,
      regularPayCents: regularPayCents ?? this.regularPayCents,
      overtimePayCents: overtimePayCents ?? this.overtimePayCents,
      grossPayCents: grossPayCents ?? this.grossPayCents,
      netPayCents: netPayCents ?? this.netPayCents,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}

// Simple Money Utils
class HistoryMoneyUtils {
  static String formatCurrency(int cents, {String currencySymbol = '£'}) {
    final pounds = cents / 100;
    return '$currencySymbol${pounds.toStringAsFixed(2)}';
  }
}

// Simple Time Utils
class HistoryTimeUtils {
  static String formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours == 0) return '${mins}m';
    if (mins == 0) return '${hours}h';
    return '${hours}h ${mins}m';
  }
}

// WorkRecord Card - Dashboard Style
class WorkRecordCard extends StatelessWidget {
  final HistoryWorkRecord record;
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.5),
        child: ExpansionTile(
          clipBehavior: Clip.antiAlias,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.5)),
          ),
          collapsedShape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.5)),
          ),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          backgroundColor: Colors.blue.shade50,
          collapsedBackgroundColor: Colors.blue.shade50,
          leading: CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: Text(
              employeeName.isNotEmpty ? employeeName[0].toUpperCase() : '?',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            employeeName.isNotEmpty ? employeeName : 'Unknown Employee',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '${DateFormat('dd MMM yyyy').format(record.workDate)} '
            '• ${HistoryTimeUtils.formatDuration(record.totalMinutes)}',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                HistoryMoneyUtils.formatCurrency(record.netPayCents),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
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
                        Icon(Icons.edit, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'duplicate',
                    child: Row(
                      children: [
                        Icon(Icons.copy, color: Colors.orange),
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
            Container(
              color: Colors.blue.shade50,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Time', '${record.startTime} - ${record.endTime}', icon: Icons.access_time, iconColor: Colors.blue),
                  _buildDetailRow('Break', '${record.breakMinutes} min', icon: Icons.free_breakfast, iconColor: Colors.green),
                  _buildDetailRow('Overtime Mode', record.overtimeMode.toUpperCase(), icon: Icons.timer, iconColor: Colors.orange),
                  const Divider(color: Colors.blue, thickness: 1),
                  _buildDetailRow('Regular Hours', HistoryTimeUtils.formatDuration(record.regularMinutes), icon: Icons.check_circle, iconColor: Colors.green),
                  _buildDetailRow('Overtime Hours', HistoryTimeUtils.formatDuration(record.overtimeMinutes), icon: Icons.star, iconColor: Colors.orange),
                  _buildDetailRow('Total Hours', HistoryTimeUtils.formatDuration(record.totalMinutes), icon: Icons.timer, iconColor: Colors.blue, bold: true),
                  const Divider(color: Colors.blue, thickness: 1),
                  _buildDetailRow('Regular Pay', HistoryMoneyUtils.formatCurrency(record.regularPayCents), icon: Icons.currency_pound, iconColor: Colors.green),
                  _buildDetailRow('Overtime Pay', HistoryMoneyUtils.formatCurrency(record.overtimePayCents), icon: Icons.currency_pound, iconColor: Colors.orange),
                  if (record.bonusCents > 0)
                    _buildDetailRow('Bonus', HistoryMoneyUtils.formatCurrency(record.bonusCents), icon: Icons.add_circle, iconColor: Colors.green),
                  if (record.deductionsCents > 0)
                    _buildDetailRow('Deductions', HistoryMoneyUtils.formatCurrency(record.deductionsCents), icon: Icons.remove_circle, iconColor: Colors.red),
                  const Divider(color: Colors.blue, thickness: 2),
                  _buildDetailRow('Gross Pay', HistoryMoneyUtils.formatCurrency(record.grossPayCents), icon: Icons.attach_money, iconColor: Colors.blue, bold: true),
                  _buildDetailRow('Net Pay', HistoryMoneyUtils.formatCurrency(record.netPayCents), icon: Icons.attach_money, iconColor: Colors.green, bold: true, textColor: Colors.green),
                  if (record.notes != null && record.notes!.isNotEmpty) ...[
                    const Divider(color: Colors.blue, thickness: 1),
                    _buildDetailRow('Notes', record.notes!, icon: Icons.note, iconColor: Colors.grey),
                  ],
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              'Rate',
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                            ),
                            Text(
                              HistoryMoneyUtils.formatCurrency(record.hourlyRateCents),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.grey.shade300,
                        ),
                        Column(
                          children: [
                            Text(
                              'Overtime',
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                            ),
                            Text(
                              HistoryMoneyUtils.formatCurrency(record.overtimeRateCents),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
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
  
  Widget _buildDetailRow(String label, String value, {bool bold = false, Color? textColor, IconData? icon, Color? iconColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: iconColor ?? Colors.grey.shade400),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: bold ? Colors.black87 : Colors.grey.shade700,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: textColor ?? (bold ? Colors.black87 : null),
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  // Search & Filter
  String _searchQuery = '';
  String? _selectedEmployeeId;
  DateTime? _startDate;
  DateTime? _endDate;
  
  // Sorting State
  String _sortBy = 'workDate'; // 'workDate', 'netPayCents', 'totalMinutes'
  bool _isAscending = false;
  
  // Pagination
  int _pageSize = 5;
  int _currentPage = 0;
  
  // Lists
  List<HistoryWorkRecord> _rawRecords = [];
  List<HistoryWorkRecord> _allRecords = [];
  List<HistoryWorkRecord> _displayedRecords = [];
  
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  
  List<HistoryEmployee> _employees = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoadingMore || !_hasMoreData) return;
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    
    if (currentScroll >= maxScroll - 150) {
      _loadMore();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _currentPage = 0;
      _displayedRecords = [];
      _hasMoreData = true;
    });

    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        setState(() {
          _rawRecords = [];
          _allRecords = [];
          _employees = [];
          _displayedRecords = [];
          _isLoading = false;
          _hasMoreData = false;
        });
        return;
      }

      final empResponse = await Supabase.instance.client
          .from('employees')
          .select()
          .eq('user_id', session.user.id);

      _employees = (empResponse as List)
          .where((json) => json['deleted_at'] == null)
          .map((json) => HistoryEmployee(
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
          .eq('user_id', session.user.id);

      _rawRecords = (recResponse as List)
          .where((json) => json['deleted_at'] == null)
          .map((json) => HistoryWorkRecord(
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

      _applyFiltersAndLoad();

    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasMoreData = false;
      });
    }
  }

  void _applyFiltersAndLoad() {
    var filtered = List<HistoryWorkRecord>.from(_rawRecords);
    
    if (_searchQuery.isNotEmpty) {
      final searchLower = _searchQuery.toLowerCase();
      final employeeMap = {for (var e in _employees) e.id: e.name};
      
      filtered = filtered.where((record) {
        final employeeName = employeeMap[record.employeeId] ?? 'Unknown';
        final notesMatch = record.notes != null 
            ? record.notes!.toLowerCase().contains(searchLower)
            : false;
        return employeeName.toLowerCase().contains(searchLower) || notesMatch;
      }).toList();
    }
    
    if (_selectedEmployeeId != null) {
      filtered = filtered.where((record) => record.employeeId == _selectedEmployeeId).toList();
    }
    
    if (_startDate != null) {
      filtered = filtered.where((record) => 
        record.workDate.isAfter(_startDate!) || record.workDate.isAtSameMomentAs(_startDate!)
      ).toList();
    }
    
    if (_endDate != null) {
      filtered = filtered.where((record) => 
        record.workDate.isBefore(_endDate!) || record.workDate.isAtSameMomentAs(_endDate!)
      ).toList();
    }

    filtered.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'netPayCents':
          comparison = a.netPayCents.compareTo(b.netPayCents);
          break;
        case 'totalMinutes':
          comparison = a.totalMinutes.compareTo(b.totalMinutes);
          break;
        case 'workDate':
        default:
          comparison = a.workDate.compareTo(b.workDate);
          break;
      }
      return _isAscending ? comparison : -comparison;
    });

    setState(() {
      _allRecords = filtered;
      _currentPage = 0;
      _displayedRecords = [];
      _hasMoreData = filtered.isNotEmpty;
      _loadPage();
    });
  }

  void _loadPage() {
    final start = _currentPage * _pageSize;
    if (start >= _allRecords.length) {
      setState(() {
        _hasMoreData = false;
        _isLoading = false;
        _isLoadingMore = false;
      });
      return;
    }

    final end = (start + _pageSize) > _allRecords.length 
        ? _allRecords.length 
        : start + _pageSize;

    final newRecords = _allRecords.sublist(start, end);
    
    setState(() {
      _displayedRecords.addAll(newRecords);
      _currentPage++;
      _hasMoreData = end < _allRecords.length;
      _isLoading = false;
      _isLoadingMore = false;
    });
  }

  void _loadMore() {
    if (_isLoadingMore || !_hasMoreData || _isLoading) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _loadPage();
      }
    });
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  Future<void> _editRecord(HistoryWorkRecord record) async {
    final result = await Navigator.pushNamed(
      context,
      '/main',
      arguments: {
        'mode': 'edit',
        'recordId': record.id,
        'employeeId': record.employeeId,
        'workDate': record.workDate,
        'startTime': record.startTime,
        'endTime': record.endTime,
        'breakMinutes': record.breakMinutes,
        'overtimeMode': record.overtimeMode,
        'regularMinutes': record.regularMinutes,
        'overtimeMinutes': record.overtimeMinutes,
        'hourlyRateCents': record.hourlyRateCents,
        'overtimeRateCents': record.overtimeRateCents,
        'bonusCents': record.bonusCents,
        'deductionsCents': record.deductionsCents,
        'notes': record.notes,
      },
    );
    
    if (result == true && mounted) {
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!_isLoading) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_allRecords.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortDialog,
            tooltip: 'Sort',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
            tooltip: 'Search',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    final filtered = _displayedRecords;
    
    if (filtered.isEmpty && !_isLoading) {
      return _buildEmptyState();
    }
    
    final employeeMap = {for (var e in _employees) e.id: e.name};
    
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: filtered.length + (_hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == filtered.length) {
            return _buildLoadMoreIndicator();
          }
          
          final record = filtered[index];
          final employeeName = employeeMap[record.employeeId] ?? 'Unknown';
          
          return WorkRecordCard(
            record: record,
            employeeName: employeeName,
            onEdit: () {
              _editRecord(record);
            },
            onDelete: () {
              _showDeleteConfirmation(record);
            },
            onDuplicate: () {
              _duplicateRecord(record);
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: _isLoadingMore
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Loading more records...', style: TextStyle(color: Colors.grey)),
                ],
              )
            : TextButton.icon(
                onPressed: _loadMore,
                icon: const Icon(Icons.expand_more),
                label: const Text('Load More Records'),
              ),
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
              Icons.history,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _selectedEmployeeId != null
                ? 'No matching records found'
                : 'No Work Records',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _selectedEmployeeId != null
                ? 'Try adjusting your search or filters'
                : 'Your work history will appear here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          if (_searchQuery.isNotEmpty || _selectedEmployeeId != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _selectedEmployeeId = null;
                  _startDate = null;
                  _endDate = null;
                  _applyFiltersAndLoad();
                });
              },
              child: const Text('Clear Filters'),
            ),
          ],
        ],
      ),
    );
  }

  // ✅ SORT DIALOG MATCHING EMPLOYEES LAYOUT
  void _showSortDialog() {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          final primaryColor = Theme.of(context).colorScheme.primary;

          final sortOptions = [
            {'label': 'Work Date', 'icon': Icons.calendar_today, 'subtitle': 'Chronological order'},
            {'label': 'Net Pay', 'icon': Icons.attach_money, 'subtitle': 'Highest to lowest pay'},
            {'label': 'Total Hours', 'icon': Icons.access_time, 'subtitle': 'Hours worked'},
          ];

          return SafeArea(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle Indicator
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Header Title
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.sort, color: primaryColor),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Sort Records',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Options Title
                    const Text(
                      'SORT BY',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // List of Options
                    ...sortOptions.map((opt) {
                      final isSelected = _sortBy == opt['label'];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: InkWell(
                          onTap: () {
                            String sortKey;
                            switch (opt['label']) {
                              case 'Net Pay':
                                sortKey = 'netPayCents';
                                break;
                              case 'Total Hours':
                                sortKey = 'totalMinutes';
                                break;
                              case 'Work Date':
                              default:
                                sortKey = 'workDate';
                                break;
                            }
                            setState(() {
                              _sortBy = sortKey;
                            });
                            setModalState(() {});
                            _applyFiltersAndLoad();
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? primaryColor.withValues(alpha: 0.08) : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? primaryColor : Colors.grey.shade200,
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  opt['icon'] as IconData,
                                  size: 20,
                                  color: isSelected ? primaryColor : Colors.grey.shade600,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        opt['label'] as String,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                          color: isSelected ? primaryColor : Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        opt['subtitle'] as String,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(Icons.check_circle, color: primaryColor, size: 18),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 12),

                    // Order Heading
                    const Text(
                      'ORDER',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),

                    InkWell(
                      onTap: () {
                        setState(() {
                          _isAscending = !_isAscending;
                        });
                        setModalState(() {});
                        _applyFiltersAndLoad();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                              color: primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _isAscending
                                    ? 'Ascending (A-Z / Low to High)'
                                    : 'Descending (Z-A / High to Low)',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ),
                            Switch.adaptive(
                              value: _isAscending,
                              activeThumbColor: primaryColor,
                              onChanged: (val) {
                                setState(() {
                                  _isAscending = val;
                                });
                                setModalState(() {});
                                _applyFiltersAndLoad();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Primary Close Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

  // ✅ FILTER DIALOG MATCHING EMPLOYEES LAYOUT
  void _showFilterDialog() {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setStateBottomSheet) {
          final primaryColor = Theme.of(context).colorScheme.primary;
          
          return SafeArea(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle Indicator
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Header Title
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.filter_list, color: primaryColor),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Filter Records',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Records per page
                    const Text(
                      'RECORDS PER PAGE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Items per chunk',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          SegmentedButton<int>(
                            segments: const [
                              ButtonSegment(value: 5, label: Text('5')),
                              ButtonSegment(value: 10, label: Text('10')),
                              ButtonSegment(value: 20, label: Text('20')),
                            ],
                            selected: {_pageSize},
                            onSelectionChanged: (Set<int> newSelection) {
                              final selectedSize = newSelection.first;
                              setStateBottomSheet(() {
                                _pageSize = selectedSize;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Employee filter
                    const Text(
                      'EMPLOYEE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedEmployeeId,
                        decoration: const InputDecoration(
                          labelText: 'Select Employee',
                          labelStyle: TextStyle(fontSize: 12, color: Colors.grey),
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.person, color: Colors.blue, size: 20),
                        ),
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                        dropdownColor: Colors.white,
                        iconEnabledColor: Colors.blue,
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
                          setStateBottomSheet(() {
                            _selectedEmployeeId = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Date range
                    const Text(
                      'DATE RANGE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _startDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setStateBottomSheet(() {
                                  _startDate = date;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today, color: primaryColor, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _startDate != null 
                                          ? DateFormat('dd MMM yyyy').format(_startDate!)
                                          : 'Start Date',
                                      style: TextStyle(
                                        color: _startDate != null ? Colors.black87 : Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _endDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setStateBottomSheet(() {
                                  _endDate = date;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today, color: primaryColor, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _endDate != null 
                                          ? DateFormat('dd MMM yyyy').format(_endDate!)
                                          : 'End Date',
                                      style: TextStyle(
                                        color: _endDate != null ? Colors.black87 : Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedEmployeeId = null;
                                  _startDate = null;
                                  _endDate = null;
                                  _applyFiltersAndLoad();
                                });
                                Navigator.pop(context);
                              },
                              child: const Text('Clear All'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  _applyFiltersAndLoad();
                                });
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Apply Filters',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Records'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search by employee or notes...',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
              _applyFiltersAndLoad();
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _applyFiltersAndLoad();
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(HistoryWorkRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text(
          'Are you sure you want to delete this work record? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await Supabase.instance.client
                    .from('work_records')
                    .update({'deleted_at': DateTime.now().toIso8601String()})
                    .eq('id', record.id);
                
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Record deleted')),
                  );
                  await _loadData();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting record: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _duplicateRecord(HistoryWorkRecord record) {
    final duplicated = record.copyWith(
      id: const Uuid().v4(),
      workDate: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Duplicating record...')),
    );
    
    Supabase.instance.client.from('work_records').insert({
      'id': duplicated.id,
      'user_id': duplicated.userId,
      'employee_id': duplicated.employeeId,
      'work_date': duplicated.workDate.toIso8601String().split('T')[0],
      'start_time': duplicated.startTime,
      'end_time': duplicated.endTime,
      'break_minutes': duplicated.breakMinutes,
      'overtime_mode': duplicated.overtimeMode,
      'regular_minutes': duplicated.regularMinutes,
      'overtime_minutes': duplicated.overtimeMinutes,
      'total_minutes': duplicated.totalMinutes,
      'hourly_rate_cents': duplicated.hourlyRateCents,
      'overtime_rate_cents': duplicated.overtimeRateCents,
      'bonus_cents': duplicated.bonusCents,
      'deductions_cents': duplicated.deductionsCents,
      'regular_pay_cents': duplicated.regularPayCents,
      'overtime_pay_cents': duplicated.overtimePayCents,
      'gross_pay_cents': duplicated.grossPayCents,
      'net_pay_cents': duplicated.netPayCents,
      'notes': duplicated.notes,
      'created_at': duplicated.createdAt.toIso8601String(),
      'updated_at': duplicated.updatedAt.toIso8601String(),
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Record duplicated successfully!')),
      );
      _loadData();
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error duplicating record: $e')),
      );
    });
  }
}