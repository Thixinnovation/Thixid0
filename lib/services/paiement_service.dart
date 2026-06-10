// lib/services/paiement_service.dart
import 'dart:async';
import 'package:thix_id/services/wallet_service.dart';

enum PaymentMethod { carte, mobileMoney, thixMoney, paypal, orangeMoney, mtnMoney }
enum PaymentStatus { pending, success, failed, refunded }

class PaymentResult {
  final bool success;
  final String transactionId;
  final String message;
  final PaymentStatus status;
  final DateTime? date;
  final String? errorCode;
  final double? amount;
  final String? merchantName;
  final String? details;

  PaymentResult({
    required this.success,
    required this.transactionId,
    required this.message,
    required this.status,
    this.date,
    this.errorCode,
    this.amount,
    this.merchantName,
    this.details,
  });
}

class PaiementService {
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
          status: PaymentStatus.failed,
          errorCode: 'INSUFFICIENT_FUNDS',
        );
      }

      await _walletService.debit(amount);
      await _notifyMerchant(merchantId, amount, reference);

      return PaymentResult(
        success: true,
        transactionId: _generateTransactionId(),
        message: 'Paiement effectué avec succès',
        status: PaymentStatus.success,
        date: DateTime.now(),
        amount: amount,
        merchantName: merchantName,
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        transactionId: '',
        message: 'Erreur lors du paiement',
        status: PaymentStatus.failed,
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
          status: PaymentStatus.failed,
          errorCode: 'INVALID_QR',
        );
      }

      double amount = 0;
      final amountStr = qrInfo['amount'];
      if (amountStr != null) {
        if (amountStr is double) {
          amount = amountStr;
        } else if (amountStr is String) {
          amount = double.tryParse(amountStr) ?? 0;
        } else if (amountStr is int) {
          amount = amountStr.toDouble();
        }
      }

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
        status: PaymentStatus.failed,
        errorCode: 'SCAN_ERROR',
        details: e.toString(),
      );
    }
  }

  Future<void> _notifyMerchant(String merchantId, double amount, String? reference) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  String _generateTransactionId() {
    return 'TXN_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
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
