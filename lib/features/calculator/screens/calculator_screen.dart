import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

// Simple Employee class for calculator
class CalcEmployee {
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
  
  CalcEmployee({
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
}

// Simple Money Utils
class CalcMoneyUtils {
  static String formatCurrency(int cents, {String currencySymbol = '£'}) {
    final pounds = cents / 100;
    return '$currencySymbol${pounds.toStringAsFixed(2)}';
  }
  
  static int poundsToCents(double pounds) {
    return (pounds * 100).round();
  }
  
  static int? parseCurrencyToCents(String value) {
    final cleaned = value.replaceAll('£', '').replaceAll(',', '').trim();
    if (cleaned.isEmpty) return null;
    try {
      final pounds = double.parse(cleaned);
      return poundsToCents(pounds);
    } catch (_) {
      return null;
    }
  }
  
  static String formatAmountWithTwoDecimals(String input) {
    if (input.isEmpty) return '';
    String cleaned = input.replaceAll(RegExp(r'[^0-9.]'), '');
    if (cleaned.isEmpty) return '';
    final double value = double.tryParse(cleaned) ?? 0;
    return value.toStringAsFixed(2);
  }
  
  static String formatAmountFromDigits(String input) {
    String digits = input.replaceAll(RegExp(r'[^0-9.]'), '');
    if (digits.isEmpty) return '';
    if (digits.contains('.')) {
      final parts = digits.split('.');
      if (parts.length > 2) {
        digits = '${parts[0]}.${parts[1]}';
      }
      if (parts.length == 2 && parts[1].length > 2) {
        digits = '${parts[0]}.${parts[1].substring(0, 2)}';
      }
      final totalDigits = digits.replaceAll('.', '').length;
      if (totalDigits > 10) {
        final allDigits = digits.replaceAll('.', '');
        final limited = allDigits.substring(0, 10);
        final intPart = parts[0];
        if (limited.length <= intPart.length) {
          digits = limited;
        } else {
          final decPart = limited.substring(intPart.length);
          digits = '$intPart.$decPart';
        }
      }
      return digits;
    }
    if (digits.isNotEmpty) {
      if (digits.length > 10) {
        digits = digits.substring(0, 10);
      }
      return digits;
    }
    return '';
  }
  
  static int parseFormattedAmountToCents(String formatted) {
    if (formatted.isEmpty) return 0;
    final cleaned = formatted.replaceAll(RegExp(r'[^0-9.]'), '');
    if (cleaned.isEmpty) return 0;
    final double value = double.tryParse(cleaned) ?? 0;
    return (value * 100).round();
  }
  
  static bool isValidAmount(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length <= 10;
  }
}

// Simple Time Utils
class CalcTimeUtils {
  static int timeToMinutes(String time) {
    final parts = time.split(':');
    if (parts.length != 2) throw FormatException('Invalid time format');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    if (hours < 0 || hours > 23 || minutes < 0 || minutes > 59) {
      throw FormatException('Invalid time values');
    }
    return hours * 60 + minutes;
  }
  
  static String formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours == 0) return '${mins}m';
    if (mins == 0) return '${hours}h';
    return '${hours}h ${mins}m';
  }
  
  static bool isValidTimeFormat(String time) {
    final pattern = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    return pattern.hasMatch(time);
  }
  
  static String formatTimeFromDigits(String input) {
    String digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';
    if (digits.length <= 2) {
      int hours = int.parse(digits);
      if (hours > 23) hours = 23;
      return '${hours.toString().padLeft(2, '0')}:00';
    }
    if (digits.length == 3) {
      int hours = int.parse(digits.substring(0, 2));
      if (hours > 23) hours = 23;
      int minutes = int.parse(digits.substring(2, 3));
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    }
    if (digits.length >= 4) {
      int hours = int.parse(digits.substring(0, 2));
      if (hours > 23) hours = 23;
      int minutes = int.parse(digits.substring(2, 4));
      if (minutes > 59) minutes = 59;
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    }
    return '';
  }
}

// Simple App Constants
class CalcAppConstants {
  static const String appName = 'WAGES';
  static const String appVersion = '1.0.0';
  static const String overtimeAutomatic = 'automatic';
  static const String overtimeManual = 'manual';
  static const String overtimeNone = 'none';
  static const int defaultRegularThresholdMinutes = 480;
  static const int defaultBreakMinutes = 30;
  static const int defaultHourlyRateCents = 1200;
}

// CURRENCY INPUT FORMATTER - Max 10 digits with 2 decimal places
class CurrencyTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.replaceAll(RegExp(r'[^0-9.]'), '');
    if (text.split('.').length > 2) return oldValue;
    if (text.contains('.')) {
      final parts = text.split('.');
      if (parts[1].length > 2) return oldValue;
    }
    final digits = text.replaceAll('.', '');
    if (digits.length > 10) return oldValue;
    return newValue;
  }
}

