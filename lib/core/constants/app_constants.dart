class AppConstants {
  static const String appName = 'WAGES';
  static const String appVersion = '1.0.0';
  
  // Database
  static const String databaseName = 'wages.db';
  static const int databaseVersion = 1;
  
  // Sync
  static const int syncIntervalMinutes = 5;
  static const int maxSyncRetries = 3;
  
  // Default Values
  static const int defaultRegularThresholdMinutes = 480; // 8 hours
  static const int defaultBreakMinutes = 30;
  static const int defaultHourlyRateCents = 1200; // £12.00
  
  // Validation
  static const int maxShiftHours = 24;
  static const int minMinutes = 0;
  static const int maxMinutes = 1440;
  
  // Currency
  static const String defaultCurrency = 'GBP';
  
  // Time Formats
  static const String timeFormat24h = '24h';
  static const String timeFormat12h = '12h';
  
  // Overtime Modes
  static const String overtimeAutomatic = 'automatic';
  static const String overtimeManual = 'manual';
  static const String overtimeNone = 'none';
  
  // Sync Status
  static const String syncStatusSynced = 'synced';
  static const String syncStatusPending = 'pending';
  static const String syncStatusFailed = 'failed';
  
  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  
  // Routes
  static const String routeSplash = '/';
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeForgotPassword = '/forgot-password';
  static const String routeMain = '/main';
  static const String routeCalculator = '/calculator';
  static const String routeReports = '/reports';
  static const String routeHistory = '/history';
  static const String routeEmployees = '/employees';
  static const String routeSettings = '/settings';
}