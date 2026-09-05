import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Simple Employee class
class ScreenEmployee {
  final String id;
  final String userId;
  final String name;
  final int hourlyRateCents;
  final int overtimeRateCents;
  final double overtimeMultiplier;
  final String? notes;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  
  ScreenEmployee({
    required this.id,
    required this.userId,
    required this.name,
    required this.hourlyRateCents,
    required this.overtimeRateCents,
    required this.overtimeMultiplier,
    this.notes,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  
  ScreenEmployee copyWith({
    String? id,
    String? userId,
    String? name,
    int? hourlyRateCents,
    int? overtimeRateCents,
    double? overtimeMultiplier,
    String? notes,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return ScreenEmployee(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      hourlyRateCents: hourlyRateCents ?? this.hourlyRateCents,
      overtimeRateCents: overtimeRateCents ?? this.overtimeRateCents,
      overtimeMultiplier: overtimeMultiplier ?? this.overtimeMultiplier,
      notes: notes ?? this.notes,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}

// Simple Money Utils
class ScreenMoneyUtils {
  static String formatCurrency(int cents, {String currencySymbol = '£'}) {
    final pounds = cents / 100;
    return '$currencySymbol${pounds.toStringAsFixed(2)}';
  }
}

// Employee Repository
class EmployeeRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  Future<List<ScreenEmployee>> getEmployees(String userId) async {
    try {
      final List<dynamic> response = await _supabase
          .from('employees')
          .select()
          .eq('user_id', userId)
          .isFilter('deleted_at', null);
      
      return response
          .map((json) => ScreenEmployee(
            id: json['id'],
            userId: json['user_id'],
            name: json['name'],
            hourlyRateCents: json['hourly_rate_cents'],
            overtimeRateCents: json['overtime_rate_cents'],
            overtimeMultiplier: (json['overtime_multiplier'] as num).toDouble(),
            notes: json['notes'],
            active: json['active'],
            createdAt: DateTime.parse(json['created_at']),
            updatedAt: DateTime.parse(json['updated_at']),
            deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
          ))
          .toList();
    } catch (e) {
      return [];
    }
  }
  
  Future<void> addEmployee(ScreenEmployee employee) async {
    await _supabase.from('employees').insert({
      'id': employee.id,
      'user_id': employee.userId,
      'name': employee.name,
      'hourly_rate_cents': employee.hourlyRateCents,
      'overtime_rate_cents': employee.overtimeRateCents,
      'overtime_multiplier': employee.overtimeMultiplier,
      'notes': employee.notes,
      'active': employee.active,
    });
  }
  
  Future<void> updateEmployee(ScreenEmployee employee) async {
    await _supabase
        .from('employees')
        .update({
          'name': employee.name,
          'hourly_rate_cents': employee.hourlyRateCents,
          'overtime_rate_cents': employee.overtimeRateCents,
          'overtime_multiplier': employee.overtimeMultiplier,
          'notes': employee.notes,
          'active': employee.active,
        })
        .eq('id', employee.id);
  }
  
  Future<void> deleteEmployee(String id) async {
    await _supabase
        .from('employees')
        .update({'deleted_at': DateTime.now().toIso8601String()})
        .eq('id', id);
  }
  
  Future<bool> hasWorkRecords(String employeeId) async {
    try {
      final List<dynamic> response = await _supabase
          .from('work_records')
          .select('id')
          .eq('employee_id', employeeId)
          .isFilter('deleted_at', null)
          .limit(1);
      
      return response.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  Future<int> getWorkRecordsCount(String employeeId) async {
    try {
      final List<dynamic> response = await _supabase
          .from('work_records')
          .select('id')
          .eq('employee_id', employeeId)
          .isFilter('deleted_at', null);
      
      return response.length;
    } catch (e) {
      return 0;
    }
  }
}

// Employee Form Dialog
class EmployeeFormDialog extends StatefulWidget {
  final ScreenEmployee? initialEmployee;
  final Function(Map<String, dynamic>) onSave;
  
  const EmployeeFormDialog({
    super.key,
    this.initialEmployee,
    required this.onSave,
  });

  @override
  State<EmployeeFormDialog> createState() => _EmployeeFormDialogState();
}

class _EmployeeFormDialogState extends State<EmployeeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _overtimeRateController = TextEditingController();
  final _overtimeMultiplierController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmployee != null) {
      _nameController.text = widget.initialEmployee!.name;
      _hourlyRateController.text = 
          (widget.initialEmployee!.hourlyRateCents / 100).toStringAsFixed(2);
      _overtimeRateController.text = 
          (widget.initialEmployee!.overtimeRateCents / 100).toStringAsFixed(2);
      _overtimeMultiplierController.text = 
          widget.initialEmployee!.overtimeMultiplier.toString();
      _notesController.text = widget.initialEmployee!.notes ?? '';
      _isActive = widget.initialEmployee!.active;
    } else {
      _hourlyRateController.text = '12.00';
      _overtimeRateController.text = '18.00';
      _overtimeMultiplierController.text = '1.5';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hourlyRateController.dispose();
    _overtimeRateController.dispose();
    _overtimeMultiplierController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final data = {
        'name': _nameController.text.trim(),
        'hourlyRateCents': (double.parse(_hourlyRateController.text) * 100).round(),
        'overtimeRateCents': (double.parse(_overtimeRateController.text) * 100).round(),
        'overtimeMultiplier': double.parse(_overtimeMultiplierController.text),
        'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        'active': _isActive,
      };
      
      await widget.onSave(data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initialEmployee == null ? 'Add Employee' : 'Edit Employee',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _hourlyRateController,
                decoration: const InputDecoration(
                  labelText: 'Hourly Rate (£) *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.currency_pound),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter hourly rate';
                  }
                  try {
                    final rate = double.parse(value);
                    if (rate < 0) return 'Rate cannot be negative';
                    return null;
                  } catch (_) {
                    return 'Invalid rate';
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _overtimeRateController,
                decoration: const InputDecoration(
                  labelText: 'Overtime Rate (£) *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.currency_pound),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter overtime rate';
                  }
                  try {
                    final rate = double.parse(value);
                    if (rate < 0) return 'Rate cannot be negative';
                    return null;
                  } catch (_) {
                    return 'Invalid rate';
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _overtimeMultiplierController,
                decoration: const InputDecoration(
                  labelText: 'Overtime Multiplier *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calculate),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter overtime multiplier';
                  }
                  try {
                    final multiplier = double.parse(value);
                    if (multiplier < 0) return 'Multiplier cannot be negative';
                    return null;
                  } catch (_) {
                    return 'Invalid multiplier';
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Active'),
                subtitle: Text(_isActive ? 'Employee is active' : 'Employee is inactive'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}

class EmployeesScreen extends ConsumerStatefulWidget {
  const EmployeesScreen({super.key});

  @override
  ConsumerState<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends ConsumerState<EmployeesScreen> {
  // Search & Filter Settings
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'All'; // 'All', 'Active', 'Inactive'
  double? _minHourlyRate;
  double? _maxHourlyRate;
  
  // Sorting Settings
  String _sortBy = 'Name'; // Options: 'Name', 'Hourly Rate', 'Date Created'
  bool _sortAscending = true;
  
  // Dynamic Pagination Settings
  int _pageSize = 5; // Per record chunk limit
  int _currentPage = 0;
  
  List<ScreenEmployee> _rawEmployees = [];
  List<ScreenEmployee> _filteredEmployees = [];
  List<ScreenEmployee> _displayedEmployees = [];
  
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  bool _hasError = false;
  String _errorMessage = '';
  
  final EmployeeRepository _repository = EmployeeRepository();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadEmployees();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
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

  Future<void> _loadEmployees() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
      _currentPage = 0;
      _displayedEmployees = [];
      _hasMoreData = true;
    });

    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        setState(() {
          _isLoading = false;
          _rawEmployees = [];
          _filteredEmployees = [];
          _displayedEmployees = [];
          _hasMoreData = false;
        });
        return;
      }

      _rawEmployees = await _repository.getEmployees(session.user.id);
      _applyFiltersAndLoad();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
        _hasMoreData = false;
      });
    }
  }

  void _applyFiltersAndLoad() {
    var filtered = List<ScreenEmployee>.from(_rawEmployees);
    
    // 1. Text Search Filter (Name/Notes)
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((e) {
        final nameMatch = e.name.toLowerCase().contains(query);
        final notesMatch = e.notes?.toLowerCase().contains(query) ?? false;
        return nameMatch || notesMatch;
      }).toList();
    }

    // 2. Active Status Filter
    if (_statusFilter == 'Active') {
      filtered = filtered.where((e) => e.active).toList();
    } else if (_statusFilter == 'Inactive') {
      filtered = filtered.where((e) => !e.active).toList();
    }

    // 3. Hourly Rate Range Filter
    if (_minHourlyRate != null) {
      filtered = filtered.where((e) => (e.hourlyRateCents / 100) >= _minHourlyRate!).toList();
    }
    if (_maxHourlyRate != null) {
      filtered = filtered.where((e) => (e.hourlyRateCents / 100) <= _maxHourlyRate!).toList();
    }

    // 4. Sorting Logic
    filtered.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'Hourly Rate':
          comparison = a.hourlyRateCents.compareTo(b.hourlyRateCents);
          break;
        case 'Date Created':
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case 'Name':
        default:
          comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    setState(() {
      _filteredEmployees = filtered;
      _currentPage = 0;
      _displayedEmployees = [];
      _hasMoreData = filtered.isNotEmpty;
      _loadPage();
    });
  }

  void _loadPage() {
    final start = _currentPage * _pageSize;
    if (start >= _filteredEmployees.length) {
      setState(() {
        _hasMoreData = false;
        _isLoading = false;
        _isLoadingMore = false;
      });
      return;
    }

    final end = (start + _pageSize) > _filteredEmployees.length 
        ? _filteredEmployees.length 
        : start + _pageSize;

    final newItems = _filteredEmployees.sublist(start, end);
    
    setState(() {
      _displayedEmployees.addAll(newItems);
      _currentPage++;
      _hasMoreData = end < _filteredEmployees.length;
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

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _statusFilter = 'All';
      _minHourlyRate = null;
      _maxHourlyRate = null;
      _sortBy = 'Name';
      _sortAscending = true;
      _applyFiltersAndLoad();
    });
  }

  bool get _hasActiveFilters {
    return _searchQuery.isNotEmpty || 
           _statusFilter != 'All' || 
           _minHourlyRate != null || 
           _maxHourlyRate != null;
  }

  // Fully visible, overflow-protected Sort Modal BottomSheet
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
              {'label': 'Name', 'icon': Icons.person, 'subtitle': 'Alphabetical order'},
              {'label': 'Hourly Rate', 'icon': Icons.payments, 'subtitle': 'Pay rate amounts'},
              {'label': 'Date Created', 'icon': Icons.calendar_today, 'subtitle': 'Creation timeline'},
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
                            'Sort Employees',
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
                              setState(() {
                                _sortBy = opt['label'] as String;
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
                            _sortAscending = !_sortAscending;
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
                                _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                                color: primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _sortAscending
                                      ? 'Ascending (A-Z / Low to High)'
                                      : 'Descending (Z-A / High to Low)',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                              ),
                              Switch.adaptive(
                                value: _sortAscending,
                                activeThumbColor: primaryColor,
                                onChanged: (val) {
                                  setState(() {
                                    _sortAscending = val;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Employees',
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
                '${_filteredEmployees.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.sort),
              tooltip: 'Sort Employees',
              onPressed: _showSortDialog,
            ),
          ],
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: _hasActiveFilters ? Colors.orangeAccent : Colors.white,
            ),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEmployees,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Employee',
            onPressed: _showAddEmployeeDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search employee name or notes...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                            _applyFiltersAndLoad();
                          });
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _applyFiltersAndLoad();
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: _hasActiveFilters 
                  ? Theme.of(context).colorScheme.primary 
                  : Colors.white,
              foregroundColor: _hasActiveFilters 
                  ? Colors.white 
                  : Colors.grey.shade700,
            ),
            icon: const Icon(Icons.tune),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading employees',
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
              onPressed: _loadEmployees,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final filtered = _displayedEmployees;
    
    if (filtered.isEmpty) {
      return _buildEmptyState();
    }
    
    return RefreshIndicator(
      onRefresh: _loadEmployees,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: filtered.length + (_hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == filtered.length) {
            return _buildLoadMoreIndicator();
          }
          final employee = filtered[index];
          return _buildEmployeeCard(employee);
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
                  Text('Loading more employees...', style: TextStyle(color: Colors.grey)),
                ],
              )
            : TextButton.icon(
                onPressed: _loadMore,
                icon: const Icon(Icons.expand_more),
                label: const Text('Load More Employees'),
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
              Icons.people_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _hasActiveFilters ? 'No matching employees' : 'No Employees Yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _hasActiveFilters 
                ? 'Try tweaking your search terms or filter criteria' 
                : 'Add your first employee to start tracking wages',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          if (_hasActiveFilters)
            OutlinedButton.icon(
              onPressed: _resetFilters,
              icon: const Icon(Icons.filter_alt_off),
              label: const Text('Reset Filters'),
            )
          else
            ElevatedButton.icon(
              onPressed: _showAddEmployeeDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Employee'),
            ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(ScreenEmployee employee) {
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
              employee.name.isNotEmpty ? employee.name[0].toUpperCase() : '?',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            employee.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            employee.active ? 'Active' : 'Inactive',
            style: TextStyle(
              color: employee.active ? Colors.green.shade700 : Colors.red.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  ScreenMoneyUtils.formatCurrency(employee.hourlyRateCents),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green.shade700,
                  ),
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
                      _showEditEmployeeDialog(employee);
                      break;
                    case 'delete':
                      _showDeleteConfirmation(employee);
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
                  _buildDetailRow(
                    'Hourly Rate', 
                    ScreenMoneyUtils.formatCurrency(employee.hourlyRateCents), 
                    icon: Icons.currency_pound, 
                    iconColor: Colors.green,
                    bold: true,
                  ),
                  _buildDetailRow(
                    'Overtime Rate', 
                    ScreenMoneyUtils.formatCurrency(employee.overtimeRateCents), 
                    icon: Icons.currency_pound, 
                    iconColor: Colors.orange,
                  ),
                  _buildDetailRow(
                    'Overtime Multiplier', 
                    '${employee.overtimeMultiplier}x', 
                    icon: Icons.calculate, 
                    iconColor: Colors.blue,
                  ),
                  if (employee.notes != null && employee.notes!.isNotEmpty) ...[
                    const Divider(color: Colors.blue, thickness: 1),
                    _buildDetailRow(
                      'Notes', 
                      employee.notes!, 
                      icon: Icons.note, 
                      iconColor: Colors.grey,
                    ),
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
                              'Standard Rate',
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                            ),
                            Text(
                              ScreenMoneyUtils.formatCurrency(employee.hourlyRateCents),
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
                              'OT Rate',
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                            ),
                            Text(
                              ScreenMoneyUtils.formatCurrency(employee.overtimeRateCents),
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

  // Multi-Criteria Filter Dialog
  // Beautiful Filter Dialog matching Sort Dialog layout
void _showFilterDialog() {
  String tempStatus = _statusFilter;
  int tempPageSize = _pageSize;

  final minRateController = TextEditingController(
    text: _minHourlyRate?.toString() ?? '',
  );
  final maxRateController = TextEditingController(
    text: _maxHourlyRate?.toString() ?? '',
  );

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
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
                          'Filter Employees',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Status Section
                    const Text(
                      'STATUS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: ['All', 'Active', 'Inactive'].map((status) {
                          final isSelected = tempStatus == status;
                          return ChoiceChip(
                            label: Text(status),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setModalState(() {
                                  tempStatus = status;
                                });
                              }
                            },
                            selectedColor: primaryColor,
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey.shade700,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            side: BorderSide(
                              color: isSelected ? primaryColor : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Hourly Rate Section
                    const Text(
                      'HOURLY RATE (£)',
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
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: TextField(
                              controller: minRateController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                hintText: 'Min Rate',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                prefixIcon: Icon(Icons.arrow_upward, size: 18, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: TextField(
                              controller: maxRateController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                hintText: 'Max Rate',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                prefixIcon: Icon(Icons.arrow_downward, size: 18, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Records Per Page Section - FIXED
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
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.list_rounded, size: 18, color: Colors.grey.shade600),
                              const SizedBox(width: 8),
                              const Text(
                                'Record Per Page',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '$tempPageSize items',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Use Wrap for better responsiveness
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [5, 10, 20, 50].map((size) {
                              final isSelected = tempPageSize == size;
                              return GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    tempPageSize = size;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected ? primaryColor : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected ? primaryColor : Colors.grey.shade300,
                                      width: 2,
                                    ),
                                    boxShadow: isSelected ? [
                                      BoxShadow(
                                        color: primaryColor.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ] : null,
                                  ),
                                  child: Text(
                                    '$size',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? Colors.white : Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Action Buttons
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
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              onPressed: () {
                                _resetFilters();
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Reset All',
                                style: TextStyle(color: Colors.red),
                              ),
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
                                  _statusFilter = tempStatus;
                                  _pageSize = tempPageSize;
                                  _minHourlyRate = double.tryParse(minRateController.text);
                                  _maxHourlyRate = double.tryParse(maxRateController.text);
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
                    const SizedBox(height: 8),
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

  void _showAddEmployeeDialog() {
    showDialog(
      context: context,
      builder: (context) => EmployeeFormDialog(
        onSave: (employeeData) async {
          try {
            final session = Supabase.instance.client.auth.currentSession;
            if (session == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please login first')),
              );
              return;
            }

            final employee = ScreenEmployee(
              id: const Uuid().v4(),
              userId: session.user.id,
              name: employeeData['name'],
              hourlyRateCents: employeeData['hourlyRateCents'],
              overtimeRateCents: employeeData['overtimeRateCents'],
              overtimeMultiplier: employeeData['overtimeMultiplier'],
              notes: employeeData['notes'],
              active: true,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
            
            await _repository.addEmployee(employee);
            
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Employee added successfully')),
              );
              await _loadEmployees();
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to add employee: $e')),
              );
            }
          }
        },
      ),
    );
  }

  void _showEditEmployeeDialog(ScreenEmployee employee) {
    showDialog(
      context: context,
      builder: (context) => EmployeeFormDialog(
        initialEmployee: employee,
        onSave: (employeeData) async {
          try {
            final updatedEmployee = employee.copyWith(
              name: employeeData['name'],
              hourlyRateCents: employeeData['hourlyRateCents'],
              overtimeRateCents: employeeData['overtimeRateCents'],
              overtimeMultiplier: employeeData['overtimeMultiplier'],
              notes: employeeData['notes'],
              active: employeeData['active'],
              updatedAt: DateTime.now(),
            );
            
            await _repository.updateEmployee(updatedEmployee);
            
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Employee updated successfully')),
              );
              await _loadEmployees();
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to update employee: $e')),
              );
            }
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(ScreenEmployee employee) async {
    final hasRecords = await _repository.hasWorkRecords(employee.id);
    
    if (hasRecords) {
      final count = await _repository.getWorkRecordsCount(employee.id);
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Cannot Delete ${employee.name}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${employee.name} has $count work record${count > 1 ? 's' : ''} associated with them.',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'You cannot delete this employee because they have existing work records.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'What would you like to do?',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.radio_button_checked, size: 14, color: Colors.blue),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text('Deactivate the employee (set Active = false)'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.radio_button_checked, size: 14, color: Colors.red),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text('Delete all associated work records first'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showEditEmployeeDialog(employee);
                },
                icon: const Icon(Icons.person_off, size: 16),
                label: const Text('Deactivate'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      }
      return;
    }

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Employee'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to delete "${employee.name}"?',
                ),
                const SizedBox(height: 8),
                Text(
                  'This employee has no work records and can be safely deleted.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _repository.deleteEmployee(employee.id);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Employee deleted successfully')),
                    );
                    await _loadEmployees();
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to delete employee: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    }
  }
}