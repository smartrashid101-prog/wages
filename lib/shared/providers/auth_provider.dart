import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class User {
  final String id;
  final String email;
  final String name;

  User({
    required this.id,
    required this.email,
    required this.name,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] ?? '',
        email: json['email'] ?? '',
        name: json['name'] ?? 'User',
      );
}

// 🔑 YOUR SUPABASE SERVICE ROLE KEY
const String supabaseServiceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVkZHJ4dW5scnJoaHpmbHVnbXR3Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4ODI1ODkxOCwiZXhwIjoyMTAzODM0OTE4fQ.PPB78CPqv2YfmadrJDxUyBfDSdRoYNCpbvlOKAefrtM';

// Supabase URL
const String supabaseUrl = 'https://uddrxunlrrhhzflugmtw.supabase.co';

/// Gets the currently logged-in user and their profile.
final authProvider = FutureProvider<User?>((ref) async {
  final supabase = Supabase.instance.client;

  try {
    print('🔍 Checking authentication...');

    final session = supabase.auth.currentSession;

    if (session == null) {
      print('❌ No active session');
      return null;
    }

    final authUser = session.user;

    print('✅ Session found');
    print('👤 User ID: ${authUser.id}');
    print('📧 Email: ${authUser.email}');

    // Get profile
    final profile = await supabase
        .from('profiles')
        .select()
        .eq('id', authUser.id)
        .maybeSingle();

    if (profile == null) {
      print('⚠️ Profile not found - creating profile...');

      final name =
          authUser.userMetadata?['name']?.toString() ??
          authUser.email?.split('@').first ??
          'User';

      await supabase.from('profiles').insert({
        'id': authUser.id,
        'email': authUser.email,
        'name': name,
      });

      print('✅ Profile created');

      // Create default settings
      try {
        await supabase.from('settings').insert({
          'user_id': authUser.id,
          'currency': 'GBP',
          'default_hourly_rate_cents': 1200,
          'default_overtime_multiplier': 1.5,
          'default_break_minutes': 30,
          'default_regular_threshold_minutes': 480,
          'time_format': '24h',
        });

        print('✅ Default settings created');
      } catch (e) {
        print('⚠️ Settings creation warning: $e');
      }

      return User(
        id: authUser.id,
        email: authUser.email ?? '',
        name: name,
      );
    }

    print('✅ Profile found: ${profile['name']}');

    // Check whether settings exist
    try {
      final settings = await supabase
          .from('settings')
          .select()
          .eq('user_id', authUser.id)
          .maybeSingle();

      if (settings == null) {
        print('⚠️ Settings missing - creating default settings...');

        await supabase.from('settings').insert({
          'user_id': authUser.id,
          'currency': 'GBP',
          'default_hourly_rate_cents': 1200,
          'default_overtime_multiplier': 1.5,
          'default_break_minutes': 30,
          'default_regular_threshold_minutes': 480,
          'time_format': '24h',
        });

        print('✅ Default settings created');
      }
    } catch (e) {
      print('⚠️ Settings check warning: $e');
    }

    return User(
      id: profile['id'] ?? authUser.id,
      email: profile['email'] ?? authUser.email ?? '',
      name: profile['name'] ?? 'User',
    );
  } catch (e, stack) {
    print('❌ Auth/profile error: $e');
    print(stack);

    return null;
  }
});

