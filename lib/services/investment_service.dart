// lib/services/investment_service.dart
import 'dart:async';
import 'package:thix_id/services/wallet_service.dart';

class InvestmentService {
  final WalletService _walletService = WalletService();

  Future<List<Investment>> getAvailableInvestments() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      Investment(
        id: '1',
        name: 'Immobilier',
        description: 'Investissez dans l\'immobilier africain',
        returnRate: 0.09,
        risk: RiskLevel.low,
        minAmount: 100000,
        maxAmount: 10000000,
        durationDays: 365,
        icon: Icons.home_work,
        color: 0xFF1E88E5,
      ),
      Investment(
        id: '2',
        name: 'Agriculture',
        description: 'Projets agricoles rentables',
        returnRate: 0.12,
        risk: RiskLevel.medium,
        minAmount: 50000,
        maxAmount: 5000000,
        durationDays: 180,
        icon: Icons.agriculture,
        color: 0xFF43A047,
      ),
      Investment(
        id: '3',
        name: 'Startup',
        description: 'Investissez dans les startups innovantes',
        returnRate: 0.17,
        risk: RiskLevel.high,
        minAmount: 250000,
        maxAmount: 2000000,
        durationDays: 730,
        icon: Icons.rocket_launch,
        color: 0xFFD4AF37,
      ),
      Investment(
        id: '4',
        name: 'Obligations d\'État',
        description: 'Placement sécurisé',
        returnRate: 0.06,
        risk: RiskLevel.veryLow,
        minAmount: 50000,
        maxAmount: 5000000,
        durationDays: 365,
        icon: Icons.account_balance,
        color: 0xFF0B1B3D,
      ),
    ];
  }

  Future<List<Investment>> getMyInvestments() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      Investment(
        id: '101',
        name: 'Immobilier - Dakar',
        description: 'Investissement en cours',
        returnRate: 0.09,
        risk: RiskLevel.low,
        minAmount: 500000,
        maxAmount: 500000,
        durationDays: 365,
        icon: Icons.home_work,
        color: 0xFF1E88E5,
        investedAmount: 500000,
        currentValue: 545000,
        startDate: DateTime.now().subtract(const Duration(days: 90)),
      ),
    ];
  }

  Future<InvestmentResult> invest({
    required String investmentId,
    required double amount,
  }) async {
    try {
      final investment = await _getInvestmentById(investmentId);
      
      if (investment == null) {
        return InvestmentResult(
          success: false,
          message: 'Investissement non trouvé',
          errorCode: 'NOT_FOUND',
        );
      }

      if (amount < investment.minAmount) {
        return InvestmentResult(
          success: false,
          message: 'Montant minimum: ${investment.minAmount.toStringAsFixed(0)} FCFA',
          errorCode: 'MINIMUM_AMOUNT',
        );
      }

      if (amount > investment.maxAmount) {
        return InvestmentResult(
          success: false,
          message: 'Montant maximum: ${investment.maxAmount.toStringAsFixed(0)} FCFA',
          errorCode: 'MAXIMUM_AMOUNT',
        );
      }

      if (!_walletService.hasSufficientFunds(amount)) {
        return InvestmentResult(
          success: false,
          message: 'Solde insuffisant',
          errorCode: 'INSUFFICIENT_FUNDS',
        );
      }

      await _walletService.transferToInvestment(amount);
      await _submitInvestment(investmentId, amount);

      final projectedReturn = amount * investment.returnRate;

      return InvestmentResult(
        success: true,
        message: 'Investissement de ${amount.toString