// Calculation Service
class CalculationService {
  (int regularMinutes, int overtimeMinutes) calculateAutomaticOvertime(
    int totalMinutes,
    int regularThresholdMinutes,
  ) {
    if (totalMinutes <= regularThresholdMinutes) {
      return (totalMinutes, 0);
    }
    return (regularThresholdMinutes, totalMinutes - regularThresholdMinutes);
  }
  
  CalculationResult calculateShift({
    required int startMinutes,
    required int endMinutes,
    required int breakMinutes,
    required int hourlyRateCents,
    required int overtimeRateCents,
    required int bonusCents,
    required int deductionsCents,
    required String overtimeMode,
    int? regularThresholdMinutes,
    int? manualRegularMinutes,
    int? manualOvertimeMinutes,
  }) {
    int rawDuration;
    if (endMinutes <= startMinutes) {
      rawDuration = endMinutes + 1440 - startMinutes;
    } else {
      rawDuration = endMinutes - startMinutes;
    }
    if (breakMinutes < 0 || breakMinutes > rawDuration) {
      throw Exception('Invalid break duration');
    }
    final shiftDurationMinutes = rawDuration - breakMinutes;
    int totalMinutes;
    int regularMinutes;
    int overtimeMinutes;
    switch (overtimeMode) {
      case 'automatic':
        totalMinutes = shiftDurationMinutes;
        final threshold = regularThresholdMinutes ?? 480;
        final result = calculateAutomaticOvertime(totalMinutes, threshold);
        regularMinutes = result.$1;
        overtimeMinutes = result.$2;
        break;
      case 'manual':
        regularMinutes = manualRegularMinutes ?? 0;
        overtimeMinutes = manualOvertimeMinutes ?? 0;
        totalMinutes = regularMinutes + overtimeMinutes;
        break;
      case 'none':
      default:
        totalMinutes = shiftDurationMinutes;
        regularMinutes = totalMinutes;
        overtimeMinutes = 0;
        break;
    }
    final regularPay = ((regularMinutes * hourlyRateCents) / 60).round();
    final overtimePay = ((overtimeMinutes * overtimeRateCents) / 60).round();
    final grossPay = regularPay + overtimePay + bonusCents;
    final netPay = grossPay - deductionsCents;
    return CalculationResult(
      totalMinutes: totalMinutes,
      regularMinutes: regularMinutes,
      overtimeMinutes: overtimeMinutes,
      regularPayCents: regularPay,
      overtimePayCents: overtimePay,
      grossPayCents: grossPay,
      netPayCents: netPay,
      bonusCents: bonusCents,
      deductionsCents: deductionsCents,
    );
  }
}

class CalculationResult {
  final int totalMinutes;
  final int regularMinutes;
  final int overtimeMinutes;
  final int regularPayCents;
  final int overtimePayCents;
  final int grossPayCents;
  final int netPayCents;
  final int bonusCents;
  final int deductionsCents;
  
  CalculationResult({
    required this.totalMinutes,
    required this.regularMinutes,
    required this.overtimeMinutes,
    required this.regularPayCents,
    required this.overtimePayCents,
    required this.grossPayCents,
    required this.netPayCents,
    required this.bonusCents,
    required this.deductionsCents,
  });
}

