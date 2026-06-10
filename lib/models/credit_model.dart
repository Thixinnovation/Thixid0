// lib/models/credit_model.dart
import 'package:flutter/material.dart';

enum CreditStatus {
  pending,
  approved,
  rejected,
  active,
  completed,
  defaulted,
}

extension CreditStatusExtension on CreditStatus {
  String get label {
    switch (this) {
      case CreditStatus.pending:
        return 'En attente';
      case CreditStatus.approved:
        return 'Approuvé';
      case CreditStatus.rejected:
        return 'Refusé';
      case CreditStatus.active:
        return 'Actif';
      case CreditStatus.completed:
        return 'Remboursé';
      case CreditStatus.defaulted:
        return 'Impayé';
    }
  }

  Color get color {
    switch (this) {
      case CreditStatus.pending:
        return Colors.orange;
      case CreditStatus.approved:
        return Colors.green;
      case CreditStatus.rejected:
        return Colors.red;
      case CreditStatus.active:
        return Colors.blue;
      case CreditStatus.completed:
        return Colors.teal;
      case CreditStatus.defaulted:
        return Colors.red;
    }
  }
}

class CreditModel {
  final String id;
  final double amount;
  final double remainingAmount;
  final double interestRate;
  final int durationMonths;
  final DateTime startDate;
  final DateTime? endDate;
  final CreditStatus status;
  final String? reason;
  final List<CreditPayment>? payments;

  CreditModel({
    required this.id,
    required this.amount,
    required this.remainingAmount,
    required this.interestRate,
    required this.durationMonths,
    required this.startDate,
    this.endDate,
    required this.status,
    this.reason,
    this.payments,
  });

  double get monthlyPayment => (amount * (1 + interestRate / 100)) / durationMonths;
  double get totalToPay => amount * (1 + interestRate / 100);
  double get totalInterest => amount * (interestRate / 100);
  double get progress => 1 - (remainingAmount / totalToPay);
  int get progressPercent => (progress * 100).toInt();
  int get remainingMonths {
    if (status == CreditStatus.completed) return 0;
    final monthsSinceStart = DateTime.now().difference(startDate).inDays / 30;
    return (durationMonths - monthsSinceStart).ceil().clamp(0, durationMonths);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'remaining_amount': remainingAmount,
      'interest_rate': interestRate,
      'duration_months': durationMonths,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'status': status.name,
      'reason': reason,
    };
  }

  factory CreditModel.fromJson(Map<String, dynamic> json) {
    return CreditModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      remainingAmount: (json['remaining_amount'] as num).toDouble(),
      interestRate: (json['interest_rate'] as num).toDouble(),
      durationMonths: json['duration_months'] as int,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      status: CreditStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CreditStatus.pending,
      ),
      reason: json['reason'] as String?,
    );
  }
}

class CreditPayment {
  final String id;
  final double amount;
  final DateTime dueDate;
  final DateTime? paidDate;
  final bool isPaid;

  CreditPayment({
    required this.id,
    required this.amount,
    required this.dueDate,
    this.paidDate,
    this.isPaid = false,
  });

  bool get isLate => !isPaid && dueDate.isBefore(DateTime.now());
  int get daysOverdue => isLate ? DateTime.now().difference(dueDate).inDays : 0;
}
