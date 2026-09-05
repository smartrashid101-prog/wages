import 'package:uuid/uuid.dart';
import '../local/dao/work_record_dao.dart';
import '../remote/supabase/supabase_client.dart';

// Simple WorkRecord class - inline to avoid import issues
class RepoWorkRecord {
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
  
  RepoWorkRecord({
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
  
  RepoWorkRecord copyWith({
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
    return RepoWorkRecord(
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
  
  factory RepoWorkRecord.fromJson(Map<String, dynamic> json) => RepoWorkRecord(
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
  
  // Convert to DaoWorkRecord for local storage
  DaoWorkRecord toDaoWorkRecord() {
    return DaoWorkRecord(
      id: id,
      userId: userId,
      employeeId: employeeId,
      workDate: workDate,
      startTime: startTime,
      endTime: endTime,
      breakMinutes: breakMinutes,
      overtimeMode: overtimeMode,
      regularMinutes: regularMinutes,
      overtimeMinutes: overtimeMinutes,
      totalMinutes: totalMinutes,
      hourlyRateCents: hourlyRateCents,
      overtimeRateCents: overtimeRateCents,
      bonusCents: bonusCents,
      deductionsCents: deductionsCents,
      regularPayCents: regularPayCents,
      overtimePayCents: overtimePayCents,
      grossPayCents: grossPayCents,
      netPayCents: netPayCents,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }
  
  // Create from DaoWorkRecord
  factory RepoWorkRecord.fromDaoWorkRecord(DaoWorkRecord dao) {
    return RepoWorkRecord(
      id: dao.id,
      userId: dao.userId,
      employeeId: dao.employeeId,
      workDate: dao.workDate,
      startTime: dao.startTime,
      endTime: dao.endTime,
      breakMinutes: dao.breakMinutes,
      overtimeMode: dao.overtimeMode,
      regularMinutes: dao.regularMinutes,
      overtimeMinutes: dao.overtimeMinutes,
      totalMinutes: dao.totalMinutes,
      hourlyRateCents: dao.hourlyRateCents,
      overtimeRateCents: dao.overtimeRateCents,
      bonusCents: dao.bonusCents,
      deductionsCents: dao.deductionsCents,
      regularPayCents: dao.regularPayCents,
      overtimePayCents: dao.overtimePayCents,
      grossPayCents: dao.grossPayCents,
      netPayCents: dao.netPayCents,
      notes: dao.notes,
      createdAt: dao.createdAt,
      updatedAt: dao.updatedAt,
      deletedAt: dao.deletedAt,
    );
  }
}

class WorkRecordRepository {
  final WorkRecordDao _localDao = WorkRecordDao();
  final AppSupabaseClient _supabase = AppSupabaseClient(); // ✅ FIXED: Use AppSupabaseClient
  
  Future<void> addWorkRecord(RepoWorkRecord record) async {
    final id = record.id.isNotEmpty ? record.id : const Uuid().v4();
    final newRecord = record.copyWith(id: id);
    
    await _localDao.insertWorkRecord(
      newRecord.toDaoWorkRecord(),
      syncStatus: 'pending',
    );
  }
  
  Future<void> updateWorkRecord(RepoWorkRecord record) async {
    await _localDao.updateWorkRecord(
      record.toDaoWorkRecord(),
      syncStatus: 'pending',
    );
  }
  
  Future<void> deleteWorkRecord(String id, String userId) async {
    await _localDao.softDeleteWorkRecord(id, userId);
  }
  
  Future<List<RepoWorkRecord>> getWorkRecordsByUserId(String userId) async {
    final daoRecords = await _localDao.getWorkRecordsByUserId(userId);
    return daoRecords.map((dao) => RepoWorkRecord.fromDaoWorkRecord(dao)).toList();
  }
  
  Future<List<RepoWorkRecord>> getWorkRecordsByEmployeeId(String employeeId, String userId) async {
    final daoRecords = await _localDao.getWorkRecordsByEmployeeId(employeeId, userId);
    return daoRecords.map((dao) => RepoWorkRecord.fromDaoWorkRecord(dao)).toList();
  }
  
  Future<List<RepoWorkRecord>> getWorkRecordsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final daoRecords = await _localDao.getWorkRecordsByDateRange(userId, startDate, endDate);
    return daoRecords.map((dao) => RepoWorkRecord.fromDaoWorkRecord(dao)).toList();
  }
  
  Future<RepoWorkRecord?> getWorkRecordById(String id, String userId) async {
    final dao = await _localDao.getWorkRecordById(id, userId);
    if (dao == null) return null;
    return RepoWorkRecord.fromDaoWorkRecord(dao);
  }
  
  Future<List<RepoWorkRecord>> getPendingWorkRecords(String userId) async {
    final daoRecords = await _localDao.getPendingWorkRecords(userId);
    return daoRecords.map((dao) => RepoWorkRecord.fromDaoWorkRecord(dao)).toList();
  }
  
  Future<void> markSynced(String id, String userId) async {
    await _localDao.markSynced(id, userId);
  }
  
  Future<void> markSyncFailed(String id, String userId, String error) async {
    await _localDao.markSyncFailed(id, userId, error);
  }
  
  // Cloud operations
  Future<void> uploadToCloud(RepoWorkRecord record) async {
    await _supabase.from('work_records').insert(record.toJson());
  }
  
  Future<void> updateInCloud(RepoWorkRecord record) async {
    await _supabase
        .from('work_records')
        .update(record.toJson())
        .eq('id', record.id);
  }
  
  Future<void> deleteInCloud(String id) async {
    await _supabase
        .from('work_records')
        .update({'deleted_at': DateTime.now().toIso8601String()})
        .eq('id', id);
  }
  
  Future<List<RepoWorkRecord>> fetchFromCloud(
    String userId, {
    DateTime? since,
  }) async {
    try {
      var query = _supabase
          .from('work_records')
          .select()
          .eq('user_id', userId);
      
      if (since != null) {
        query = query.gt('updated_at', since.toIso8601String());
      }
      
      final response = await query;
      
      return (response as List)
          .map((json) => RepoWorkRecord.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching work records from cloud: $e');
      return [];
    }
  }
}