class CalcLoadingWidget extends StatelessWidget {
  const CalcLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class CalculatorScreen extends ConsumerStatefulWidget {
  const CalculatorScreen({super.key});

  @override
  ConsumerState<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends ConsumerState<CalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _calculationService = CalculationService();
  bool _isDataLoaded = false; // Flag to prevent re-reading route arguments
  
  // Controllers
  final _employeeController = TextEditingController();
  final _dateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _breakController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _overtimeRateController = TextEditingController();
  final _bonusController = TextEditingController();
  final _deductionsController = TextEditingController();
  final _notesController = TextEditingController();
  
  // Manual overtime controllers
  final _manualRegularController = TextEditingController();
  final _manualOvertimeController = TextEditingController();
  
  // Focus Nodes
  final FocusNode _startTimeFocus = FocusNode();
  final FocusNode _endTimeFocus = FocusNode();
  final FocusNode _hourlyRateFocus = FocusNode();
  final FocusNode _overtimeRateFocus = FocusNode();
  final FocusNode _bonusFocus = FocusNode();
  final FocusNode _deductionsFocus = FocusNode();
  final FocusNode _manualRegularFocus = FocusNode();
  final FocusNode _manualOvertimeFocus = FocusNode();
  
  // State variables
  String _selectedEmployeeId = '';
  String _overtimeMode = CalcAppConstants.overtimeNone;
  int _regularMinutes = 0;
  int _overtimeMinutes = 0;
  int _totalMinutes = 0;
  int _regularPay = 0;
  int _overtimePay = 0;
  int _grossPay = 0;
  int _netPay = 0;
  int _bonus = 0;
  int _deductions = 0;
  DateTime _selectedDate = DateTime.now();
  String _startTime = '09:00';
  String _endTime = '17:00';
  int _breakMinutes = 0;
  int _hourlyRateCents = 1200;
  int _overtimeRateCents = 1800;
  
  // Manual overtime state
  int _manualRegularMinutes = 0;
  int _manualOvertimeMinutes = 0;
  
  // ✅ Edit Mode
  String? _editRecordId;
  bool _isEditMode = false;
  
  List<CalcEmployee> _employees = [];
  bool _isLoadingEmployees = true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setDefaultTimes();
    _loadEmployees();
    _calculate();
    
    _hourlyRateFocus.addListener(() {
      if (!_hourlyRateFocus.hasFocus && _hourlyRateController.text.isNotEmpty) {
        _formatCurrencyOnFocusLost(_hourlyRateController, (val) {
          _hourlyRateCents = CalcMoneyUtils.parseFormattedAmountToCents(val);
        });
      }
    });
    _overtimeRateFocus.addListener(() {
      if (!_overtimeRateFocus.hasFocus && _overtimeRateController.text.isNotEmpty) {
        _formatCurrencyOnFocusLost(_overtimeRateController, (val) {
          _overtimeRateCents = CalcMoneyUtils.parseFormattedAmountToCents(val);
        });
      }
    });
    _bonusFocus.addListener(() {
      if (!_bonusFocus.hasFocus && _bonusController.text.isNotEmpty) {
        _formatCurrencyOnFocusLost(_bonusController, (val) {
          _bonus = CalcMoneyUtils.parseFormattedAmountToCents(val);
        });
      }
    });
    _deductionsFocus.addListener(() {
      if (!_deductionsFocus.hasFocus && _deductionsController.text.isNotEmpty) {
        _formatCurrencyOnFocusLost(_deductionsController, (val) {
          _deductions = CalcMoneyUtils.parseFormattedAmountToCents(val);
        });
      }
    });
    _startTimeFocus.addListener(() {
      if (!_startTimeFocus.hasFocus && _startTimeController.text.isNotEmpty) {
        _formatTimeOnFocusLost(_startTimeController, (val) => _startTime = val);
      }
    });
    _endTimeFocus.addListener(() {
      if (!_endTimeFocus.hasFocus && _endTimeController.text.isNotEmpty) {
        _formatTimeOnFocusLost(_endTimeController, (val) => _endTime = val);
      }
    });
    _manualRegularFocus.addListener(() {
      if (!_manualRegularFocus.hasFocus && _manualRegularController.text.isNotEmpty) {
        _updateManualOvertime();
      }
    });
    _manualOvertimeFocus.addListener(() {
      if (!_manualOvertimeFocus.hasFocus && _manualOvertimeController.text.isNotEmpty) {
        _updateManualOvertime();
      }
    });
  }

  Future<void> _pickDate() async {
  final date = await showDatePicker(
    context: context,
    initialDate: _selectedDate,
    firstDate: DateTime(2020),
    lastDate: DateTime(2030), // Agay ki dates agar select karni hon[cite: 6]
  );
  
  if (date != null) {
    setState(() {
      _selectedDate = date;
      _dateController.text = DateFormat('dd-MM-yyyy').format(date); //[cite: 6]
    });
    _calculate(); //[cite: 6]
  }
}

  // ✅ Receive arguments for Edit Mode
  @override
void didChangeDependencies() {
  super.didChangeDependencies();
  
  // Is check say arguments sirf pehli baar load hon gay, date picker use karne par dubara override nahi hon gay
  if (!_isDataLoaded) {
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    
    if (arguments != null && arguments['mode'] == 'edit') {
      _isEditMode = true;
      _editRecordId = arguments['recordId'];
      
      _selectedEmployeeId = arguments['employeeId'] ?? '';
      _selectedDate = arguments['workDate'] ?? DateTime.now(); //
      _startTime = arguments['startTime'] ?? '09:00';
      _endTime = arguments['endTime'] ?? '17:00';
      _breakMinutes = arguments['breakMinutes'] ?? 0;
      _overtimeMode = arguments['overtimeMode'] ?? CalcAppConstants.overtimeNone;
      _regularMinutes = arguments['regularMinutes'] ?? 0;
      _overtimeMinutes = arguments['overtimeMinutes'] ?? 0;
      _hourlyRateCents = arguments['hourlyRateCents'] ?? 1200;
      _overtimeRateCents = arguments['overtimeRateCents'] ?? 1800;
      _bonus = arguments['bonusCents'] ?? 0;
      _deductions = arguments['deductionsCents'] ?? 0;
      _notesController.text = arguments['notes'] ?? '';
      
      _dateController.text = DateFormat('dd-MM-yyyy').format(_selectedDate); //
      _startTimeController.text = _startTime;
      _endTimeController.text = _endTime;
      _breakController.text = _breakMinutes.toString();
      _hourlyRateController.text = (_hourlyRateCents / 100).toStringAsFixed(2);
      _overtimeRateController.text = (_overtimeRateCents / 100).toStringAsFixed(2);
      _bonusController.text = (_bonus / 100).toStringAsFixed(2);
      _deductionsController.text = (_deductions / 100).toStringAsFixed(2);
      
      _calculate(); //[cite: 6]
    }
    _isDataLoaded = true; // Mark as loaded[cite: 6]
  }
}
  
