class MoneyUtils {
  // Convert pounds to pence (minor units)
  static int poundsToCents(double pounds) {
    return (pounds * 100).round();
  }
  
  // Convert pence to pounds
  static double centsToPounds(int cents) {
    return cents / 100;
  }
  
  // Format as currency string
  static String formatCurrency(int cents, {String currencySymbol = '£'}) {
    final pounds = centsToPounds(cents);
    return '$currencySymbol${pounds.toStringAsFixed(2)}';
  }
  
  // Calculate pay from minutes and rate per hour
  static int calculatePay(int minutes, int rateCentsPerHour) {
    // pay = round(minutes × rate / 60)
    return ((minutes * rateCentsPerHour) / 60).round();
  }
  
  // Validate cents is not negative
  static bool isValidCents(int cents) {
    return cents >= 0;
  }
  
  // Parse currency string to cents
  static int? parseCurrencyToCents(String value, {String currencySymbol = '£'}) {
    final cleaned = value.replaceAll(currencySymbol, '').replaceAll(',', '').trim();
    if (cleaned.isEmpty) return null;
    
    try {
      final pounds = double.parse(cleaned);
      return poundsToCents(pounds);
    } catch (_) {
      return null;
    }
  }
}