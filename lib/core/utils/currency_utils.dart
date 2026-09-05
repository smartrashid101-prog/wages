// lib/core/utils/currency_utils.dart

class CurrencyUtils {
  static const Map<String, String> _currencySymbols = {
    'GBP': '£',
    'USD': '\$',
    'EUR': '€',
    'PKR': 'Rs.',
    'INR': '₹',
    'JPY': '¥',
    'AUD': 'A\$',
    'CAD': 'C\$',
    'CHF': 'CHF',
    'CNY': '¥',
    'NZD': 'NZ\$',
    'SEK': 'kr',
    'KRW': '₩',
  };

  static String getCurrencySymbol(String currencyCode) {
    return _currencySymbols[currencyCode.toUpperCase()] ?? '£';
  }

  static String formatCurrency(int cents, String currencyCode) {
    final pounds = cents / 100;
    final symbol = getCurrencySymbol(currencyCode);
    return '$symbol${pounds.toStringAsFixed(2)}';
  }
}