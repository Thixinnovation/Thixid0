// lib/models/exchange_rate_model.dart
class ExchangeRate {
  final String currencyCode;
  final String currencyName;
  final double rate;
  final String flag;
  final double? change24h;

  ExchangeRate({
    required this.currencyCode,
    required this.currencyName,
    required this.rate,
    required this.flag,
    this.change24h,
  });

  String get formattedRate => rate.toStringAsFixed(2);
  
  bool get isPositiveChange => (change24h ?? 0) >= 0;
  
  String get formattedChange {
    if (change24h == null) return '';
    final sign = isPositiveChange ? '+' : '';
    return '$sign${change24h!.toStringAsFixed(2)}%';
  }

  double convertFromFcfa(double amountFcfa) {
    return amountFcfa / rate;
  }

  double convertToFcfa(double amount) {
    return amount * rate;
  }
}

// Mock exchange rates
List<ExchangeRate> mockExchangeRates = [
  ExchangeRate(
    currencyCode: 'EUR',
    currencyName: 'Euro',
    rate: 655.96,
    flag: '🇪🇺',
    change24h: 0.15,
  ),
  ExchangeRate(
    currencyCode: 'USD',
    currencyName: 'Dollar américain',
    rate: 610.00,
    flag: '🇺🇸',
    change24h: -0.08,
  ),
  ExchangeRate(
    currencyCode: 'CAD',
    currencyName: 'Dollar canadien',
    rate: 445.00,
    flag: '🇨🇦',
    change24h: 0.05,
  ),
  ExchangeRate(
    currencyCode: 'GBP',
    currencyName: 'Livre sterling',
    rate: 770.00,
    flag: '🇬🇧',
    change24h: 0.22,
  ),
  ExchangeRate(
    currencyCode: 'CHF',
    currencyName: 'Franc suisse',
    rate: 680.00,
    flag: '🇨🇭',
    change24h: -0.03,
  ),
];
