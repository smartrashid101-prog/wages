import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_provider.dart';

// Simple AppSettings class - no need to import from domain
class AppSettings {
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
  
  AppSettings({
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
  
  // Create default settings
  factory AppSettings.createDefault(String userId) {
    return AppSettings(
      id: '',
      userId: userId,
      currency: 'GBP',
      defaultHourlyRateCents: 1200,
      defaultOvertimeMultiplier: 1.5,
      defaultBreakMinutes: 30,
      defaultRegularThresholdMinutes: 480,
      timeFormat: '24h',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

// Settings Repository
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

class SettingsRepository {
  Future<AppSettings?> getSettingsByUserId(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('settings')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      
      if (response == null) {
        // Create default settings if none exist
        final defaultSettings = AppSettings.createDefault(userId);
        await createSettings(defaultSettings);
        return defaultSettings;
      }
      
      return AppSettings(
        id: response['id'],
        userId: response['user_id'],
        currency: response['currency'] ?? 'GBP',
        defaultHourlyRateCents: response['default_hourly_rate_cents'] ?? 1200,
        defaultOvertimeMultiplier: (response['default_overtime_multiplier'] as num?)?.toDouble() ?? 1.5,
        defaultBreakMinutes: response['default_break_minutes'] ?? 30,
        defaultRegularThresholdMinutes: response['default_regular_threshold_minutes'] ?? 480,
        timeFormat: response['time_format'] ?? '24h',
        createdAt: DateTime.parse(response['created_at']),
        updatedAt: DateTime.parse(response['updated_at']),
      );
    } catch (e) {
      // Return default settings if there's an error
      return AppSettings.createDefault(userId);
    }
  }
  
  Future<void> createSettings(AppSettings settings) async {
    await Supabase.instance.client.from('settings').insert({
      'user_id': settings.userId,
      'currency': settings.currency,
      'default_hourly_rate_cents': settings.defaultHourlyRateCents,
      'default_overtime_multiplier': settings.defaultOvertimeMultiplier,
      'default_break_minutes': settings.defaultBreakMinutes,
      'default_regular_threshold_minutes': settings.defaultRegularThresholdMinutes,
      'time_format': settings.timeFormat,
    });
  }
  
  Future<void> updateSettings(AppSettings settings) async {
    await Supabase.instance.client
        .from('settings')
        .update({
          'currency': settings.currency,
          'default_hourly_rate_cents': settings.defaultHourlyRateCents,
          'default_overtime_multiplier': settings.defaultOvertimeMultiplier,
          'default_break_minutes': settings.defaultBreakMinutes,
          'default_regular_threshold_minutes': settings.defaultRegularThresholdMinutes,
          'time_format': settings.timeFormat,
        })
        .eq('user_id', settings.userId);
  }
}

// Settings Provider - uses authProvider (not authStateProvider)
final settingsProvider = FutureProvider<AppSettings?>((ref) async {
  final authState = ref.watch(authProvider);  // ✅ FIXED: authProvider
  final user = authState.value;
  if (user == null) return null;
  
  final repository = ref.watch(settingsRepositoryProvider);
  return await repository.getSettingsByUserId(user.id);
});

// Settings Notifier
final settingsNotifierProvider = StateNotifierProvider<SettingsNotifier, AsyncValue<AppSettings?>>((ref) {
  return SettingsNotifier(ref);
});

class SettingsNotifier extends StateNotifier<AsyncValue<AppSettings?>> {
  final Ref ref;
  
  SettingsNotifier(this.ref) : super(const AsyncValue.loading()) {
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final authState = ref.watch(authProvider);  // ✅ FIXED: authProvider
    final user = authState.value;
    if (user == null) {
      state = const AsyncValue.data(null);
      return;
    }
    
    try {
      final repository = ref.read(settingsRepositoryProvider);
      final settings = await repository.getSettingsByUserId(user.id);
      state = AsyncValue.data(settings);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<void> updateSettings(AppSettings settings) async {
    try {
      final repository = ref.read(settingsRepositoryProvider);
      await repository.updateSettings(settings);
      await _loadSettings();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}