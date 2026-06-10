// lib/services/savings_service.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:thix_id/services/wallet_service.dart';

class SavingsService {
  final WalletService _walletService = WalletService();

  Future<List<SavingsGoal>> getSavingsGoals() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      SavingsGoal(
        id: '1',
        name: 'Voyage',
        targetAmount: 500000,
        currentAmount: 150000,
        deadline: DateTime.now().add(const Duration(days: 180)),
        icon: Icons.flight_takeoff,
      ),
      SavingsGoal(
        id: '2',
        name: 'Achat maison',
        targetAmount: 3000000,
        currentAmount: 450000,
        deadline: DateTime.now().add(const Duration(days: 730)),
        icon: Icons.home,
      ),
      SavingsGoal(
        id: '3',
        name: 'Études',
        targetAmount: 1000000,
        currentAmount: 600000,
        deadline: DateTime.now().add(const Duration(days: 365)),
        icon: Icons.school,
      ),
    ];
  }

  Future<SavingsResult> contributeToGoal({
    required String goalId,
    required double amount,
  }) async {
    try {
      if (amount <= 0) {
        return SavingsResult(
          success: false,
          message: 'Montant invalide',
          errorCode: 'INVALID_AMOUNT',
        );
      }

      if (!_walletService.hasSufficientFunds(amount)) {
        return SavingsResult(
          success: false,
          message: 'Solde insuffisant',
          errorCode: 'INSUFFICIENT_FUNDS',
        );
      }

      await _walletService.debit(amount);
      await _updateSavingsGoal(goalId, amount);

      return SavingsResult(
        success: true,
        message: '${amount.toStringAsFixed(0)} FCFA ajoutés à votre objectif',
        goalId: goalId,
        amount: amount,
      );
    } catch (e) {
      return SavingsResult(
        success: false,
        message: 'Erreur lors de l\'épargne',
        errorCode: 'SAVINGS_ERROR',
        details: e.toString(),
      );
    }
  }

  Future<AutoSavingsResult> setupAutoSavings({
    required double amount,
    required String frequency,
    required String goalId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return AutoSavingsResult(
      success: true,
      message: 'Épargne automatique activée',
      amount: amount,
      frequency: frequency,
      nextDate: DateTime.now().add(const Duration(days: 30)),
    );
  }

  Future<void> _updateSavingsGoal(String goalId, double amount) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Appel API
  }
}

class SavingsGoal {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime deadline;
  final IconData icon;

  SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    required this.icon,
  });

  double get progress => currentAmount / targetAmount;
  double get remaining => targetAmount - currentAmount;
  bool get isCompleted => currentAmount >= targetAmount;
  int get progressPercent => (progress * 100).toInt();
  String get formattedTarget => '${targetAmount.toStringAsFixed(0)} FCFA';
  String get formattedCurrent => '${currentAmount.toStringAsFixed(0)} FCFA';
}

class SavingsResult {
  final bool success;
  final String message;
  final String? errorCode;
  final String? goalId;
  final double? amount;
  final String? details;

  SavingsResult({
    required this.success,
    required this.message,
    this.errorCode,
    this.goalId,
    this.amount,
    this.details,
  });
}

class AutoSavingsResult {
  final bool success;
  final String message;
  final double? amount;
  final String? frequency;
  final DateTime? nextDate;

  AutoSavingsResult({
    required this.success,
    required this.message,
    this.amount,
    this.frequency,
    this.nextDate,
  });
}
