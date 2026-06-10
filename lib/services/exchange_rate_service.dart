// lib/services/exchange_rate_service.dart
import 'dart:async';

class ExchangeRateService {
  static final ExchangeRateService _instance = ExchangeRateService._internal();
  factory ExchangeRateService() => _instance;
  ExchangeRateService._internal();

  final Map<String, double> _rates = {
    'EUR': 655.96,
    'USD': 610.00,
    'CAD': 445.00,
    'GBP': 770.00,
    'CHF': 680.00,
    'CNY': 84.00,
    'NGN': 0.40,
  };

  Future<double> getRate(String currencyCode) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final rate = _rates[currencyCode.toUpperCase()];
    if (rate == null) {
      throw Exception('Devise non supportée: $currencyCode');
    }
    return rate;
  }

  Future<double> convert({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    if (fromCurrency == toCurrency) return amount;
    
    final fromRate = await getRate(fromCurrency);
    final toRate = await getRate(toCurrency);
    
    // Convertir d'abord en FCFA, puis dans la devise cible
    final inFcfa = amount * fromRate;
    final result = inFcfa / toRate;
    
    return double.parse(result.toStringAsFixed(2));
  }

  Future<List<ExchangeRate>> getAllRates() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return _rates.entries.map((entry) {
      return ExchangeRate(
        currencyCode: entry.key,
        currencyName: _getCurrencyName(entry.key),
        rate: entry.value,
        flag: _getFlagEmoji(entry.key),
      );
    }).toList();
  }

  String _getCurrencyName(String code) {
    switch (code) {
      case 'EUR': return 'Euro';
      case 'USD': return 'Dollar américain';
      case 'CAD': return 'Dollar canadien';
      case 'GBP': return 'Livre sterling';
      case 'CHF': return 'Franc suisse';
      case 'CNY': return 'Yuan chinois';
      case 'NGN': return 'Naira nigérian';
      default: return code;
    }
  }

  String _getFlagEmoji(String code) {
    switch (code) {
      case 'EUR': return '🇪🇺';
      case 'USD': return '🇺🇸';
      case 'CAD': return '🇨🇦';
      case 'GBP': return '🇬🇧';
      case 'CHF': return '🇨🇭';
      case 'CNY': return '🇨🇳';
      case 'NGN': return '🇳🇬';
      default: return '🏳️';
    }
  }
}

class ExchangeRate {
  final String currencyCode;
  final String currencyName;
  final double rate;
  final String flag;

  ExchangeRate({
    required this.currencyCode,
    required this.currencyName,
    required this.rate,
    required this.flag,
  });
}