  void _initializeControllers() {
    _dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    _breakController.text = '0';
    _bonusController.text = '0.00';
    _deductionsController.text = '0.00';
    _hourlyRateController.text = '12.00';
    _overtimeRateController.text = '18.00';
    _manualRegularController.text = '0';
    _manualOvertimeController.text = '0';
  }
  
  void _setDefaultTimes() {
    _startTime = '09:00';
    _endTime = '17:00';
    _breakMinutes = 0;
    _startTimeController.text = _startTime;
    _endTimeController.text = _endTime;
  }

  @override
  void dispose() {
    _employeeController.dispose();
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _breakController.dispose();
    _hourlyRateController.dispose();
    _overtimeRateController.dispose();
    _bonusController.dispose();
    _deductionsController.dispose();
    _notesController.dispose();
    _manualRegularController.dispose();
    _manualOvertimeController.dispose();
    _startTimeFocus.dispose();
    _endTimeFocus.dispose();
    _hourlyRateFocus.dispose();
    _overtimeRateFocus.dispose();
    _bonusFocus.dispose();
    _deductionsFocus.dispose();
    _manualRegularFocus.dispose();
    _manualOvertimeFocus.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    setState(() {
      _isLoadingEmployees = true;
    });

    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        setState(() {
          _employees = [];
          _isLoadingEmployees = false;
        });
        return;
      }

      final response = await Supabase.instance.client
          .from('employees')
          .select()
          .eq('user_id', session.user.id);

      _employees = (response as List)
          .where((json) => json['deleted_at'] == null && json['active'] == true) // Filter active employees
          .map((json) => CalcEmployee(
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

      // ✅ If in edit mode, select the employee
      if (_isEditMode && _selectedEmployeeId.isNotEmpty) {
        final employee = _employees.firstWhere(
          (e) => e.id == _selectedEmployeeId,
          orElse: () => _employees.isEmpty ? CalcEmployee(
            id: '',
            userId: '',
            name: '',
            hourlyRateCents: 0,
            overtimeRateCents: 0,
            overtimeMultiplier: 1,
            active: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ) : _employees.first,
        );
        if (employee.id.isNotEmpty) {
          _employeeController.text = employee.name;
        }
      }

      setState(() {
        _employees = _employees;
        _isLoadingEmployees = false;
      });
    } catch (e) {
      print('❌ Error loading employees: $e');
      setState(() {
        _isLoadingEmployees = false;
      });
    }
  }

  void _calculateIfValid() {
    try {
      if (CalcTimeUtils.isValidTimeFormat(_startTimeController.text) && 
          CalcTimeUtils.isValidTimeFormat(_endTimeController.text)) {
        _calculate();
      }
    } catch (_) {}
  }

  void _updateManualOvertime() {
    final regular = int.tryParse(_manualRegularController.text) ?? 0;
    final overtime = int.tryParse(_manualOvertimeController.text) ?? 0;
    
    setState(() {
      _manualRegularMinutes = regular;
      _manualOvertimeMinutes = overtime;
    });
    _calculate();
  }

  void _calculate() {
    try {
      final start = _startTimeController.text.isNotEmpty ? _startTimeController.text : _startTime;
      final end = _endTimeController.text.isNotEmpty ? _endTimeController.text : _endTime;

      if (!CalcTimeUtils.isValidTimeFormat(start) || !CalcTimeUtils.isValidTimeFormat(end)) {
        return;
      }

      final startMinutes = CalcTimeUtils.timeToMinutes(start);
      final endMinutes = CalcTimeUtils.timeToMinutes(end);
      
      final breakMins = int.tryParse(_breakController.text) ?? 0;
      final hourlyCents = CalcMoneyUtils.parseFormattedAmountToCents(_hourlyRateController.text);
      final overtimeCents = CalcMoneyUtils.parseFormattedAmountToCents(_overtimeRateController.text);
      final bonus = CalcMoneyUtils.parseFormattedAmountToCents(_bonusController.text);
      final deductions = CalcMoneyUtils.parseFormattedAmountToCents(_deductionsController.text);
      final threshold = CalcAppConstants.defaultRegularThresholdMinutes;
      
      final manualReg = _manualRegularMinutes;
      final manualOt = _manualOvertimeMinutes;

      final result = _calculationService.calculateShift(
        startMinutes: startMinutes,
        endMinutes: endMinutes,
        breakMinutes: breakMins,
        hourlyRateCents: hourlyCents,
        overtimeRateCents: overtimeCents,
        bonusCents: bonus,
        deductionsCents: deductions,
        overtimeMode: _overtimeMode,
        regularThresholdMinutes: threshold,
        manualRegularMinutes: manualReg,
        manualOvertimeMinutes: manualOt,
      );
      
      setState(() {
        _breakMinutes = breakMins;
        _hourlyRateCents = hourlyCents;
        _overtimeRateCents = overtimeCents;
        _totalMinutes = result.totalMinutes;
        _regularMinutes = result.regularMinutes;
        _overtimeMinutes = result.overtimeMinutes;
        _regularPay = result.regularPayCents;
        _overtimePay = result.overtimePayCents;
        _grossPay = result.grossPayCents;
        _netPay = result.netPayCents;
        _bonus = bonus;
        _deductions = deductions;
      });
    } catch (e) {
      // Silently handle calculation errors
    }
  }

