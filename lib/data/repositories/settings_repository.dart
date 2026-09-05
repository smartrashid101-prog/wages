import 'package:uuid/uuid.dart';
import '../local/dao/settings_dao.dart';
import '../remote/supabase/supabase_client.dart';

// Simple Settings class - inline to avoid import issues
class RepoSettings {
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
  
  RepoSettings({
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
  
  RepoSettings copyWith({
    String? id,
    String? userId,
    String? currency,
    int? defaultHourlyRateCents,
    double? defaultOvertimeMultiplier,
    int? defaultBreakMinutes,
    int? defaultRegularThresholdMinutes,
    String? timeFormat,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RepoSettings(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      currency: currency ?? this.currency,
      defaultHourlyRateCents: defaultHourlyRateCents ?? this.defaultHourlyRateCents,
      defaultOvertimeMultiplier: defaultOvertimeMultiplier ?? this.defaultOvertimeMultiplier,
      defaultBreakMinutes: defaultBreakMinutes ?? this.defaultBreakMinutes,
      defaultRegularThresholdMinutes: defaultRegularThresholdMinutes ?? this.defaultRegularThresholdMinutes,
      timeFormat: timeFormat ?? this.timeFormat,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
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
  
  factory RepoSettings.fromJson(Map<String, dynamic> json) => RepoSettings(
    id: json['id'],
    userId: json['user_id'],
    currency: json['currency'] ?? 'GBP',
    defaultHourlyRateCents: json['default_hourly_rate_cents'] ?? 1200,
    defaultOvertimeMultiplier: (json['default_overtime_multiplier'] as num?)?.toDouble() ?? 1.5,
    defaultBreakMinutes: json['default_break_minutes'] ?? 30,
    defaultRegularThresholdMinutes: json['default_regular_threshold_minutes'] ?? 480,
    timeFormat: json['time_format'] ?? '24h',
    createdAt: DateTime.parse(json['created_at']),
    updatedAt: DateTime.parse(json['updated_at']),
  );
  
  // Convert to DaoAppSettings for local storage
  DaoAppSettings toDaoSettings() {
    return DaoAppSettings(
      id: id,
      userId: userId,
      currency: currency,
      defaultHourlyRateCents: defaultHourlyRateCents,
      defaultOvertimeMultiplier: defaultOvertimeMultiplier,
      defaultBreakMinutes: defaultBreakMinutes,
      defaultRegularThresholdMinutes: defaultRegularThresholdMinutes,
      timeFormat: timeFormat,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
  
  // Create from DaoAppSettings
  factory RepoSettings.fromDaoSettings(DaoAppSettings dao) {
    return RepoSettings(
      id: dao.id,
      userId: dao.userId,
      currency: dao.currency,
      defaultHourlyRateCents: dao.defaultHourlyRateCents,
      defaultOvertimeMultiplier: dao.defaultOvertimeMultiplier,
      defaultBreakMinutes: dao.defaultBreakMinutes,
      defaultRegularThresholdMinutes: dao.defaultRegularThresholdMinutes,
      timeFormat: dao.timeFormat,
      createdAt: dao.createdAt,
      updatedAt: dao.updatedAt,
    );
  }
}

class SettingsRepository {
  final SettingsDao _localDao = SettingsDao();
  final AppSupabaseClient _supabase = AppSupabaseClient(); // ✅ FIXED: Use AppSupabaseClient
  
  Future<void> addSettings(RepoSettings settings) async {
    final id = settings.id.isNotEmpty ? settings.id : const Uuid().v4();
    final newSettings = settings.copyWith(id: id);
    
    await _localDao.insertSettings(
      newSettings.toDaoSettings(),
      syncStatus: 'pending',
    );
  }
  
  Future<void> updateSettings(RepoSettings settings) async {
    await _localDao.updateSettings(
      settings.toDaoSettings(),
      syncStatus: 'pending',
    );
  }
  
  Future<RepoSettings?> getSettingsByUserId(String userId) async {
    final dao = await _localDao.getSettingsByUserId(userId);
    if (dao == null) return null;
    return RepoSettings.fromDaoSettings(dao);
  }
  
  Future<RepoSettings?> getPendingSettings(String userId) async {
    final pending = await _localDao.getPendingSettings(userId);
    if (pending.isEmpty) return null;
    return RepoSettings.fromDaoSettings(pending.first);
  }
  
  Future<void> markSynced(String id, String userId) async {
    await _localDao.markSynced(id, userId);
  }
  
  Future<void> markSyncFailed(String id, String userId, String error) async {
    await _localDao.markSyncFailed(id, userId, error);
  }
  
  // Cloud operations
  Future<void> uploadToCloud(RepoSettings settings) async {
    await _supabase.from('settings').insert(settings.toJson());
  }
  
  Future<void> updateInCloud(RepoSettings settings) async {
    await _supabase
        .from('settings')
        .update(settings.toJson())
        .eq('user_id', settings.userId);
  }
  
  Future<RepoSettings?> fetchFromCloud(String userId) async {
    try {
      final response = await _supabase
          .from('settings')
          .select()
          .eq('user_id', userId)
          .maybeSingle(); // ✅ FIXED: Use maybeSingle() instead of single()
      
      if (response == null) return null;
      return RepoSettings.fromJson(response);
    } catch (e) {
      print('Error fetching settings from cloud: $e');
      return null;
    }
  }
}