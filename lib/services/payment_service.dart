// lib/services/payment_service.dart
import 'dart:async';
import 'package:thix_id/services/wallet_service.dart';

class PaymentResult {
  final bool success;
  final String transactionId;
  final String message;
  final String? errorCode;
  final double? amount;
  final String? merchantName;
  final String? details;

  PaymentResult({
    required this.success,
    required this.transactionId,
    required this.message,
    this.errorCode,
    this.amount,
    this.merchantName,
    this.details,
  });
}

class PaymentService {
  final WalletService _walletService = WalletService();

  Future<PaymentResult> processPayment({
    required String merchantId,
    required String merchantName,
    required double amount,
    String? reference,
  }) async {
    try {
      final hasFunds = await _walletService.checkSufficientFundsAsync(amount);
      
      if (!hasFunds) {
        return PaymentResult(
          success: false,
          transactionId: '',
          message: 'Solde insuffisant',
          errorCode: 'INSUFFICIENT_FUNDS',
        );
      }

      await _walletService.debit(amount);

      return PaymentResult(
        success: true,
        transactionId: _generateTransactionId(),
        message: 'Paiement effectué avec succès',
        amount: amount,
        merchantName: merchantName,
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        transactionId: '',
        message: 'Erreur lors du paiement',
        errorCode: 'PAYMENT_ERROR',
        details: e.toString(),
      );
    }
  }

  Future<PaymentResult> processQrPayment(String qrData) async {
    try {
      final qrInfo = _parseQrCode(qrData);
      
      if (qrInfo == null) {
        return PaymentResult(
          success: false,
          transactionId: '',
          message: 'QR code invalide',
          errorCode: 'INVALID_QR',
        );
      }

      double amount = double.tryParse(qrInfo['amount']?.toString() ?? '0') ?? 0;

      return await processPayment(
        merchantId: qrInfo['merchantId']!,
        merchantName: qrInfo['merchantName']!,
        amount: amount,
        reference: qrInfo['reference']?.toString(),
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        transactionId: '',
        message: 'Erreur lors du scan',
        errorCode: 'SCAN_ERROR',
        details: e.toString(),
      );
    }
  }

  String _generateTransactionId() {
    return 'TXN_${DateTime.now().millisecondsSinceEpoch}';
  }

  Map<String, dynamic>? _parseQrCode(String qrData) {
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
