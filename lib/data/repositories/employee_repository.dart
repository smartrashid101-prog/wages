import 'package:uuid/uuid.dart';
import '../local/dao/employee_dao.dart';
import '../remote/supabase/supabase_client.dart';

// Simple Employee class - inline to avoid import issues
class RepoEmployee {
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
  
  RepoEmployee({
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
  
  RepoEmployee copyWith({
    String? id,
    String? userId,
    String? name,
    int? hourlyRateCents,
    int? overtimeRateCents,
    double? overtimeMultiplier,
    String? notes,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return RepoEmployee(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      hourlyRateCents: hourlyRateCents ?? this.hourlyRateCents,
      overtimeRateCents: overtimeRateCents ?? this.overtimeRateCents,
      overtimeMultiplier: overtimeMultiplier ?? this.overtimeMultiplier,
      notes: notes ?? this.notes,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'name': name,
    'hourly_rate_cents': hourlyRateCents,
    'overtime_rate_cents': overtimeRateCents,
    'overtime_multiplier': overtimeMultiplier,
    'notes': notes,
    'active': active,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'deleted_at': deletedAt?.toIso8601String(),
  };
  
  factory RepoEmployee.fromJson(Map<String, dynamic> json) => RepoEmployee(
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
  );
  
  // Convert to DaoEmployee for local storage
  DaoEmployee toDaoEmployee() {
    return DaoEmployee(
      id: id,
      userId: userId,
      name: name,
      hourlyRateCents: hourlyRateCents,
      overtimeRateCents: overtimeRateCents,
      overtimeMultiplier: overtimeMultiplier,
      notes: notes,
      active: active,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }
  
  // Create from DaoEmployee
  factory RepoEmployee.fromDaoEmployee(DaoEmployee dao) {
    return RepoEmployee(
      id: dao.id,
      userId: dao.userId,
      name: dao.name,
      hourlyRateCents: dao.hourlyRateCents,
      overtimeRateCents: dao.overtimeRateCents,
      overtimeMultiplier: dao.overtimeMultiplier,
      notes: dao.notes,
      active: dao.active,
      createdAt: dao.createdAt,
      updatedAt: dao.updatedAt,
      deletedAt: dao.deletedAt,
    );
  }
}

class EmployeeRepository {
  final EmployeeDao _localDao = EmployeeDao();
  final AppSupabaseClient _supabase = AppSupabaseClient(); // ✅ FIXED: Use AppSupabaseClient
  
  Future<void> addEmployee(RepoEmployee employee) async {
    // Generate ID if not provided
    final id = employee.id.isNotEmpty ? employee.id : const Uuid().v4();
    final newEmployee = employee.copyWith(id: id);
    
    // Convert to DaoEmployee and save locally with pending status
    await _localDao.insertEmployee(
      newEmployee.toDaoEmployee(),
      syncStatus: 'pending',
    );
  }
  
  Future<void> updateEmployee(RepoEmployee employee) async {
    await _localDao.updateEmployee(
      employee.toDaoEmployee(),
      syncStatus: 'pending',
    );
  }
  
  Future<void> deleteEmployee(String id, String userId) async {
    await _localDao.softDeleteEmployee(id, userId);
  }
  
  Future<List<RepoEmployee>> getEmployeesByUserId(String userId) async {
    final daoEmployees = await _localDao.getEmployeesByUserId(userId);
    return daoEmployees.map((dao) => RepoEmployee.fromDaoEmployee(dao)).toList();
  }
  
  Future<RepoEmployee?> getEmployeeById(String id, String userId) async {
    final daoEmployee = await _localDao.getEmployeeById(id, userId);
    if (daoEmployee == null) return null;
    return RepoEmployee.fromDaoEmployee(daoEmployee);
  }
  
  Future<List<RepoEmployee>> getPendingEmployees(String userId) async {
    final daoEmployees = await _localDao.getPendingEmployees(userId);
    return daoEmployees.map((dao) => RepoEmployee.fromDaoEmployee(dao)).toList();
  }
  
  Future<void> markSynced(String id, String userId) async {
    await _localDao.markSynced(id, userId);
  }
  
  Future<void> markSyncFailed(String id, String userId, String error) async {
    await _localDao.markSyncFailed(id, userId, error);
  }
  
  // Cloud operations
  Future<void> uploadToCloud(RepoEmployee employee) async {
    await _supabase.from('employees').insert(employee.toJson());
  }
  
  Future<void> updateInCloud(RepoEmployee employee) async {
    await _supabase
        .from('employees')
        .update(employee.toJson())
        .eq('id', employee.id);
  }
  
  Future<void> deleteInCloud(String id) async {
    await _supabase
        .from('employees')
        .update({'deleted_at': DateTime.now().toIso8601String()})
        .eq('id', id);
  }
  
  Future<List<RepoEmployee>> fetchFromCloud(String userId) async {
    try {
      final response = await _supabase
          .from('employees')
          .select()
          .eq('user_id', userId);
      
      // Filter out deleted records in Dart
      return (response as List)
          .where((json) => json['deleted_at'] == null)
          .map((json) => RepoEmployee.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching from cloud: $e');
      return [];
    }
  }
}