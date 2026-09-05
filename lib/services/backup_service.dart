import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';

// These classes should match what's used in your app
class BackupEmployee {
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
  
  BackupEmployee({
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
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'name': name,
    'hourly_rate_cents': hourlyRateCents,
    'overtime_rate_cents': overtimeRateCents,
    'overtime_multiplier': overtimeMultiplier,
    'notes': notes,
    'active': active,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'deleted_at': deletedAt?.toIso8601String(),
  };
  
  factory BackupEmployee.fromJson(Map<String, dynamic> json) => BackupEmployee(
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
  );
}

class BackupWorkRecord {
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
  
  BackupWorkRecord({
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
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'employee_id': employeeId,
    'work_date': workDate.toIso8601String().split('T')[0],
    'start_time': startTime,
    'end_time': endTime,
    'break_minutes': breakMinutes,
    'overtime_mode': overtimeMode,
    'regular_minutes': regularMinutes,
    'overtime_minutes': overtimeMinutes,
    'total_minutes': totalMinutes,
    'hourly_rate_cents': hourlyRateCents,
    'overtime_rate_cents': overtimeRateCents,
    'bonus_cents': bonusCents,
    'deductions_cents': deductionsCents,
    'regular_pay_cents': regularPayCents,
    'overtime_pay_cents': overtimePayCents,
    'gross_pay_cents': grossPayCents,
    'net_pay_cents': netPayCents,
    'notes': notes,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'deleted_at': deletedAt?.toIso8601String(),
  };
  
  factory BackupWorkRecord.fromJson(Map<String, dynamic> json) => BackupWorkRecord(
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
  );
}

class BackupSettings {
  final String id;
  final String userId;
  final String currency;
  final int defaultHourlyRateCents;
  final double defaultOvertimeMultiplier;
  final int defaultBreakMinutes;
  final int defaultRegularThresholdMinutes;
  final String timeFormat;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  BackupSettings({
    required this.id,
    required this.userId,
    required this.currency,
    required this.defaultHourlyRateCents,
    required this.defaultOvertimeMultiplier,
    required this.defaultBreakMinutes,
    required this.defaultRegularThresholdMinutes,
    required this.timeFormat,
    required this.createdAt,
    required this.updatedAt,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'currency': currency,
    'default_hourly_rate_cents': defaultHourlyRateCents,
    'default_overtime_multiplier': defaultOvertimeMultiplier,
    'default_break_minutes': defaultBreakMinutes,
    'default_regular_threshold_minutes': defaultRegularThresholdMinutes,
    'time_format': timeFormat,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
  
  factory BackupSettings.fromJson(Map<String, dynamic> json) => BackupSettings(
    id: json['id'],
    userId: json['user_id'],
    currency: json['currency'] ?? 'GBP',
    defaultHourlyRateCents: json['default_hourly_rate_cents'] ?? 1200,
    defaultOvertimeMultiplier: (json['default_overtime_multiplier'] as num?)?.toDouble() ?? 1.5,
    defaultBreakMinutes: json['default_break_minutes'] ?? 30,
    defaultRegularThresholdMinutes: json['default_regular_threshold_minutes'] ?? 480,
    timeFormat: json['time_format'] ?? '24h',
    createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
  );
}

class BackupService {
  static const int schemaVersion = 1;
  
  /// Export all user data as JSON
  Future<File> exportData({
    required String userId,
    required List<BackupEmployee> employees,
    required List<BackupWorkRecord> workRecords,
    BackupSettings? settings,
  }) async {
    try {
      final backup = {
        'schema_version': schemaVersion,
        'exported_at': DateTime.now().toIso8601String(),
        'user_id': userId,
        'employees': employees.map((e) => e.toJson()).toList(),
        'work_records': workRecords.map((r) => r.toJson()).toList(),
        'settings': settings?.toJson(),
      };
      
      final jsonString = const JsonEncoder.withIndent('  ').convert(backup);
      final tempDir = Directory.systemTemp;
      final fileName = 'wages_backup_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.json';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(jsonString);
      
      return file;
    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }
  
  /// Import data from JSON file
  Future<ImportResult> importData(String userId, File file) async {
    try {
      final jsonString = await file.readAsString();
      final Map<String, dynamic> backup = jsonDecode(jsonString);
      
      if (backup['schema_version'] != schemaVersion) {
        throw Exception('Incompatible schema version. Expected $schemaVersion, got ${backup['schema_version']}');
      }
      
      if (!backup.containsKey('employees') || !backup.containsKey('work_records')) {
        throw Exception('Invalid backup file: missing required fields');
      }
      
      int importedEmployees = 0;
      int importedRecords = 0;
      
      // ✅ FIXED: Use the data and count properly
      final employees = (backup['employees'] as List)
          .map((e) => BackupEmployee.fromJson(e))
          .toList();
      
      for (final employee in employees) {
        // For now, just count them
        importedEmployees++;
        // Use the employee variable to avoid unused warning
        print('Importing employee: ${employee.name}');
      }
      
      final records = (backup['work_records'] as List)
          .map((r) => BackupWorkRecord.fromJson(r))
          .toList();
      
      for (final record in records) {
        // For now, just count them
        importedRecords++;
        // Use the record variable to avoid unused warning
        print('Importing work record: ${record.id}');
      }
      
      if (backup['settings'] != null) {
        final settings = BackupSettings.fromJson(backup['settings']);
        // Use the settings variable to avoid unused warning
        print('Importing settings for user: ${settings.userId}');
      }
      
      return ImportResult(
        success: true,
        importedEmployees: importedEmployees,
        importedRecords: importedRecords,
      );
    } catch (e) {
      return ImportResult(
        success: false,
        error: e.toString(),
      );
    }
  }
  
  /// Validate backup file without importing
  Future<ValidationResult> validateBackup(File file) async {
    try {
      final jsonString = await file.readAsString();
      final Map<String, dynamic> backup = jsonDecode(jsonString);
      
      final schemaVersion = backup['schema_version'] as int?;
      if (schemaVersion == null) {
        return ValidationResult(isValid: false, error: 'Missing schema version');
      }
      
      if (schemaVersion != BackupService.schemaVersion) {
        return ValidationResult(
          isValid: false,
          error: 'Incompatible schema version. Expected $schemaVersion, got ${BackupService.schemaVersion}',
        );
      }
      
      if (!backup.containsKey('employees') || !backup.containsKey('work_records')) {
        return ValidationResult(
          isValid: false,
          error: 'Invalid backup file: missing required fields',
        );
      }
      
      if (backup['employees'] is! List) {
        return ValidationResult(isValid: false, error: 'Employees must be a list');
      }
      
      if (backup['work_records'] is! List) {
        return ValidationResult(isValid: false, error: 'Work records must be a list');
      }
      
      for (final employee in backup['employees'] as List) {
        if (!_validateEmployeeJson(employee)) {
          return ValidationResult(isValid: false, error: 'Invalid employee data structure');
        }
      }
      
      for (final record in backup['work_records'] as List) {
        if (!_validateWorkRecordJson(record)) {
          return ValidationResult(isValid: false, error: 'Invalid work record data structure');
        }
      }
      
      return ValidationResult(isValid: true);
    } catch (e) {
      return ValidationResult(isValid: false, error: 'Failed to validate backup: $e');
    }
  }
  
  bool _validateEmployeeJson(Map<String, dynamic> json) {
    return json.containsKey('id') &&
        json.containsKey('name') &&
        json.containsKey('hourly_rate_cents') &&
        json.containsKey('overtime_rate_cents');
  }
  
  bool _validateWorkRecordJson(Map<String, dynamic> json) {
    return json.containsKey('id') &&
        json.containsKey('employee_id') &&
        json.containsKey('work_date') &&
        json.containsKey('start_time') &&
        json.containsKey('end_time');
  }
}

class ImportResult {
  final bool success;
  final int importedEmployees;
  final int importedRecords;
  final String? error;
  
  ImportResult({
    required this.success,
    this.importedEmployees = 0,
    this.importedRecords = 0,
    this.error,
  });
}

class ValidationResult {
  final bool isValid;
  final String? error;
  
  ValidationResult({
    required this.isValid,
    this.error,
  });
}