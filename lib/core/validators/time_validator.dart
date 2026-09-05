class TimeValidator {
  static bool isValidTime(String time) {
    if (time.isEmpty) return false;
    
    final pattern = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    if (!pattern.hasMatch(time)) return false;
    
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59;
    } catch (_) {
      return false;
    }
  }
  
  static bool isValidBreak(int breakMinutes, int rawDuration) {
    if (breakMinutes < 0) return false;
    if (breakMinutes > rawDuration) return false;
    return true;
  }
  
  static bool isValidShiftDuration(int minutes) {
    return minutes > 0 && minutes <= 24 * 60;
  }
  
  static bool isValidTimeRange(String start, String end) {
    if (!isValidTime(start) || !isValidTime(end)) return false;
    return true;
  }
  
  static String? validateTimeInput(String value) {
    if (value.isEmpty) return null;
    if (!isValidTime(value)) {
      return 'Please enter a valid time (HH:mm)';
    }
    return null;
  }
}