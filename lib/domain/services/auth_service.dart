import 'package:supabase_flutter/supabase_flutter.dart';

// Simple User class - no need to import from domain
class AuthUser {
  final String id;
  final String email;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  AuthUser({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
  
  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id: json['id'],
    email: json['email'],
    name: json['name'],
    createdAt: DateTime.parse(json['created_at']),
    updatedAt: DateTime.parse(json['updated_at']),
  );
}

class AuthService {
  SupabaseClient get _supabase => Supabase.instance.client;
  
  Future<AuthUser?> getCurrentUser() async {
    final session = _supabase.auth.currentSession;
    if (session == null) return null;
    
    final user = session.user;
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();
      
      return AuthUser(
        id: response['id'],
        email: response['email'],
        name: response['name'],
        createdAt: DateTime.parse(response['created_at']),
        updatedAt: DateTime.parse(response['updated_at']),
      );
    } catch (e) {
      // If profile doesn't exist, create one
      await _createProfile(user.id, user.email!);
      return AuthUser(
        id: user.id,
        email: user.email!,
        name: user.email!.split('@').first,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }
  
  Future<void> _createProfile(String userId, String email) async {
    await _supabase.from('profiles').insert({
      'id': userId,
      'email': email,
      'name': email.split('@').first,
    });
  }
  
  Future<AuthUser> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
    
    if (response.user == null) {
      throw Exception('Sign up failed');
    }
    
    // Create profile
    await _supabase.from('profiles').insert({
      'id': response.user!.id,
      'email': email,
      'name': name,
    });
    
    // Create default settings
    await _supabase.from('settings').insert({
      'user_id': response.user!.id,
    });
    
    return AuthUser(
      id: response.user!.id,
      email: email,
      name: name,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
  
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    
    if (response.user == null) {
      throw Exception('Login failed');
    }
    
    final user = response.user!;
    final profileResponse = await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();
    
    return AuthUser(
      id: user.id,
      email: user.email!,
      name: profileResponse['name'],
      createdAt: DateTime.parse(profileResponse['created_at']),
      updatedAt: DateTime.parse(profileResponse['updated_at']),
    );
  }
  
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }
  
  Future<void> updatePassword(String newPassword) async {
    await _supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }
  
  Future<void> updateProfile(String name) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');
    
    await _supabase.from('profiles').update({
      'name': name,
    }).eq('id', user.id);
  }
  
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
  
  Future<void> deleteAccount() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');
    
    // Delete profile (cascading delete will handle related data)
    await _supabase.from('profiles').delete().eq('id', user.id);
    
    // Delete the user account
    // Note: In some versions, admin.deleteUser might not be available
    // If you get an error, you may need to use a Supabase Edge Function
    try {
      await _supabase.auth.admin.deleteUser(user.id);
    } catch (e) {
      // If admin.deleteUser is not available, just delete the profile
      // The user will still exist but won't be able to log in
      print('Note: User account deletion requires Edge Function or admin access');
    }
  }
}