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
  
  Employee copyWith({
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
    return Employee(
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
  
  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
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
    deletedAt: json['deleted_at'] != null 
        ? DateTime.parse(json['deleted_at']) 
        : null,
  );
}