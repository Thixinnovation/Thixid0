// lib/services/payment_service.dart
import 'dart:async';
import 'package:thix_id/services/wallet_service.dart';

class PaymentService {
  final WalletService _walletService = WalletService();

  Future<PaymentResult> processPayment({
    required String merchantId,
    required String merchantName,
    required double amount,
    String? reference,
  }) async {
    try {
      // Vérifier le solde
      final hasFunds = await _walletService.checkSufficientFundsAsync(amount);
      
      if (!hasFunds) {
        return PaymentResult(
          success: false,
          message: 'Solde insuffisant',
          errorCode: 'INSUFFICIENT_FUNDS',
        );
      }

      // Débiter le compte
      await _walletService.debit(amount);

      // Ici: appel API pour notifier le marchand
      await _notifyMerchant(merchantId, amount, reference);

      return PaymentResult(
        success: true,
        message: 'Paiement effectué avec succès',
        transactionId: _generateTransactionId(),
        amount: amount,
        merchantName: merchantName,
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        message: 'Erreur lors du paiement',
        errorCode: 'PAYMENT_ERROR',
        details: e.toString(),
      );
    }
  }

  Future<PaymentResult> processQrPayment(String qrData) async {
    try {
      // Parser le QR code
      final qrInfo = _parseQrCode(qrData);
      
      if (qrInfo == null) {
        return PaymentResult(
          success: false,
          message: 'QR code invalide',
          errorCode: 'INVALID_QR',
        );
      }

      // Traiter le paiement
      return await processPayment(
        merchantId: qrInfo['merchantId']!,
        merchantName: qrInfo['merchantName']!,
        amount: qrInfo['amount'] ?? 0,
        reference: qrInfo['reference'],
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        message: 'Erreur lors du scan',
        errorCode: 'SCAN_ERROR',
        details: e.toString(),
      );
    }
  }

  Future<void> _notifyMerchant(String merchantId, double amount, String? reference) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Logique d'envoi au marchand
  }

  String _generateTransactionId() {
    return 'TXN_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  Map<String, String>? _parseQrCode(String qrData) {
    // Format attendu: merchantId|merchantName|amount|reference
    try {
      final parts = qrData.split('|');
      if (parts.length < 2) return null;
      
      return {
        'merchantId': parts[0],
        'merchantName': parts[1],
        'amount': parts.length > 2 ? parts[2] : '0',
        'reference': parts.length > 3 ? parts[3] : '',
      };
    } catch (e) {
      return null;
    }
  }
}

class PaymentResult {
  final bool success;
  final String message;
  final String? errorCode;
  final String? transactionId;
  final double? amount;
  final String? merchantName;
  final String? details;

  PaymentResult({
    required this.success,
    required this.message,
    this.errorCode,
    this.transactionId,
    this.amount,
    this.merchantName,
    this.details,
  });
}
