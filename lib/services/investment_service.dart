// lib/services/investment_service.dart
import 'dart:async';
import 'package:flutter/material.dart';
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
        status: InvestmentStatus.active,
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
        message: 'Investissement de ${amount.toStringAsFixed(0)} FCFA effectué',
        investmentId: investmentId,
        amount: amount,
        projectedReturn: projectedReturn,
        returnRate: investment.returnRate,
      );
    } catch (e) {
      return InvestmentResult(
        success: false,
        message: 'Erreur lors de l\'investissement',
        errorCode: 'INVESTMENT_ERROR',
        details: e.toString(),
      );
    }
  }

  Future<Investment?> _getInvestmentById(String id) async {
    final investments = await getAvailableInvestments();
    try {
      return investments.firstWhere((i) => i.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> _submitInvestment(String id, double amount) async {
    await Future.delayed(const Duration(seconds: 1));
    // Appel API
  }
}

enum RiskLevel { veryLow, low, medium, high }

extension RiskLevelExtension on RiskLevel {
  String get label {
    switch (this) {
      case RiskLevel.veryLow:
        return 'Très faible';
      case RiskLevel.low:
        return 'Faible';
      case RiskLevel.medium:
        return 'Moyen';
      case RiskLevel.high:
        return 'Élevé';
    }
  }

  Color get color {
    switch (this) {
      case RiskLevel.veryLow:
        return Colors.green;
      case RiskLevel.low:
        return Colors.lightGreen;
      case RiskLevel.medium:
        return Colors.orange;
      case RiskLevel.high:
        return Colors.red;
    }
  }
}

enum InvestmentStatus {
  active,
  matured,
  cancelled,
}

extension InvestmentStatusExtension on InvestmentStatus {
  String get label {
    switch (this) {
      case InvestmentStatus.active:
        return 'Actif';
      case InvestmentStatus.matured:
        return 'Arrivé à échéance';
      case InvestmentStatus.cancelled:
        return 'Annulé';
    }
  }
}

class Investment {
  final String id;
  final String name;
  final String description;
  final double returnRate;
  final RiskLevel risk;
  final double minAmount;
  final double maxAmount;
  final int durationDays;
  final IconData icon;
  final int color;
  final double? investedAmount;
  final double? currentValue;
  final DateTime? startDate;
  final InvestmentStatus? status;

  Investment({
    required this.id,
    required this.name,
    required this.description,
    required this.returnRate,
    required this.risk,
    required this.minAmount,
    required this.maxAmount,
    required this.durationDays,
    required this.icon,
    required this.color,
    this.investedAmount,
    this.currentValue,
    this.startDate,
    this.status,
  });

  double get profit => (currentValue ?? 0) - (investedAmount ?? 0);
  
  double get profitPercentage {
    if (investedAmount == null || investedAmount == 0) return 0;
    return (profit / investedAmount!) * 100;
  }

  DateTime get maturityDate {
    if (startDate == null) return DateTime.now();
    return startDate!.add(Duration(days: durationDays));
  }

  int get daysRemaining {
    final remaining = maturityDate.difference(DateTime.now());
    return remaining.inDays.clamp(0, remaining.inDays);
  }

  String get formattedReturnRate => '+${(returnRate * 100).toInt()}%';
  String get formattedMinAmount => '${minAmount.toStringAsFixed(0)} FCFA';
  String get formattedInvested => investedAmount != null ? '${investedAmount!.toStringAsFixed(0)} FCFA' : '-';
  String get formattedCurrent => currentValue != null ? '${currentValue!.toStringAsFixed(0)} FCFA' : '-';
}

class InvestmentResult {
  final bool success;
  final String message;
  final String? errorCode;
  final String? investmentId;
  final double? amount;
  final double? projectedReturn;
  final double? returnRate;
  final String? details;

  InvestmentResult({
    required this.success,
    required this.message,
    this.errorCode,
    this.investmentId,
    this.amount,
    this.projectedReturn,
    this.returnRate,
    this.details,
  });
}
