// lib/services/qr_payment_service.dart
import 'dart:async';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:thix_id/services/paiement_service.dart';  // ← Vérifie que le fichier existe

class QrPaymentService {
  final PaiementService _paymentService = PaiementService();

  Future<QrScanResult> scanQrCode(BarcodeCapture capture) async {
    try {
      final qrCode = capture.barcodes.first.rawValue;
      
      if (qrCode == null || qrCode.isEmpty) {
        return QrScanResult(
          success: false,
          message: 'QR code invalide',
          errorCode: 'INVALID_QR',
        );
      }

      final parsedData = _parseQrData(qrCode);
      
      if (parsedData == null) {
        return QrScanResult(
          success: false,
          message: 'Format de QR code non reconnu',
          errorCode: 'UNSUPPORTED_FORMAT',
        );
      }

      return QrScanResult(
        success: true,
        message: 'QR code scanné avec succès',
        merchantId: parsedData['merchantId'],
        merchantName: parsedData['merchantName'],
        amount: parsedData['amount'],
        reference: parsedData['reference'],
      );
    } catch (e) {
      return QrScanResult(
        success: false,
        message: 'Erreur lors du scan',
        errorCode: 'SCAN_ERROR',
        details: e.toString(),
      );
    }
  }

  Future<PaymentResult> processQrPayment(String qrData) async {
    return await _paymentService.processQrPayment(qrData);
  }

  Map<String, dynamic>? _parseQrData(String qrData) {
    if (qrData.startsWith('THIX|')) {
      final parts = qrData.split('|');
      if (parts.length >= 3) {
        return {
          'merchantId': parts[1],
          'merchantName': parts[2],
          'amount': parts.length > 3 ? double.tryParse(parts[3]) ?? 0 : 0,
          'reference': parts.length > 4 ? parts[4] : null,
        };
      }
    }
    return null;
  }

  String generateQrCode({
    required String merchantId,
    required String merchantName,
    double? amount,
    String? reference,
  }) {
    return 'THIX|$merchantId|$merchantName|${amount ?? 0}|${reference ?? ''}';
  }
}

class QrScanResult {
  final bool success;
  final String message;
  final String? errorCode;
  final String? merchantId;
  final String? merchantName;
  final double? amount;
  final String? reference;
  final String? details;

  QrScanResult({
    required this.success,
    required this.message,
    this.errorCode,
    this.merchantId,
    this.merchantName,
    this.amount,
    this.reference,
    this.details,
  });
}