/// Authentication state notifier.
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final Ref ref;

  AuthNotifier(this.ref) : super(const AsyncValue.loading()) {
    _checkAuth();
  }

  /// Check whether a user is already logged in.
  Future<void> _checkAuth() async {
    try {
      final user = await ref.read(authProvider.future);

      print('📊 Current user: $user');

      state = AsyncValue.data(user);
    } catch (e, stack) {
      print('❌ Auth check error: $e');

      state = AsyncValue.error(e, stack);
    }
  }

  /// Sign in with email and password.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    try {
      final supabase = Supabase.instance.client;

      final cleanEmail = email.trim();

      print('📝 Signing in: $cleanEmail');

      final response = await supabase.auth.signInWithPassword(
        email: cleanEmail,
        password: password,
      );

      if (response.user == null || response.session == null) {
        throw Exception(
          'Login failed. Please check your email and password.',
        );
      }

      print('✅ Login successful');
      print('👤 User ID: ${response.user!.id}');
      print('📧 Email: ${response.user!.email}');

      // Force authProvider to reload the profile.
      ref.invalidate(authProvider);

      final user = await ref.read(authProvider.future);

      if (user == null) {
        throw Exception(
          'Login succeeded, but your profile could not be loaded.',
        );
      }

      print('✅ User loaded: ${user.name}');

      state = AsyncValue.data(user);
    } on AuthException catch (e, stack) {
      print('❌ Supabase login error: ${e.message}');

      state = AsyncValue.error(
        Exception(e.message),
        stack,
      );
    } catch (e, stack) {
      print('❌ Login error: $e');

      state = AsyncValue.error(e, stack);
    }
  }

  /// Register a new account.
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    state = const AsyncValue.loading();

    try {
      final supabase = Supabase.instance.client;

      final cleanEmail = email.trim();
      final cleanName = name.trim();

      print('📝 Signing up: $cleanEmail');

      final response = await supabase.auth.signUp(
        email: cleanEmail,
        password: password,
        data: {
          'name': cleanName,
        },
      );

      if (response.user == null) {
        throw Exception('Sign up failed.');
      }

      print('✅ Auth user created: ${response.user!.id}');

      // If Supabase immediately gives us a session,
      // create the profile now.
      if (response.session != null) {
        try {
          await supabase.from('profiles').upsert({
            'id': response.user!.id,
            'email': cleanEmail,
            'name': cleanName,
          });

          print('✅ Profile created');
        } catch (e) {
          print('⚠️ Profile creation warning: $e');
        }

        try {
          await supabase.from('settings').upsert({
            'user_id': response.user!.id,
            'currency': 'GBP',
            'default_hourly_rate_cents': 1200,
            'default_overtime_multiplier': 1.5,
            'default_break_minutes': 30,
            'default_regular_threshold_minutes': 480,
            'time_format': '24h',
          });

          print('✅ Settings created');
        } catch (e) {
          print('⚠️ Settings creation warning: $e');
        }

        ref.invalidate(authProvider);

        final user = await ref.read(authProvider.future);

        state = AsyncValue.data(user);
      } else {
        // Email confirmation is probably enabled.
        print('📧 Email confirmation required');

        state = const AsyncValue.data(null);
      }
    } on AuthException catch (e, stack) {
      print('❌ Supabase signup error: ${e.message}');

      state = AsyncValue.error(
        Exception(e.message),
        stack,
      );
    } catch (e, stack) {
      print('❌ Signup error: $e');

      state = AsyncValue.error(e, stack);
    }
  }

  /// Sign out.
  Future<void> signOut() async {
    try {
      final supabase = Supabase.instance.client;

      await supabase.auth.signOut();

      ref.invalidate(authProvider);

      state = const AsyncValue.data(null);

      print('✅ Signed out');
    } catch (e, stack) {
      print('❌ Sign out error: $e');

      state = AsyncValue.error(e, stack);
    }
  }

  // ============================================================
  // ✅ OTP PASSWORD RESET
  // ============================================================

  /// Send OTP to user's email using Gmail SMTP
  Future<void> sendPasswordResetOTP({required String email}) async {
    try {
      final supabase = Supabase.instance.client;
      final cleanEmail = email.trim();

      print('📝 Sending password reset OTP to: $cleanEmail');

      // ✅ Generate 6-digit OTP
      final otp = _generateOTP();

      // ✅ Store OTP in Supabase
      await supabase.from('password_reset_otps').upsert({
        'email': cleanEmail,
        'otp': otp,
        'expires_at': DateTime.now()
            .add(const Duration(minutes: 10))
            .toIso8601String(),
      });

      // ✅ Send email via Gmail SMTP
      await _sendOTPEmail(cleanEmail, otp);

      print('✅ OTP sent successfully to: $cleanEmail');
    } catch (e) {
      print('❌ Send OTP error: $e');
      // Show OTP in console as fallback
      final otp = _generateOTP();
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('⚠️ Email sending failed. Check your Gmail credentials.');
      print('🔑 YOUR OTP CODE: $otp');
      print('📧 Email: $email');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      try {
        final supabase = Supabase.instance.client;
        await supabase.from('password_reset_otps').upsert({
          'email': email.trim(),
          'otp': otp,
          'expires_at': DateTime.now()
              .add(const Duration(minutes: 10))
              .toIso8601String(),
        });
      } catch (_) {}
    }
  }

  /// Send OTP email via Gmail SMTP using mailer package
  Future<void> _sendOTPEmail(String email, String otp) async {
    try {
      const String gmailEmail = 'smartrashid101@gmail.com';
      const String gmailPassword = 'isgc wssj albf fxzg';

      print('📤 Sending email via Gmail SMTP...');
      print('📧 To: $email');

      final smtpServer = gmail(gmailEmail, gmailPassword);

      final message = Message()
        ..from = Address(gmailEmail, 'WAGES')
        ..recipients.add(email)
        ..subject = '🔐 WAGES - Password Reset OTP'
        ..text = '''
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔐 WAGES Password Reset

You requested to reset your password.

🔑 YOUR OTP CODE: $otp

This code expires in 10 minutes.

If you didn't request this, please ignore this email.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WAGES - Hours & Wages Calculator
''';

      await send(message, smtpServer);
      print('✅ OTP email sent successfully');
    } catch (e) {
      print('❌ SMTP error: $e');
      rethrow;
    }
  }

  /// Generate 6-digit OTP
  String _generateOTP() {
    final random = DateTime.now().millisecondsSinceEpoch;
    final otp = (random % 900000 + 100000).toString();
    return otp;
  }

  /// ✅ FIXED: Verify OTP and update password using Auth Admin API directly
  /// ✅ FIXED: Verify OTP with email AND update password
