import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_provider.dart';

// Simple Employee class
class Employee {
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
  
  Employee({
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
}

// Employee Repository
final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  return EmployeeRepository();
});

class EmployeeRepository {
  Future<List<Employee>> getEmployeesByUserId(String userId) async {
    try {
      // Get all employees for this user
      final response = await Supabase.instance.client
          .from('employees')
          .select()
          .eq('user_id', userId);
      
      // ✅ FIXED: Filter in Dart instead of Supabase
      return (response as List)
          .where((json) => json['deleted_at'] == null)  // Filter out deleted
          .map((json) => Employee(
            id: json['id'],
            userId: json['user_id'],
            name: json['name'],
            hourlyRateCents: json['hourly_rate_cents'],
            overtimeRateCents: json['overtime_rate_cents'],
            overtimeMultiplier: (json['overtime_multiplier'] as num).toDouble(),
            notes: json['notes'],
            active: json['active'],
            createdAt: DateTime.parse(json['created_at']),
            updatedAt: DateTime.parse(json['updated_at']),
            deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
          ))
          .toList();
    } catch (e) {
      return [];
    }
  }
  
  Future<void> addEmployee(Employee employee) async {
    await Supabase.instance.client.from('employees').insert({
      'id': employee.id,
      'user_id': employee.userId,
      'name': employee.name,
      'hourly_rate_cents': employee.hourlyRateCents,
      'overtime_rate_cents': employee.overtimeRateCents,
      'overtime_multiplier': employee.overtimeMultiplier,
      'notes': employee.notes,
      'active': employee.active,
    });
  }
  
  Future<void> updateEmployee(Employee employee) async {
    await Supabase.instance.client
        .from('employees')
        .update({
          'name': employee.name,
          'hourly_rate_cents': employee.hourlyRateCents,
          'overtime_rate_cents': employee.overtimeRateCents,
          'overtime_multiplier': employee.overtimeMultiplier,
          'notes': employee.notes,
          'active': employee.active,
        })
        .eq('id', employee.id);
  }
  
  Future<void> deleteEmployee(String id, String userId) async {
    await Supabase.instance.client
        .from('employees')
        .update({'deleted_at': DateTime.now().toIso8601String()})
        .eq('id', id)
        .eq('user_id', userId);
  }
}

// Employee List Provider
final employeeListProvider = FutureProvider<List<Employee>>((ref) async {
  final authState = ref.watch(authProvider);
  final user = authState.value;
  if (user == null) return [];
  
  final repository = ref.watch(employeeRepositoryProvider);
  return await repository.getEmployeesByUserId(user.id);
});

// Employee Notifier
final employeeNotifierProvider = StateNotifierProvider<EmployeeNotifier, AsyncValue<List<Employee>>>((ref) {
  return EmployeeNotifier(ref);
});

class EmployeeNotifier extends StateNotifier<AsyncValue<List<Employee>>> {
  final Ref ref;
  
  EmployeeNotifier(this.ref) : super(const AsyncValue.loading()) {
    _loadEmployees();
  }
  
  Future<void> _loadEmployees() async {
    final authState = ref.watch(authProvider);
    final user = authState.value;
    if (user == null) {
      state = const AsyncValue.data([]);
      return;
    }
    
    try {
      final repository = ref.read(employeeRepositoryProvider);
      final employees = await repository.getEmployeesByUserId(user.id);
      state = AsyncValue.data(employees);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<void> addEmployee(Employee employee) async {
    try {
      final repository = ref.read(employeeRepositoryProvider);
      await repository.addEmployee(employee);
      await _loadEmployees();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<void> updateEmployee(Employee employee) async {
    try {
      final repository = ref.read(employeeRepositoryProvider);
      await repository.updateEmployee(employee);
      await _loadEmployees();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<void> deleteEmployee(String id) async {
    try {
      final repository = ref.read(employeeRepositoryProvider);
      final authState = ref.watch(authProvider);
      final user = authState.value;
      if (user == null) throw Exception('User not authenticated');
      
      await repository.deleteEmployee(id, user.id);
      await _loadEmployees();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Employee? getEmployeeById(String id) {
    final currentState = state;
    
    if (currentState is AsyncData<List<Employee>>) {
      try {
        return currentState.value.firstWhere((e) => e.id == id);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}