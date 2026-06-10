// lib/models/wallet_model.dart
import 'package:flutter/material.dart';

class WalletModel {
  final String id;
  final String userId;
  final double balance;
  final double savingsBalance;
  final double investmentBalance;
  final String currency;
  final DateTime lastUpdated;
  final List<WalletTransaction>? recentTransactions;

  WalletModel({
    required this.id,
    required this.userId,
    required this.balance,
    required this.savingsBalance,
    required this.investmentBalance,
    this.currency = 'FCFA',
    required this.lastUpdated,
    this.recentTransactions,
  });

  double get totalBalance => balance + savingsBalance + investmentBalance;
  
  String get formattedBalance {
    return balance.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
  }

  String get formattedTotalBalance {
    return totalBalance.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'balance': balance,
      'savings_balance': savingsBalance,
      'investment_balance': investmentBalance,
      'currency': currency,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      balance: (json['balance'] as num).toDouble(),
      savingsBalance: (json['savings_balance'] as num).toDouble(),
      investmentBalance: (json['investment_balance'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'FCFA',
      lastUpdated: DateTime.parse(json['last_updated'] as String),
    );
  }
}

class WalletTransaction {
  final String id;
  final double amount;
  final DateTime date;
  final String type;
  final String description;
  final String? reference;

  WalletTransaction({
    required this.id,
    required this.amount,
    required this.date,
    required this.type,
    required this.description,
    this.reference,
  });

  bool get isCredit => amount > 0;
  bool get isDebit => amount < 0;
}
