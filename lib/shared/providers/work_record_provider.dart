import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_provider.dart';

// Simple WorkRecord class
class WorkRecord {
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
  
  WorkRecord({
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

// WorkRecord Repository
final workRecordRepositoryProvider = Provider<WorkRecordRepository>((ref) {
  return WorkRecordRepository();
});

class WorkRecordRepository {
  Future<List<WorkRecord>> getWorkRecordsByUserId(String userId) async {
    try {
      // ✅ FIXED: Get all records first, then filter in Dart
      final response = await Supabase.instance.client
          .from('work_records')
          .select()
          .eq('user_id', userId)
          .order('work_date', ascending: false);
      
      // ✅ Filter out deleted records in Dart
      return (response as List)
          .where((json) => json['deleted_at'] == null)
          .map((json) => WorkRecord(
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
    } catch (e) {
      return [];
    }
  }
  
  Future<List<WorkRecord>> getWorkRecordsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final startStr = startDate.toIso8601String().split('T')[0];
      final endStr = endDate.toIso8601String().split('T')[0];
      
      // ✅ FIXED: Get all records first, then filter in Dart
      final response = await Supabase.instance.client
          .from('work_records')
          .select()
          .eq('user_id', userId)
          .gte('work_date', startStr)
          .lte('work_date', endStr)
          .order('work_date', ascending: false);
      
      // ✅ Filter out deleted records in Dart
      return (response as List)
          .where((json) => json['deleted_at'] == null)
          .map((json) => WorkRecord(
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
    } catch (e) {
      return [];
    }
  }
  
  Future<void> addWorkRecord(WorkRecord record) async {
    await Supabase.instance.client.from('work_records').insert({
      'id': record.id,
      'user_id': record.userId,
      'employee_id': record.employeeId,
      'work_date': record.workDate.toIso8601String().split('T')[0],
      'start_time': record.startTime,
      'end_time': record.endTime,
      'break_minutes': record.breakMinutes,
      'overtime_mode': record.overtimeMode,
      'regular_minutes': record.regularMinutes,
      'overtime_minutes': record.overtimeMinutes,
      'total_minutes': record.totalMinutes,
      'hourly_rate_cents': record.hourlyRateCents,
      'overtime_rate_cents': record.overtimeRateCents,
      'bonus_cents': record.bonusCents,
      'deductions_cents': record.deductionsCents,
      'regular_pay_cents': record.regularPayCents,
      'overtime_pay_cents': record.overtimePayCents,
      'gross_pay_cents': record.grossPayCents,
      'net_pay_cents': record.netPayCents,
      'notes': record.notes,
    });
  }
  
  Future<void> updateWorkRecord(WorkRecord record) async {
    await Supabase.instance.client
        .from('work_records')
        .update({
          'employee_id': record.employeeId,
          'work_date': record.workDate.toIso8601String().split('T')[0],
          'start_time': record.startTime,
          'end_time': record.endTime,
          'break_minutes': record.breakMinutes,
          'overtime_mode': record.overtimeMode,
          'regular_minutes': record.regularMinutes,
          'overtime_minutes': record.overtimeMinutes,
          'total_minutes': record.totalMinutes,
          'hourly_rate_cents': record.hourlyRateCents,
          'overtime_rate_cents': record.overtimeRateCents,
          'bonus_cents': record.bonusCents,
          'deductions_cents': record.deductionsCents,
          'regular_pay_cents': record.regularPayCents,
          'overtime_pay_cents': record.overtimePayCents,
          'gross_pay_cents': record.grossPayCents,
          'net_pay_cents': record.netPayCents,
          'notes': record.notes,
        })
        .eq('id', record.id);
  }
  
  Future<void> deleteWorkRecord(String id, String userId) async {
    await Supabase.instance.client
        .from('work_records')
        .update({'deleted_at': DateTime.now().toIso8601String()})
        .eq('id', id)
        .eq('user_id', userId);
  }
}

// WorkRecord List Provider
final workRecordListProvider = FutureProvider<List<WorkRecord>>((ref) async {
  final authState = ref.watch(authProvider);
  final user = authState.value;
  if (user == null) return [];
  
  final repository = ref.watch(workRecordRepositoryProvider);
  return await repository.getWorkRecordsByUserId(user.id);
});

// WorkRecord Notifier
final workRecordNotifierProvider = StateNotifierProvider<WorkRecordNotifier, AsyncValue<List<WorkRecord>>>((ref) {
  return WorkRecordNotifier(ref);
});

class WorkRecordNotifier extends StateNotifier<AsyncValue<List<WorkRecord>>> {
  final Ref ref;
  
  WorkRecordNotifier(this.ref) : super(const AsyncValue.loading()) {
    _loadWorkRecords();
  }
  
  Future<void> _loadWorkRecords() async {
    final authState = ref.watch(authProvider);
    final user = authState.value;
    if (user == null) {
      state = const AsyncValue.data([]);
      return;
    }
    
    try {
      final repository = ref.read(workRecordRepositoryProvider);
      final records = await repository.getWorkRecordsByUserId(user.id);
      state = AsyncValue.data(records);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<void> addWorkRecord(WorkRecord record) async {
    try {
      final repository = ref.read(workRecordRepositoryProvider);
      await repository.addWorkRecord(record);
      await _loadWorkRecords();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<void> updateWorkRecord(WorkRecord record) async {
    try {
      final repository = ref.read(workRecordRepositoryProvider);
      await repository.updateWorkRecord(record);
      await _loadWorkRecords();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<void> deleteWorkRecord(String id) async {
    try {
      final repository = ref.read(workRecordRepositoryProvider);
      final authState = ref.watch(authProvider);
      final user = authState.value;
      if (user == null) throw Exception('User not authenticated');
      
      await repository.deleteWorkRecord(id, user.id);
      await _loadWorkRecords();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<List<WorkRecord>> getRecordsByDateRange(DateTime start, DateTime end) async {
    final authState = ref.watch(authProvider);
    final user = authState.value;
    if (user == null) return [];
    
    final repository = ref.read(workRecordRepositoryProvider);
    return await repository.getWorkRecordsByDateRange(user.id, start, end);
  }
}