  Future<void> _saveShift() async {
    if (_selectedEmployeeId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an employee')),
      );
      return;
    }

    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login first')),
        );
        return;
      }

      final workRecord = {
        'id': _isEditMode ? _editRecordId! : const Uuid().v4(),
        'user_id': session.user.id,
        'employee_id': _selectedEmployeeId,
        'work_date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'start_time': _startTimeController.text,
        'end_time': _endTimeController.text,
        'break_minutes': _breakMinutes,
        'overtime_mode': _overtimeMode,
        'regular_minutes': _regularMinutes,
        'overtime_minutes': _overtimeMinutes,
        'total_minutes': _totalMinutes,
        'hourly_rate_cents': _hourlyRateCents,
        'overtime_rate_cents': _overtimeRateCents,
        'bonus_cents': _bonus,
        'deductions_cents': _deductions,
        'regular_pay_cents': _regularPay,
        'overtime_pay_cents': _overtimePay,
        'gross_pay_cents': _grossPay,
        'net_pay_cents': _netPay,
        'notes': _notesController.text.isNotEmpty ? _notesController.text : null,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (_isEditMode) {
        // ✅ UPDATE existing record
        await Supabase.instance.client
            .from('work_records')
            .update(workRecord)
            .eq('id', _editRecordId!);
      } else {
        // ✅ INSERT new record
        workRecord['created_at'] = DateTime.now().toIso8601String();
        await Supabase.instance.client
            .from('work_records')
            .insert(workRecord);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(
            _isEditMode ? 'Shift updated successfully!' : 'Shift saved successfully!'
          )),
        );
        
        if (_isEditMode) {
          Navigator.pop(context, true);
        } else {
          _resetForm();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving shift: $e')),
        );
      }
    }
  }

  void _resetForm() {
    setState(() {
      _selectedEmployeeId = '';
      _employeeController.clear();
      _startTime = '09:00';
      _endTime = '17:00';
      _breakMinutes = 0;
      _regularMinutes = 0;
      _overtimeMinutes = 0;
      _totalMinutes = 0;
      _regularPay = 0;
      _overtimePay = 0;
      _grossPay = 0;
      _netPay = 0;
      _bonus = 0;
      _deductions = 0;
      _manualRegularMinutes = 0;
      _manualOvertimeMinutes = 0;
      _notesController.clear();
      _bonusController.text = '0.00';
      _deductionsController.text = '0.00';
      _startTimeController.text = '09:00';
      _endTimeController.text = '17:00';
      _breakController.text = '0';
      _hourlyRateController.text = '12.00';
      _overtimeRateController.text = '18.00';
      _manualRegularController.text = '0';
      _manualOvertimeController.text = '0';
      _dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
      _selectedDate = DateTime.now();
      _overtimeMode = CalcAppConstants.overtimeNone;
    });
    _calculate();
  }

  void _selectEmployee(CalcEmployee employee) {
    setState(() {
      _selectedEmployeeId = employee.id;
      _employeeController.text = employee.name;
      _hourlyRateCents = employee.hourlyRateCents;
      _overtimeRateCents = employee.overtimeRateCents;
      _hourlyRateController.text = (employee.hourlyRateCents / 100).toStringAsFixed(2);
      _overtimeRateController.text = (employee.overtimeRateCents / 100).toStringAsFixed(2);
    });
    _calculate();
  }

  void _formatTimeOnFocusLost(TextEditingController controller, Function(String) onUpdate) {
    if (controller.text.isNotEmpty) {
      final formatted = CalcTimeUtils.formatTimeFromDigits(controller.text);
      if (formatted.isNotEmpty) {
        controller.text = formatted;
        onUpdate(formatted);
      }
    }
    _calculateIfValid();
  }

  void _formatCurrencyOnFocusLost(TextEditingController controller, Function(String) onUpdate) {
    if (controller.text.isNotEmpty) {
      final formatted = CalcMoneyUtils.formatAmountFromDigits(controller.text);
      if (formatted.isNotEmpty) {
        final withTwoDecimals = CalcMoneyUtils.formatAmountWithTwoDecimals(formatted);
        controller.text = withTwoDecimals;
        onUpdate(withTwoDecimals);
      }
    }
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Shift' : 'Calculator',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context, false),
              tooltip: 'Cancel',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEmployees,
            tooltip: 'Refresh Employees',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveShift,
            tooltip: _isEditMode ? 'Update Shift' : 'Save Shift',
          ),
        ],
      ),
      body: _isLoadingEmployees
          ? const Center(child: CircularProgressIndicator())
          : _buildCalculator(_employees),
    );
  }

  Widget _buildCalculator(List<CalcEmployee> employees) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Employee Selection - Dashboard Style
          Container(
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
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                if (employees.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please add employees first')),
                  );
                  return;
                }
                _showEmployeePicker(employees);
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.person,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Employee',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            _selectedEmployeeId.isEmpty
                                ? employees.isEmpty 
                                    ? 'No employees found' 
                                    : 'Select an employee'
                                : _employeeController.text,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // ✅ Date - Dashboard Style (Light Orange Background) - FIXED
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
            child:Row(
  children: [
    Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        child: TextFormField(
          controller: _dateController,
          decoration: InputDecoration(
            labelText: 'Date (DD-MM-YYYY)',
            labelStyle: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
            prefixIcon: Icon(
              Icons.calendar_today,
              color: Colors.orange.shade400,
              size: 20,
            ),
            border: InputBorder.none,
            hintText: 'DD-MM-YYYY',
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
          ),
          style: const TextStyle(fontSize: 15),
          readOnly: true,
          onTap: _pickDate,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a date';
            }
            return null;
          },
        ),
      ),
    ),
    Container(
      padding: const EdgeInsets.only(right: 12),
      child: IconButton(
        icon: Icon(
          Icons.edit_calendar,
          color: Colors.orange.shade400,
          size: 20,
        ),
        onPressed: _pickDate,
      ),
    ),
  ],
)
          ),
          const SizedBox(height: 12),
          
          // ✅ Time Row - Dashboard Style
          Row(
            children: [
              Expanded(
                child: Container(
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    child: TextFormField(
                      controller: _startTimeController,
                      focusNode: _startTimeFocus,
                      decoration: InputDecoration(
                        labelText: 'Start Time',
                        labelStyle: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                        prefixIcon: Icon(
                          Icons.access_time,
                          color: Colors.purple.shade400,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        hintText: 'HH:MM',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(fontSize: 15),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      onChanged: (value) {
                        _startTime = value;
                        _calculateIfValid();
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter start time';
                        }
                        if (!CalcTimeUtils.isValidTimeFormat(value)) {
                          return 'Please enter valid time (HH:MM)';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    child: TextFormField(
                      controller: _endTimeController,
                      focusNode: _endTimeFocus,
                      decoration: InputDecoration(
                        labelText: 'End Time',
                        labelStyle: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                        prefixIcon: Icon(
                          Icons.access_time,
                          color: Colors.teal.shade400,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        hintText: 'HH:MM',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(fontSize: 15),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      onChanged: (value) {
                        _endTime = value;
                        _calculateIfValid();
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter end time';
                        }
                        if (!CalcTimeUtils.isValidTimeFormat(value)) {
                          return 'Please enter valid time (HH:MM)';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // ✅ Break - Dashboard Style (Light Green Background)
          Container(
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green.shade200,
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
              child: TextFormField(
                controller: _breakController,
                decoration: InputDecoration(
                  labelText: 'Break (minutes)',
                  labelStyle: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                  prefixIcon: Icon(
                    Icons.free_breakfast,
                    color: Colors.green.shade400,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  hintText: '0',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                ),
                style: const TextStyle(fontSize: 15),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (value) {
                  _breakMinutes = int.tryParse(value) ?? 0;
                  _calculateIfValid();
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // ✅ Overtime Mode Section - Dashboard Style (Light Indigo Background)
          Container(
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.indigo.shade200,
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
                  const Text(
                    'Overtime Mode',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<String>(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.selected)) {
                            return Colors.indigo.shade100;
                          }
                          return Colors.white;
                        },
                      ),
                      foregroundColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.selected)) {
                            return Colors.indigo.shade700;
                          }
                          return Colors.grey.shade700;
                        },
                      ),
                    ),
                    segments: const [
                      ButtonSegment(
                        value: CalcAppConstants.overtimeAutomatic,
                        label: Text('Auto'),
                        icon: Icon(Icons.auto_awesome, size: 16),
                      ),
                      ButtonSegment(
                        value: CalcAppConstants.overtimeManual,
                        label: Text('Manual'),
                        icon: Icon(Icons.edit, size: 16),
                      ),
                      ButtonSegment(
                        value: CalcAppConstants.overtimeNone,
                        label: Text('None'),
                        icon: Icon(Icons.block, size: 16),
                      ),
                    ],
                    selected: {_overtimeMode},
                    onSelectionChanged: (Set<String> selection) {
                      setState(() {
                        _overtimeMode = selection.first;
                        if (_overtimeMode == CalcAppConstants.overtimeManual) {
                          _manualRegularController.text = _totalMinutes.toString();
                          _manualOvertimeController.text = '0';
                          _manualRegularMinutes = _totalMinutes;
                          _manualOvertimeMinutes = 0;
                        }
                      });
                      _calculate();
                    },
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _overtimeMode == CalcAppConstants.overtimeAutomatic 
                              ? Icons.auto_awesome 
                              : _overtimeMode == CalcAppConstants.overtimeManual 
                                  ? Icons.edit 
                                  : Icons.block,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getOvertimeModeDescription(_overtimeMode),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // ✅ Manual Overtime Inputs - Dashboard Style
          if (_overtimeMode == CalcAppConstants.overtimeManual) ...[
            const SizedBox(height: 12),
            Container(
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
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.edit_note,
                            color: Colors.blue.shade700,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Manual Distribution',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.timer, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 6),
                          Text(
                            'Total: ${CalcTimeUtils.formatDuration(_totalMinutes)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: TextFormField(
                                controller: _manualRegularController,
                                focusNode: _manualRegularFocus,
                                decoration: const InputDecoration(
                                  labelText: 'Regular Minutes',
                                  labelStyle: TextStyle(fontSize: 12, color: Colors.grey),
                                  border: InputBorder.none,
                                  prefixIcon: Icon(Icons.check_circle, color: Colors.green, size: 18),
                                ),
                                style: const TextStyle(fontSize: 14),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onChanged: (_) => _updateManualOvertime(),
                                validator: (value) {
                                  final val = int.tryParse(value ?? '0') ?? 0;
                                  final total = int.tryParse(_manualOvertimeController.text) ?? 0;
                                  if (val + total > _totalMinutes) {
                                    return 'Exceeds total minutes';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: TextFormField(
                                controller: _manualOvertimeController,
                                focusNode: _manualOvertimeFocus,
                                decoration: const InputDecoration(
                                  labelText: 'Overtime Minutes',
                                  labelStyle: TextStyle(fontSize: 12, color: Colors.grey),
                                  border: InputBorder.none,
                                  prefixIcon: Icon(Icons.star, color: Colors.orange, size: 18),
                                ),
                                style: const TextStyle(fontSize: 14),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onChanged: (_) => _updateManualOvertime(),
                                validator: (value) {
                                  final val = int.tryParse(value ?? '0') ?? 0;
                                  final total = int.tryParse(_manualRegularController.text) ?? 0;
                                  if (val + total > _totalMinutes) {
                                    return 'Exceeds total minutes';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _manualRegularMinutes + _manualOvertimeMinutes == _totalMinutes
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _manualRegularMinutes + _manualOvertimeMinutes == _totalMinutes
                              ? Colors.green.shade200
                              : Colors.red.shade200,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: _manualRegularMinutes + _manualOvertimeMinutes == _totalMinutes
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _manualRegularMinutes + _manualOvertimeMinutes == _totalMinutes
                                  ? '✅ Regular + Overtime = $_totalMinutes minutes (correct)'
                                  : '⚠️ Regular + Overtime must equal $_totalMinutes minutes',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: _manualRegularMinutes + _manualOvertimeMinutes == _totalMinutes
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Current: ${_manualRegularMinutes} regular + ${_manualOvertimeMinutes} overtime = ${_manualRegularMinutes + _manualOvertimeMinutes} min',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 12),
          
          // ✅ Rates Row - Dashboard Style
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.shade200,
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
                    child: TextFormField(
                      controller: _hourlyRateController,
                      focusNode: _hourlyRateFocus,
                      decoration: InputDecoration(
                        labelText: 'Hourly Rate',
                        labelStyle: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                        prefixIcon: Icon(
                          Icons.currency_pound,
                          color: Colors.green.shade400,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        hintText: '0.00',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(fontSize: 15),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        CurrencyTextInputFormatter(),
                      ],
                      onChanged: (value) {
                        _hourlyRateCents = CalcMoneyUtils.parseFormattedAmountToCents(value);
                        _calculateIfValid();
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter hourly rate';
                        }
                        final rate = double.tryParse(value);
                        if (rate == null || rate < 0) {
                          return 'Please enter a valid rate';
                        }
                        final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
                        if (digits.length > 10) {
                          return 'Maximum 10 digits allowed';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
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
                    child: TextFormField(
                      controller: _overtimeRateController,
                      focusNode: _overtimeRateFocus,
                      decoration: InputDecoration(
                        labelText: 'Overtime Rate',
                        labelStyle: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                        prefixIcon: Icon(
                          Icons.currency_pound,
                          color: Colors.orange.shade400,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        hintText: '0.00',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(fontSize: 15),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        CurrencyTextInputFormatter(),
                      ],
                      onChanged: (value) {
                        _overtimeRateCents = CalcMoneyUtils.parseFormattedAmountToCents(value);
                        _calculateIfValid();
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter overtime rate';
                        }
                        final rate = double.tryParse(value);
                        if (rate == null || rate < 0) {
                          return 'Please enter a valid rate';
                        }
                        final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
                        if (digits.length > 10) {
                          return 'Maximum 10 digits allowed';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // ✅ Bonus and Deductions Row - Dashboard Style
          Row(
            children: [
              Expanded(
                child: Container(
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    child: TextFormField(
                      controller: _bonusController,
                      focusNode: _bonusFocus,
                      decoration: InputDecoration(
                        labelText: 'Bonus',
                        labelStyle: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                        prefixIcon: Icon(
                          Icons.add_circle,
                          color: Colors.teal.shade400,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        hintText: '0.00',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(fontSize: 15),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        CurrencyTextInputFormatter(),
                      ],
                      onChanged: (_) => _calculateIfValid(),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
                          if (digits.length > 10) {
                            return 'Maximum 10 digits allowed';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red.shade200,
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
                    child: TextFormField(
                      controller: _deductionsController,
                      focusNode: _deductionsFocus,
                      decoration: InputDecoration(
                        labelText: 'Deductions',
                        labelStyle: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                        prefixIcon: Icon(
                          Icons.remove_circle,
                          color: Colors.red.shade400,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        hintText: '0.00',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(fontSize: 15),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        CurrencyTextInputFormatter(),
                      ],
                      onChanged: (_) => _calculateIfValid(),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
                          if (digits.length > 10) {
                            return 'Maximum 10 digits allowed';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // ✅ Notes - Dashboard Style (Light Grey Background)
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade300,
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
              child: TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  labelStyle: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                  prefixIcon: Icon(
                    Icons.note,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  hintText: 'Add notes...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                ),
                style: const TextStyle(fontSize: 15),
                maxLines: 2,
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // ✅ Results Card - Dashboard Style
          Container(
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue.shade200,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
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
                        child: Icon(
                          Icons.calculate,
                          color: Colors.blue.shade700,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Results',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const Divider(thickness: 1),
                  const SizedBox(height: 4),
                  _buildResultRow(
                    'Total Time',
                    CalcTimeUtils.formatDuration(_totalMinutes),
                    icon: Icons.timer,
                    iconColor: Colors.blue,
                  ),
                  _buildResultRow(
                    'Regular Hours',
                    CalcTimeUtils.formatDuration(_regularMinutes),
                    icon: Icons.check_circle,
                    iconColor: Colors.green,
                  ),
                  _buildResultRow(
                    'Overtime Hours',
                    CalcTimeUtils.formatDuration(_overtimeMinutes),
                    icon: Icons.star,
                    iconColor: Colors.orange,
                  ),
                  const Divider(thickness: 1),
                  _buildResultRow(
                    'Regular Pay',
                    CalcMoneyUtils.formatCurrency(_regularPay),
                    icon: Icons.currency_pound,
                    iconColor: Colors.green,
                  ),
                  _buildResultRow(
                    'Overtime Pay',
                    CalcMoneyUtils.formatCurrency(_overtimePay),
                    icon: Icons.currency_pound,
                    iconColor: Colors.orange,
                  ),
                  _buildResultRow(
                    'Bonus',
                    CalcMoneyUtils.formatCurrency(_bonus),
                    icon: Icons.add_circle,
                    iconColor: Colors.green,
                  ),
                  _buildResultRow(
                    'Deductions',
                    CalcMoneyUtils.formatCurrency(_deductions),
                    icon: Icons.remove_circle,
                    iconColor: Colors.red,
                  ),
                  const Divider(thickness: 2, color: Colors.blue),
                  _buildResultRow(
                    'Gross Pay',
                    CalcMoneyUtils.formatCurrency(_grossPay),
                    bold: true,
                    icon: Icons.attach_money,
                    iconColor: Colors.blue,
                  ),
                  _buildResultRow(
                    'Net Pay',
                    CalcMoneyUtils.formatCurrency(_netPay),
                    bold: true,
                    icon: Icons.attach_money,
                    iconColor: Colors.green,
                    textColor: Colors.green,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // ✅ Save Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _saveShift,
              icon: const Icon(Icons.save),
              label: Text(
                _isEditMode ? 'Update Shift' : 'Save Shift',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  String _getOvertimeModeDescription(String mode) {
    switch (mode) {
      case 'automatic':
        return '🔹 Overtime calculated automatically after threshold (8 hours)';
      case 'manual':
        return '✏️ You manually enter regular and overtime hours';
      case 'none':
        return '⛔ No overtime, all hours treated as regular (Default)';
      default:
        return '';
    }
  }

  Widget _buildResultRow(String label, String value, {bool bold = false, IconData? icon, Color? iconColor, Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: iconColor ?? Colors.grey),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                fontSize: bold ? 16 : 14,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              fontSize: bold ? 16 : 14,
              color: textColor ?? (bold ? Colors.blue.shade700 : null),
            ),
          ),
        ],
      ),
    );
  }

  void _showEmployeePicker(List<CalcEmployee> employees) {
  // 1. Filter out inactive employees
  final activeEmployees = employees.where((e) => e.active).toList();

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Container(
        height: 400,
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
            const Text(
              'Select Employee',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: activeEmployees.isEmpty
                  ? const Center(
                      child: Text('No active employees available'),
                    )
                  : ListView.builder(
                      // 2. Use activeEmployees here instead of employees
                      itemCount: activeEmployees.length,
                      itemBuilder: (context, index) {
                        final employee = activeEmployees[index];
                        return Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              child: Text(
                                employee.name[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              employee.name,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              '£${(employee.hourlyRateCents / 100).toStringAsFixed(2)}/hr',
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              _selectEmployee(employee);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    },
  );
}
}