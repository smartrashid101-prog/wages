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
  
  AppSettings copyWith({
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
    return AppSettings(
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
  
  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    id: json['id'],
    userId: json['user_id'],
    currency: json['currency'],
    defaultHourlyRateCents: json['default_hourly_rate_cents'],
    defaultOvertimeMultiplier: (json['default_overtime_multiplier'] as num).toDouble(),
    defaultBreakMinutes: json['default_break_minutes'],
    defaultRegularThresholdMinutes: json['default_regular_threshold_minutes'],
    timeFormat: json['time_format'],
    createdAt: DateTime.parse(json['created_at']),
    updatedAt: DateTime.parse(json['updated_at']),
  );
}