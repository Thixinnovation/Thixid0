// lib/services/transfer_service.dart
import 'dart:async';
import 'package:thix_id/services/wallet_service.dart';

class TransferService {
  final WalletService _walletService = WalletService();

  Future<TransferResult> sendTransfer({
    required String recipientPhone,
    required String recipientName,
    required double amount,
    String? note,
  }) async {
    try {
      // Vérifier le solde
      if (!_walletService.hasSufficientFunds(amount)) {
        return TransferResult(
          success: false,
          message: 'Solde insuffisant',
          errorCode: 'INSUFFICIENT_FUNDS',
        );
      }

      // Vérifier le montant minimum
      if (amount < 100) {
        return TransferResult(
          success: false,
          message: 'Montant minimum: 100 FCFA',
          errorCode: 'MINIMUM_AMOUNT',
        );
      }

      // Vérifier le montant maximum
      if (amount > 1000000) {
        return TransferResult(
          success: false,
          message: 'Montant maximum par virement: 1 000 000 FCFA',
          errorCode: 'MAXIMUM_AMOUNT',
        );
      }

      // Débiter le compte
      await _walletService.debit(amount);

      // Ici: appel API pour envoyer le virement
      await _processTransfer(recipientPhone, amount, note);

      return TransferResult(
        success: true,
        message: 'Virement effectué avec succès',
        transactionId: _generateTransactionId(),
        amount: amount,
        recipientName: recipientName,
        recipientPhone: recipientPhone,
      );
    } catch (e) {
      return TransferResult(
        success: false,
        message: 'Erreur lors du virement',
        errorCode: 'TRANSFER_ERROR',
        details: e.toString(),
      );
    }
  }

  Future<TransferResult> sendInternationalTransfer({
    required String beneficiaryName,
    required String iban,
    required String bic,
    required String country,
    required String currency,
    required double amount,
  }) async {
    try {
      final rate = await getExchangeRate(currency);
      final convertedAmount = amount / rate;
      
      final fees = amount * 0.02;
      final totalAmount = amount + fees;

      if (!_walletService.hasSufficientFunds(totalAmount)) {
        return TransferResult(
          success: false,
          message: 'Solde insuffisant (frais inclus)',
          errorCode: 'INSUFFICIENT_FUNDS',
        );
      }

      await _walletService.debit(totalAmount);
      await _processInternationalTransfer(beneficiaryName, iban, bic, convertedAmount, currency);

      return TransferResult(
        success: true,
        message: 'Virement international envoyé',
        transactionId: _generateTransactionId(),
        amount: amount,
        convertedAmount: convertedAmount,
        currency: currency,
        fees: fees,
      );
    } catch (e) {
      return TransferResult(
        success: false,
        message: 'Erreur lors du virement international',
        errorCode: 'INTERNATIONAL_ERROR',
        details: e.toString(),
      );
    }
  }

  Future<double> getExchangeRate(String currency) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final rates = {
      'EUR': 655.96,
      'USD': 610.00,
      'CAD': 445.00,
      'GBP': 770.00,
      'CHF': 680.00,
    };
    
    return rates[currency] ?? 600.0;
  }

  Future<List<Map<String, String>>> getRecentContacts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return [
      {'name': 'Marie Claire', 'phone': '6XXXXXXXX', 'avatar': 'MC'},
      {'name': 'Paul Biya', 'phone': '6XXXXXXXX', 'avatar': 'PB'},
      {'name': 'Sandra N.', 'phone': '6XXXXXXXX', 'avatar': 'SN'},
      {'name': 'François D.', 'phone': '6XXXXXXXX', 'avatar': 'FD'},
    ];
  }

  Future<void> _processTransfer(String phone, double amount, String? note) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Appel API
  }

  Future<void> _processInternationalTransfer(
    String name, String iban, String bic, double amount, String currency,
  ) async {
    await Future.delayed(const Duration(seconds: 1));
    // Appel API
  }

  String _generateTransactionId() {
    return 'TRF_${DateTime.now().millisecondsSinceEpoch}';
  }
}

class TransferResult {
  final bool success;
  final String message;
  final String? errorCode;
  final String? transactionId;
  final double? amount;
  final double? convertedAmount;
  final String? currency;
  final double? fees;
  final String? recipientName;
  final String? recipientPhone;
  final String? details;

  TransferResult({
    required this.success,
    required this.message,
    this.errorCode,
    this.transactionId,
    this.amount,
    this.convertedAmount,
    this.currency,
    this.fees,
    this.recipientName,
    this.recipientPhone,
    this.details,
  });
}
