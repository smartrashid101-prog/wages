// ✅ REMOVED: import 'package:sqflite/sqflite.dart'; - Not needed directly
import '../database/local_database.dart';

// Simple Employee class
class DaoEmployee {
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
  
  DaoEmployee({
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
  
  Map<String, dynamic> toMap() => {
    'id': id,
    'user_id': userId,
    'name': name,
    'hourly_rate_cents': hourlyRateCents,
    'overtime_rate_cents': overtimeRateCents,
    'overtime_multiplier': overtimeMultiplier,
    'notes': notes,
    'active': active ? 1 : 0,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'deleted_at': deletedAt?.toIso8601String(),
  };
  
  factory DaoEmployee.fromMap(Map<String, dynamic> map) => DaoEmployee(
    id: map['id'],
    userId: map['user_id'],
    name: map['name'],
    hourlyRateCents: map['hourly_rate_cents'],
    overtimeRateCents: map['overtime_rate_cents'],
    overtimeMultiplier: map['overtime_multiplier'],
    notes: map['notes'],
    active: map['active'] == 1,
    createdAt: DateTime.parse(map['created_at']),
    updatedAt: DateTime.parse(map['updated_at']),
    deletedAt: map['deleted_at'] != null ? DateTime.parse(map['deleted_at']) : null,
  );
}

class EmployeeDao {
  final LocalDatabase _db = LocalDatabase();
  
  Future<int> insertEmployee(DaoEmployee employee, {String syncStatus = 'pending'}) async {
    final db = await _db.database;
    final map = employee.toMap();
    map['sync_status'] = syncStatus;
    return await db.insert('local_employees', map);
  }
  
  Future<int> updateEmployee(DaoEmployee employee, {String syncStatus = 'pending'}) async {
    final db = await _db.database;
    final map = employee.toMap();
    map['sync_status'] = syncStatus;
    return await db.update(
      'local_employees',
      map,
      where: 'id = ? AND user_id = ?',
      whereArgs: [employee.id, employee.userId],
    );
  }
  
  Future<List<DaoEmployee>> getEmployeesByUserId(String userId, {bool includeDeleted = false}) async {
    final db = await _db.database;
    final where = includeDeleted 
        ? 'user_id = ?' 
        : 'user_id = ? AND deleted_at IS NULL';
    
    final result = await db.query(
      'local_employees',
      where: where,
      whereArgs: [userId],
      orderBy: 'name ASC',
    );
    
    return result.map((row) => DaoEmployee.fromMap(row)).toList();
  }
  
  Future<DaoEmployee?> getEmployeeById(String id, String userId) async {
    final db = await _db.database;
    final result = await db.query(
      'local_employees',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
    
    if (result.isEmpty) return null;
    return DaoEmployee.fromMap(result.first);
  }
  
  Future<List<DaoEmployee>> getPendingEmployees(String userId) async {
    final db = await _db.database;
    final result = await db.query(
      'local_employees',
      where: 'user_id = ? AND sync_status = ?',
      whereArgs: [userId, 'pending'],
    );
    
    return result.map((row) => DaoEmployee.fromMap(row)).toList();
  }
  
  Future<List<DaoEmployee>> getFailedEmployees(String userId) async {
    final db = await _db.database;
    final result = await db.query(
      'local_employees',
      where: 'user_id = ? AND sync_status = ?',
      whereArgs: [userId, 'failed'],
    );
    
    return result.map((row) => DaoEmployee.fromMap(row)).toList();
  }
  
  Future<int> markSynced(String id, String userId) async {
    final db = await _db.database;
    return await db.update(
      'local_employees',
      {'sync_status': 'synced', 'sync_error': null},
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }
  
  Future<int> markSyncFailed(String id, String userId, String error) async {
    final db = await _db.database;
    return await db.update(
      'local_employees',
      {'sync_status': 'failed', 'sync_error': error},
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }
  
  Future<int> softDeleteEmployee(String id, String userId) async {
    final db = await _db.database;
    return await db.update(
      'local_employees',
      {
        'deleted_at': DateTime.now().toIso8601String(),
        'sync_status': 'pending',
      },
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }
  
  Future<int> deleteEmployeePermanently(String id, String userId) async {
    final db = await _db.database;
    return await db.delete(
      'local_employees',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }
}