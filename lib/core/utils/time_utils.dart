class TimeUtils {
  // Parse time string (HH:mm) to minutes since midnight
  static int timeToMinutes(String time) {
    final parts = time.split(':');
    if (parts.length != 2) throw FormatException('Invalid time format');
    
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    
    if (hours < 0 || hours > 23 || minutes < 0 || minutes > 59) {
      throw FormatException('Invalid time values');
    }
    
    return hours * 60 + minutes;
  }
  
  // Convert minutes to time string (HH:mm)
  static String minutesToTime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
  }
  
  // Format duration as hours and minutes
  static String formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours == 0) return '${mins}m';
    if (mins == 0) return '${hours}h';
    return '${hours}h ${mins}m';
  }
  
  // Format duration as decimal hours
  static String formatDecimalHours(int minutes) {
    final decimal = minutes / 60;
    return decimal.toStringAsFixed(2);
  }
  
  // Calculate overnight duration
  static int calculateOvernightDuration(int startMinutes, int endMinutes) {
    if (endMinutes <= startMinutes) {
      return endMinutes + 1440 - startMinutes;
    }
    return endMinutes - startMinutes;
  }
  
  // Get current time string
  static String getCurrentTimeString() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
  
  // Get today's date string
  static String getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}