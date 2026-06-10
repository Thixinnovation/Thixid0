// lib/services/paiement_service.dart
import 'dart:async';
import 'package:thix_id/services/wallet_service.dart';

enum PaymentMethod { carte, mobileMoney, thixMoney, paypal, orangeMoney, mtnMoney }
enum PaymentStatus { pending, success, failed, refunded }
enum PaymentCategory { vol, hotel, bus, taxi, colis, restaurant, reservation }

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

  // ==================== PAIEMENT STANDARD (Wallet THIX) ====================

  Future<PaymentResult> processPayment({
    required String merchantId,
    required String merchantName,
    required double amount,
    String? reference,
    PaymentCategory? category,
  }) async {
    try {
      // Vérifier le solde
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

      // Débiter le compte
      await _walletService.debit(amount);

      // Notifier le marchand
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

  // ==================== PAIEMENT POUR RÉSERVATIONS ====================

  Future<PaymentResult> payerReservation({
    required String reservationId,
    required String titre,
    required double montant,
    required String devise,
    required PaymentMethod method,
    Map<String, dynamic>? details,
  }) async {
    try {
      // Vérifier le solde si paiement via Wallet THIX
      if (method == PaymentMethod.thixMoney) {
        final hasFunds = await _walletService.checkSufficientFundsAsync(montant);
        if (!hasFunds) {
          return PaymentResult(
            success: false,
            transactionId: '',
            message: 'Solde THIX Money insuffisant',
            status: PaymentStatus.failed,
            errorCode: 'INSUFFICIENT_FUNDS',
          );
        }
        await _walletService.debit(montant);
      }

      // Simuler l'appel à l'API de paiement externe
      final paymentResult = await _processExternalPayment(method, montant, devise);

      if (paymentResult) {
        return PaymentResult(
          success: true,
          transactionId: _generateTransactionId(),
          message: 'Paiement de $montant $devise effectué avec succès',
          status: PaymentStatus.success,
          date: DateTime.now(),
          amount: montant,
          merchantName: titre,
        );
      } else {
        return PaymentResult(
          success: false,
          transactionId: '',
          message: 'Échec du paiement',
          status: PaymentStatus.failed,
          errorCode: 'EXTERNAL_PAYMENT_FAILED',
        );
      }
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

  // ==================== PAIEMENT VOL ====================

  Future<PaymentResult> payerVol({
    required String volId,
    required String compagnie,
    required String volCode,
    required double montant,
    required String devise,
    required PaymentMethod method,
    required String passagerNom,
  }) async {
    return await payerReservation(
      reservationId: volId,
      titre: 'Vol $volCode - $compagnie',
      montant: montant,
      devise: devise,
      method: method,
      details: {
        'type': 'vol',
        'compagnie': compagnie,
        'volCode': volCode,
        'passager': passagerNom,
      },
    );
  }

  // ==================== PAIEMENT HÔTEL ====================

  Future<PaymentResult> payerHotel({
    required String hotelId,
    required String hotelNom,
    required double montant,
    required String devise,
    required PaymentMethod method,
    required int nuits,
    required String chambre,
  }) async {
    return await payerReservation(
      reservationId: hotelId,
      titre: 'Hôtel $hotelNom - $nuits nuits',
      montant: montant,
      devise: devise,
      method: method,
      details: {
        'type': 'hotel',
        'hotelNom': hotelNom,
        'nuits': nuits,
        'chambre': chambre,
      },
    );
  }

  // ==================== PAIEMENT BUS ====================

  Future<PaymentResult> payerBus({
    required String busId,
    required String compagnie,
    required String trajet,
    required double montant,
    required String devise,
    required PaymentMethod method,
    required int passagers,
  }) async {
    return await payerReservation(
      reservationId: busId,
      titre: 'Bus $compagnie - $trajet',
      montant: montant,
      devise: devise,
      method: method,
      details: {
        'type': 'bus',
        'compagnie': compagnie,
        'trajet': trajet,
        'passagers': passagers,
      },
    );
  }

  // ==================== PAIEMENT TAXI ====================

  Future<PaymentResult> payerTaxi({
    required String trajetId,
    required String depart,
    required String arrivee,
    required double montant,
    required String devise,
    required PaymentMethod method,
  }) async {
    return await payerReservation(
      reservationId: trajetId,
      titre: 'Taxi - $depart → $arrivee',
      montant: montant,
      devise: devise,
      method: method,
      details: {
        'type': 'taxi',
        'depart': depart,
        'arrivee': arrivee,
      },
    );
  }

  // ==================== PAIEMENT COLIS ====================

  Future<PaymentResult> payerColis({
    required String colisId,
    required String expediteur,
    required String destinataire,
    required double montant,
    required String devise,
    required PaymentMethod method,
  }) async {
    return await payerReservation(
      reservationId: colisId,
      titre: 'Envoi colis - $expediteur → $destinataire',
      montant: montant,
      devise: devise,
      method: method,
      details: {
        'type': 'colis',
        'expediteur': expediteur,
        'destinataire': destinataire,
      },
    );
  }

  // ==================== VALIDATION ET REMBOURSEMENT ====================

  Future<PaymentResult> validerPaiement(String otp, String transactionId) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // Simulation de validation 3D Secure
    if (otp == '123456') {
      return PaymentResult(
        success: true,
        transactionId: transactionId,
        message: 'Paiement validé avec succès',
        status: PaymentStatus.success,
        date: DateTime.now(),
      );
    } else {
      return PaymentResult(
        success: false,
        transactionId: transactionId,
        message: 'Code OTP invalide',
        status: PaymentStatus.failed,
        errorCode: 'INVALID_OTP',
      );
    }
  }

  Future<PaymentResult> rembourser(String transactionId, double montant) async {
    await Future.delayed(const Duration(seconds: 1));
    
    try {
      await _walletService.credit(montant);
      
      return PaymentResult(
        success: true,
        transactionId: transactionId,
        message: 'Remboursement de $montant FCFA effectué',
        status: PaymentStatus.refunded,
        date: DateTime.now(),
        amount: montant,
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        transactionId: transactionId,
        message: 'Erreur lors du remboursement',
        status: PaymentStatus.failed,
        errorCode: 'REFUND_ERROR',
        details: e.toString(),
      );
    }
  }

  // ==================== HISTORIQUE ET MÉTHODES ====================

  Future<List<PaymentResult>> getHistoriquePaiements() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      PaymentResult(
        success: true,
        transactionId: 'TXN_1704067200000',
        message: 'Paiement vol Paris - Ethiopian Airlines',
        status: PaymentStatus.success,
        date: DateTime.now().subtract(const Duration(days: 2)),
        amount: 780,
        merchantName: 'Ethiopian Airlines',
      ),
      PaymentResult(
        success: true,
        transactionId: 'TXN_1703980800000',
        message: 'Paiement hôtel Abidjan - Azalai',
        status: PaymentStatus.success,
        date: DateTime.now().subtract(const Duration(days: 5)),
        amount: 148000,
        merchantName: 'Azalai Hôtel',
      ),
      PaymentResult(
        success: true,
        transactionId: 'TXN_1703894400000',
        message: 'Paiement taxi - Abidjan → Yamoussoukro',
        status: PaymentStatus.success,
        date: DateTime.now().subtract(const Duration(days: 7)),
        amount: 25000,
        merchantName: 'Taxi THIX',
      ),
    ];
  }

  Future<List<PaymentMethod>> getMethodesPaiement() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      PaymentMethod.carte,
      PaymentMethod.mobileMoney,
      PaymentMethod.thixMoney,
      PaymentMethod.orangeMoney,
      PaymentMethod.mtnMoney,
      PaymentMethod.paypal,
    ];
  }

  Future<Map<PaymentMethod, bool>> getMethodesDisponibles() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return {
      PaymentMethod.carte: true,
      PaymentMethod.mobileMoney: true,
      PaymentMethod.thixMoney: true,
      PaymentMethod.orangeMoney: true,
      PaymentMethod.mtnMoney: true,
      PaymentMethod.paypal: false,
    };
  }

  // ==================== MÉTHODES PRIVÉES ====================

  Future<void> _notifyMerchant(String merchantId, double amount, String? reference) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Appel API pour notifier le marchand
  }

  Future<bool> _processExternalPayment(PaymentMethod method, double amount, String devise) async {
    await Future.delayed(const Duration(seconds: 1));
    // Simulation d'appel à l'API de paiement externe
    return true;
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
