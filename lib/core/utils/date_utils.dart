import 'package:intl/intl.dart';

class DateUtils {
  static String formatDate(DateTime date, {String pattern = 'yyyy-MM-dd'}) {
    return DateFormat(pattern).format(date);
  }
  
  static String formatDateTime(DateTime date, {String pattern = 'yyyy-MM-dd HH:mm'}) {
    return DateFormat(pattern).format(date);
  }
  
  static DateTime parseDate(String dateStr, {String pattern = 'yyyy-MM-dd'}) {
    return DateFormat(pattern).parse(dateStr);
  }
  
  static DateTime getStartOfWeek(DateTime date) {
    final day = date.weekday;
    final diff = day - 1; // Monday is 1
    return DateTime(date.year, date.month, date.day - diff);
  }
  
  static DateTime getEndOfWeek(DateTime date) {
    final start = getStartOfWeek(date);
    return DateTime(start.year, start.month, start.day + 6);
  }
  
  static DateTime getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }
  
  static DateTime getEndOfMonth(DateTime date) {
    final lastDay = DateTime(date.year, date.month + 1, 0);
    return lastDay;
  }
  
  static DateTime getStartOfYear(DateTime date) {
    return DateTime(date.year, 1, 1);
  }
  
  static DateTime getEndOfYear(DateTime date) {
    return DateTime(date.year, 12, 31);
  }
  
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
  
  static bool isSameWeek(DateTime a, DateTime b) {
    final startA = getStartOfWeek(a);
    final startB = getStartOfWeek(b);
    return isSameDay(startA, startB);
  }
  
  static bool isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }
}