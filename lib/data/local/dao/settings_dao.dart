// ✅ REMOVED: import 'package:sqflite/sqflite.dart'; - Not needed directly
import '../database/local_database.dart';

// Simple Settings class - inline to avoid import issues
class DaoAppSettings {
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
  
  DaoAppSettings({
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
  
  Map<String, dynamic> toMap() => {
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
  
  factory DaoAppSettings.fromMap(Map<String, dynamic> map) => DaoAppSettings(
    id: map['id'],
    userId: map['user_id'],
    currency: map['currency'] ?? 'GBP',
    defaultHourlyRateCents: map['default_hourly_rate_cents'] ?? 1200,
    defaultOvertimeMultiplier: (map['default_overtime_multiplier'] as num?)?.toDouble() ?? 1.5,
    defaultBreakMinutes: map['default_break_minutes'] ?? 30,
    defaultRegularThresholdMinutes: map['default_regular_threshold_minutes'] ?? 480,
    timeFormat: map['time_format'] ?? '24h',
    createdAt: DateTime.parse(map['created_at']),
    updatedAt: DateTime.parse(map['updated_at']),
  );
}

class SettingsDao {
  final LocalDatabase _db = LocalDatabase();
  
  Future<int> insertSettings(DaoAppSettings settings, {String syncStatus = 'pending'}) async {
    final db = await _db.database;
    final map = settings.toMap();
    map['sync_status'] = syncStatus;
    return await db.insert('local_settings', map);
  }
  
  Future<int> updateSettings(DaoAppSettings settings, {String syncStatus = 'pending'}) async {
    final db = await _db.database;
    final map = settings.toMap();
    map['sync_status'] = syncStatus;
    return await db.update(
      'local_settings',
      map,
      where: 'user_id = ?',
      whereArgs: [settings.userId],
    );
  }
  
  Future<DaoAppSettings?> getSettingsByUserId(String userId) async {
    final db = await _db.database;
    final result = await db.query(
      'local_settings',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    
    if (result.isEmpty) return null;
    return DaoAppSettings.fromMap(result.first);
  }
  
  Future<List<DaoAppSettings>> getPendingSettings(String userId) async {
    final db = await _db.database;
    final result = await db.query(
      'local_settings',
      where: 'user_id = ? AND sync_status = ?',
      whereArgs: [userId, 'pending'],
    );
    
    return result.map((row) => DaoAppSettings.fromMap(row)).toList();
  }
  
  Future<int> markSynced(String id, String userId) async {
    final db = await _db.database;
    return await db.update(
      'local_settings',
      {'sync_status': 'synced', 'sync_error': null},
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }
  
  Future<int> markSyncFailed(String id, String userId, String error) async {
    final db = await _db.database;
    return await db.update(
      'local_settings',
      {'sync_status': 'failed', 'sync_error': error},
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }
}