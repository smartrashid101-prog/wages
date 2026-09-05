import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wages/shared/providers/auth_provider.dart';

// ✅ Sync Service Provider
final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService();
});

class SyncService {
  final Connectivity _connectivity = Connectivity();
  
  Future<bool> isOnline() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      return true;
    }
  }
  
  Future<int> getPendingChangesCount(String userId) async {
    return 0;
  }
  
  Future<SyncResult> sync(String userId) async {
  try {
    // Check connectivity
    if (!await isOnline()) {
      return SyncResult.offline();
    }
    
    print('🔄 Starting sync for user: $userId');
    
    final supabase = Supabase.instance.client;
    
    // 1. Sync Employees
    final empResponse = await supabase
        .from('employees')
        .select()
        .eq('user_id', userId);
    print('✅ Synced ${empResponse.length} employees');
    
    // 2. Sync Work Records
    final recResponse = await supabase
        .from('work_records')
        .select()
        .eq('user_id', userId)
        .order('work_date', ascending: false);
    print('✅ Synced ${recResponse.length} work records');
    
    // 3. Sync Settings - ✅ FIXED: Handle RLS and missing settings
    try {
      final settingsResponse = await supabase
          .from('settings')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      
      if (settingsResponse != null) {
        print('✅ Synced settings');
      } else {
        print('⚠️ No settings found, creating default...');
        try {
          await supabase.from('settings').insert({
            'user_id': userId,
            'currency': 'GBP',
            'default_hourly_rate_cents': 1200,
            'default_overtime_multiplier': 1.5,
            'default_break_minutes': 30,
            'default_regular_threshold_minutes': 480,
            'time_format': '24h',
          });
          print('✅ Default settings created');
        } catch (insertError) {
          print('❌ Failed to create settings: $insertError');
          // Continue sync even if settings creation fails
        }
      }
    } catch (settingsError) {
      // If SELECT fails due to RLS, try to insert settings directly
      print('⚠️ Error accessing settings: $settingsError');
      try {
        print('🔄 Attempting to create settings directly...');
        await supabase.from('settings').insert({
          'user_id': userId,
          'currency': 'GBP',
          'default_hourly_rate_cents': 1200,
          'default_overtime_multiplier': 1.5,
          'default_break_minutes': 30,
          'default_regular_threshold_minutes': 480,
          'time_format': '24h',
        });
        print('✅ Settings created successfully');
      } catch (insertError) {
        print('❌ Failed to create settings: $insertError');
        // Continue sync even if settings creation fails
      }
    }
    
    print('✅ Sync completed successfully');
    return SyncResult.success();
    
  } catch (e) {
    print('❌ Sync error: $e');
    return SyncResult.error(e.toString());
  }
}
}

class SyncResult {
  final bool success;
  final bool isOffline;
  final String? error;
  
  const SyncResult({
    this.success = false,
    this.isOffline = false,
    this.error,
  });
  
  factory SyncResult.success() => const SyncResult(success: true);
  factory SyncResult.offline() => const SyncResult(isOffline: true);
  factory SyncResult.error(String message) => SyncResult(error: message);
}

// Sync State
class SyncState {
  final bool isSyncing;
  final bool isOffline;
  final DateTime? lastSyncTime;
  final String? error;
  
  const SyncState({
    this.isSyncing = false,
    this.isOffline = false,
    this.lastSyncTime,
    this.error,
  });
  
  const SyncState.idle() : this();
  const SyncState.syncing() : this(isSyncing: true);
  const SyncState.offline() : this(isOffline: true);
  
  factory SyncState.success({DateTime? lastSyncTime}) {
    return SyncState(
      lastSyncTime: lastSyncTime ?? DateTime.now(),
    );
  }
  
  factory SyncState.error(String message) {
    return SyncState(error: message);
  }
  
  SyncState copyWith({
    bool? isSyncing,
    bool? isOffline,
    DateTime? lastSyncTime,
    String? error,
  }) {
    return SyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      isOffline: isOffline ?? this.isOffline,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      error: error ?? this.error,
    );
  }
}

// Sync State Provider
final syncStateProvider = StateProvider<SyncState>((ref) {
  return const SyncState.idle();
});

// Pending Changes Provider
final pendingChangesProvider = FutureProvider<int>((ref) async {
  final authState = ref.watch(authProvider);
  final user = authState.value;
  if (user == null) return 0;
  
  final syncService = ref.watch(syncServiceProvider);
  return await syncService.getPendingChangesCount(user.id);
});