// ✅ REMOVED: import 'package:sqflite/sqflite.dart'; - Not needed directly
import '../database/local_database.dart';

// Simple WorkRecord class - inline to avoid import issues
class DaoWorkRecord {
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
  
  DaoWorkRecord({
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
  
  Map<String, dynamic> toMap() => {
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
  
  factory DaoWorkRecord.fromMap(Map<String, dynamic> map) => DaoWorkRecord(
    id: map['id'],
    userId: map['user_id'],
    employeeId: map['employee_id'],
    workDate: DateTime.parse(map['work_date']),
    startTime: map['start_time'],
    endTime: map['end_time'],
    breakMinutes: map['break_minutes'],
    overtimeMode: map['overtime_mode'],
    regularMinutes: map['regular_minutes'],
    overtimeMinutes: map['overtime_minutes'],
    totalMinutes: map['total_minutes'],
    hourlyRateCents: map['hourly_rate_cents'],
    overtimeRateCents: map['overtime_rate_cents'],
    bonusCents: map['bonus_cents'],
    deductionsCents: map['deductions_cents'],
    regularPayCents: map['regular_pay_cents'],
    overtimePayCents: map['overtime_pay_cents'],
    grossPayCents: map['gross_pay_cents'],
    netPayCents: map['net_pay_cents'],
    notes: map['notes'],
    createdAt: DateTime.parse(map['created_at']),
    updatedAt: DateTime.parse(map['updated_at']),
    deletedAt: map['deleted_at'] != null ? DateTime.parse(map['deleted_at']) : null,
  );
}

class WorkRecordDao {
  final LocalDatabase _db = LocalDatabase();
  
  Future<int> insertWorkRecord(DaoWorkRecord record, {String syncStatus = 'pending'}) async {
    final db = await _db.database;
    final map = record.toMap();
    map['sync_status'] = syncStatus;
    return await db.insert('local_work_records', map);
  }
  
  Future<int> updateWorkRecord(DaoWorkRecord record, {String syncStatus = 'pending'}) async {
    final db = await _db.database;
    final map = record.toMap();
    map['sync_status'] = syncStatus;
    return await db.update(
      'local_work_records',
      map,
      where: 'id = ? AND user_id = ?',
      whereArgs: [record.id, record.userId],
    );
  }
  
  Future<List<DaoWorkRecord>> getWorkRecordsByUserId(String userId, {bool includeDeleted = false}) async {
    final db = await _db.database;
    final where = includeDeleted 
        ? 'user_id = ?' 
        : 'user_id = ? AND deleted_at IS NULL';
    
    final result = await db.query(
      'local_work_records',
      where: where,
      whereArgs: [userId],
      orderBy: 'work_date DESC, start_time DESC',
    );
    
    return result.map((row) => DaoWorkRecord.fromMap(row)).toList();
  }
  
  Future<List<DaoWorkRecord>> getWorkRecordsByEmployeeId(String employeeId, String userId, {bool includeDeleted = false}) async {
    final db = await _db.database;
    final where = includeDeleted 
        ? 'employee_id = ? AND user_id = ?' 
        : 'employee_id = ? AND user_id = ? AND deleted_at IS NULL';
    
    final result = await db.query(
      'local_work_records',
      where: where,
      whereArgs: [employeeId, userId],
      orderBy: 'work_date DESC',
    );
    
    return result.map((row) => DaoWorkRecord.fromMap(row)).toList();
  }
  
  Future<List<DaoWorkRecord>> getWorkRecordsByDateRange(
    String userId, 
    DateTime startDate, 
    DateTime endDate,
    {bool includeDeleted = false}
  ) async {
    final db = await _db.database;
    final startStr = startDate.toIso8601String().split('T')[0];
    final endStr = endDate.toIso8601String().split('T')[0];
    
    final where = includeDeleted 
        ? 'user_id = ? AND work_date >= ? AND work_date <= ?' 
        : 'user_id = ? AND work_date >= ? AND work_date <= ? AND deleted_at IS NULL';
    
    final result = await db.query(
      'local_work_records',
      where: where,
      whereArgs: [userId, startStr, endStr],
      orderBy: 'work_date DESC',
    );
    
    return result.map((row) => DaoWorkRecord.fromMap(row)).toList();
  }
  
  Future<DaoWorkRecord?> getWorkRecordById(String id, String userId) async {
    final db = await _db.database;
    final result = await db.query(
      'local_work_records',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
    
    if (result.isEmpty) return null;
    return DaoWorkRecord.fromMap(result.first);
  }
  
  Future<List<DaoWorkRecord>> getPendingWorkRecords(String userId) async {
    final db = await _db.database;
    final result = await db.query(
      'local_work_records',
      where: 'user_id = ? AND sync_status = ?',
      whereArgs: [userId, 'pending'],
    );
    
    return result.map((row) => DaoWorkRecord.fromMap(row)).toList();
  }
  
  Future<List<DaoWorkRecord>> getFailedWorkRecords(String userId) async {
    final db = await _db.database;
    final result = await db.query(
      'local_work_records',
      where: 'user_id = ? AND sync_status = ?',
      whereArgs: [userId, 'failed'],
    );
    
    return result.map((row) => DaoWorkRecord.fromMap(row)).toList();
  }
  
  Future<int> markSynced(String id, String userId) async {
    final db = await _db.database;
    return await db.update(
      'local_work_records',
      {'sync_status': 'synced', 'sync_error': null},
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }
  
  Future<int> markSyncFailed(String id, String userId, String error) async {
    final db = await _db.database;
    return await db.update(
      'local_work_records',
      {'sync_status': 'failed', 'sync_error': error},
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }
  
  Future<int> softDeleteWorkRecord(String id, String userId) async {
    final db = await _db.database;
    return await db.update(
      'local_work_records',
      {
        'deleted_at': DateTime.now().toIso8601String(),
        'sync_status': 'pending',
      },
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }
  
  Future<int> deleteWorkRecordPermanently(String id, String userId) async {
    final db = await _db.database;
    return await db.delete(
      'local_work_records',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }
}