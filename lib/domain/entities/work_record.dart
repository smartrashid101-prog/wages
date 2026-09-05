class WorkRecord {
  final String id;
  final String userId;
  final String employeeId;
  final DateTime workDate;
  final String startTime;
  final String endTime;
  final int breakMinutes;
  final String overtimeMode;
  final int regularMinutes;
  final int overtimeMinutes;
  final int totalMinutes;
  final int hourlyRateCents;
  final int overtimeRateCents;
  final int bonusCents;
  final int deductionsCents;
  final int regularPayCents;
  final int overtimePayCents;
  final int grossPayCents;
  final int netPayCents;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  
  WorkRecord({
    required this.id,
    required this.userId,
    required this.employeeId,
    required this.workDate,
    required this.startTime,
    required this.endTime,
    required this.breakMinutes,
    required this.overtimeMode,
    required this.regularMinutes,
    required this.overtimeMinutes,
    required this.totalMinutes,
    required this.hourlyRateCents,
    required this.overtimeRateCents,
    required this.bonusCents,
    required this.deductionsCents,
    required this.regularPayCents,
    required this.overtimePayCents,
    required this.grossPayCents,
    required this.netPayCents,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  
  WorkRecord copyWith({
    String? id,
    String? userId,
    String? employeeId,
    DateTime? workDate,
    String? startTime,
    String? endTime,
    int? breakMinutes,
    String? overtimeMode,
    int? regularMinutes,
    int? overtimeMinutes,
    int? totalMinutes,
    int? hourlyRateCents,
    int? overtimeRateCents,
    int? bonusCents,
    int? deductionsCents,
    int? regularPayCents,
    int? overtimePayCents,
    int? grossPayCents,
    int? netPayCents,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return WorkRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      employeeId: employeeId ?? this.employeeId,
      workDate: workDate ?? this.workDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      breakMinutes: breakMinutes ?? this.breakMinutes,
      overtimeMode: overtimeMode ?? this.overtimeMode,
      regularMinutes: regularMinutes ?? this.regularMinutes,
      overtimeMinutes: overtimeMinutes ?? this.overtimeMinutes,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      hourlyRateCents: hourlyRateCents ?? this.hourlyRateCents,
      overtimeRateCents: overtimeRateCents ?? this.overtimeRateCents,
      bonusCents: bonusCents ?? this.bonusCents,
      deductionsCents: deductionsCents ?? this.deductionsCents,
      regularPayCents: regularPayCents ?? this.regularPayCents,
      overtimePayCents: overtimePayCents ?? this.overtimePayCents,
      grossPayCents: grossPayCents ?? this.grossPayCents,
      netPayCents: netPayCents ?? this.netPayCents,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'employee_id': employeeId,
    'work_date': workDate.toIso8601String().split('T')[0],
    'start_time': startTime,
    'end_time': endTime,
    'break_minutes': breakMinutes,
    'overtime_mode': overtimeMode,
    'regular_minutes': regularMinutes,
    'overtime_minutes': overtimeMinutes,
    'total_minutes': totalMinutes,
    'hourly_rate_cents': hourlyRateCents,
    'overtime_rate_cents': overtimeRateCents,
    'bonus_cents': bonusCents,
    'deductions_cents': deductionsCents,
    'regular_pay_cents': regularPayCents,
    'overtime_pay_cents': overtimePayCents,
    'gross_pay_cents': grossPayCents,
    'net_pay_cents': netPayCents,
    'notes': notes,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'deleted_at': deletedAt?.toIso8601String(),
  };
  
  factory WorkRecord.fromJson(Map<String, dynamic> json) => WorkRecord(
    id: json['id'],
    userId: json['user_id'],
    employeeId: json['employee_id'],
    workDate: DateTime.parse(json['work_date']),
    startTime: json['start_time'],
    endTime: json['end_time'],
    breakMinutes: json['break_minutes'],
    overtimeMode: json['overtime_mode'],
    regularMinutes: json['regular_minutes'],
    overtimeMinutes: json['overtime_minutes'],
    totalMinutes: json['total_minutes'],
    hourlyRateCents: json['hourly_rate_cents'],
    overtimeRateCents: json['overtime_rate_cents'],
    bonusCents: json['bonus_cents'],
    deductionsCents: json['deductions_cents'],
    regularPayCents: json['regular_pay_cents'],
    overtimePayCents: json['overtime_pay_cents'],
    grossPayCents: json['gross_pay_cents'],
    netPayCents: json['net_pay_cents'],
    notes: json['notes'],
    createdAt: DateTime.parse(json['created_at']),
    updatedAt: DateTime.parse(json['updated_at']),
    deletedAt: json['deleted_at'] != null 
        ? DateTime.parse(json['deleted_at']) 
        : null,
  );
}