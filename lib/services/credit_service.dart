// lib/services/credit_service.dart
import 'dart:async';
import 'package:thix_id/services/wallet_service.dart';

class CreditService {
  final WalletService _walletService = WalletService();

  Future<CreditEligibility> checkEligibility() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final balance = await _walletService.getBalance();
    final monthlyStats = await _walletService.getMonthlyStats();
    
    // Logique simple d'éligibilité
    final isEligible = balance > 50000 && monthlyStats['income']! > 200000;
    
    return CreditEligibility(
      eligible: isEligible,
      maxAmount: isEligible ? 5000000 : 0,
      interestRate: 5.5,
      availableMonths: [1, 3, 6, 12],
      message: isEligible 
          ? 'Félicitations ! Vous êtes éligible au crédit instantané.'
          : 'Pour être éligible, maintenez un solde minimum de 50 000 FCFA et des revenus réguliers.',
    );
  }

  Future<CreditResult> requestCredit({
    required double amount,
    required int durationMonths,
    required String reason,
  }) async {
    try {
      final eligibility = await checkEligibility();
      
      if (!eligibility.eligible) {
        return CreditResult(
          success: false,
          message: eligibility.message,
          errorCode: 'NOT_ELIGIBLE',
        );
      }
      
      if (amount > eligibility.maxAmount) {
        return CreditResult(
          success: false,
          message: 'Montant maximum: ${eligibility.maxAmount.toStringAsFixed(0)} FCFA',
          errorCode: 'MAX_AMOUNT_EXCEEDED',
        );
      }
      
      if (durationMonths < 1 || durationMonths > 12) {
        return CreditResult(
          success: false,
          message: 'Durée invalide (1-12 mois)',
          errorCode: 'INVALID_DURATION',
        );
      }

      // Calculer les intérêts
      final interest = amount * (eligibility.interestRate / 100);
      final monthlyPayment = (amount + interest) / durationMonths;
      
      // Appel API pour la demande
      await _submitCreditRequest(amount, durationMonths, reason);
      
      // Créditer le compte (simulation)
      await _walletService.requestCredit(amount);
      
      return CreditResult(
        success: true,
        message: 'Demande de crédit approuvée',
        creditId: _generateCreditId(),
        amount: amount,
        interest: interest,
        monthlyPayment: monthlyPayment,
        durationMonths: durationMonths,
      );
    } catch (e) {
      return CreditResult(
        success: false,
        message: 'Erreur lors de la demande',
        errorCode: 'REQUEST_ERROR',
        details: e.toString(),
      );
    }
  }

  Future<List<CreditHistory>> getCreditHistory() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      CreditHistory(
        id: 'CR_001',
        amount: 500000,
        date: DateTime.now().subtract(const Duration(days: 90)),
        status: 'Remboursé',
        remainingAmount: 0,
      ),
      CreditHistory(
        id: 'CR_002',
        amount: 250000,
        date: DateTime.now().subtract(const Duration(days: 30)),
        status: 'En cours',
        remainingAmount: 150000,
      ),
    ];
  }

  Future<void> _submitCreditRequest(double amount, int duration, String reason) async {
    await Future.delayed(const Duration(seconds: 1));
    // Appel API
  }

  String _generateCreditId() {
    return 'CR_${DateTime.now().millisecondsSinceEpoch}';
  }
}

class CreditEligibility {
  final bool eligible;
  final double maxAmount;
  final double interestRate;
  final List<int> availableMonths;
  final String message;

  CreditEligibility({
    required this.eligible,
    required this.maxAmount,
    required this.interestRate,
    required this.availableMonths,
    required this.message,
  });
}

class CreditResult {
  final bool success;
  final String message;
  final String? errorCode;
  final String? creditId;
  final double? amount;
  final double? interest;
  final double? monthlyPayment;
  final int? durationMonths;
  final String? details;

  CreditResult({
    required this.success,
    required this.message,
    this.errorCode,
    this.creditId,
    this.amount,
    this.interest,
    this.monthlyPayment,
    this.durationMonths,
    this.details,
  });
}

class CreditHistory {
  final String id;
  final double amount;
  final DateTime date;
  final String status;
  final double remainingAmount;

  CreditHistory({
    required this.id,
    required this.amount,
    required this.date,
    required this.status,
    required this.remainingAmount,
  });
}