Future<void> resetPasswordWithOTP({
  required String email,
  required String otp,
  required String newPassword,
}) async {
  try {
    final supabase = Supabase.instance.client;
    final cleanEmail = email.trim().toLowerCase();
    final cleanOtp = otp.trim();

    print('📝 Verifying OTP for $cleanEmail...');

    // ✅ 1. Verify OTP with email AND OTP (SECURE)
    final response = await supabase
        .from('password_reset_otps')
        .select()
        .eq('email', cleanEmail)  // ✅ MUST check email!
        .eq('otp', cleanOtp)
        .gte('expires_at', DateTime.now().toIso8601String())
        .maybeSingle();

    if (response == null) {
      throw Exception('Invalid or expired OTP. Please request a new one.');
    }

    print('✅ OTP verified for email: $cleanEmail');

    // ✅ 2. Get user from Auth Admin API
    print('📤 Getting user from Auth Admin API...');
    
    final userListResponse = await http.get(
      Uri.parse('$supabaseUrl/auth/v1/admin/users?email=$cleanEmail'),
      headers: {
        'Authorization': 'Bearer $supabaseServiceRoleKey',
        'apikey': supabaseServiceRoleKey,
        'Content-Type': 'application/json',
      },
    );

    if (userListResponse.statusCode != 200) {
      print('❌ Auth Admin API error: ${userListResponse.statusCode}');
      print('❌ Response: ${userListResponse.body}');
      throw Exception('Failed to find user. Please try again.');
    }

    final userListData = jsonDecode(userListResponse.body);
    final users = userListData['users'] as List?;

    if (users == null || users.isEmpty) {
      throw Exception('User not found with this email.');
    }

    final userId = users[0]['id'];
    print('✅ User found in Auth: $userId');

    // ✅ 3. Update password using Supabase Auth Admin API
    print('📤 Updating password via Admin API...');
    
    final updateResponse = await http.put(
      Uri.parse('$supabaseUrl/auth/v1/admin/users/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $supabaseServiceRoleKey',
        'apikey': supabaseServiceRoleKey,
      },
      body: jsonEncode({
        'password': newPassword,
      }),
    );

    if (updateResponse.statusCode != 200 && updateResponse.statusCode != 201) {
      print('❌ Admin API error: ${updateResponse.statusCode}');
      print('❌ Response: ${updateResponse.body}');
      throw Exception('Failed to update password. Please try again.');
    }

    print('✅ Password updated successfully via Admin API');

    // ✅ 4. Delete used OTP
    await supabase
        .from('password_reset_otps')
        .delete()
        .eq('email', cleanEmail)
        .eq('otp', cleanOtp);

    print('✅ Password reset completed successfully!');
  } catch (e) {
    print('❌ Reset password error: $e');
    throw Exception(e.toString());
  }
}
}