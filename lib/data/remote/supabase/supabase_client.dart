import 'package:supabase_flutter/supabase_flutter.dart';

class AppSupabaseClient {
  static SupabaseClient? _instance;
  
  static SupabaseClient get instance {
    if (_instance == null) {
      throw Exception('Supabase not initialized');
    }
    return _instance!;
  }
  
  // ✅ FIXED: Use publishableKey instead of anonKey
  static Future<void> initialize({
    required String url,
    required String publishableKey,
  }) async {
    await Supabase.initialize(
      url: url,
      publishableKey: publishableKey,
    );
    _instance = Supabase.instance.client;
  }
  
  SupabaseQueryBuilder from(String table) {
    return instance.from(table);
  }
}