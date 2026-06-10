// lib/models/investment_model.dart
import 'package:flutter/material.dart';

enum RiskLevel {
  veryLow,
  low,
  medium,
  high,
}

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'return_rate': returnRate,
      'risk': risk.name,
      'min_amount': minAmount,
      'max_amount': maxAmount,
      'duration_days': durationDays,
      'invested_amount': investedAmount,
      'current_value': currentValue,
      'start_date': startDate?.toIso8601String(),
      'status': status?.name,
    };
  }

  factory Investment.fromJson(Map<String, dynamic> json) {
    return Investment(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      returnRate: (json['return_rate'] as num).toDouble(),
      risk: RiskLevel.values.firstWhere(
        (e) => e.name == json['risk'],
        orElse: () => RiskLevel.medium,
      ),
      minAmount: (json['min_amount'] as num).toDouble(),
      maxAmount: (json['max_amount'] as num).toDouble(),
      durationDays: json['duration_days'] as int,
      icon: Icons.trending_up,
      color: 0xFFD4AF37,
      investedAmount: (json['invested_amount'] as num?)?.toDouble(),
      currentValue: (json['current_value'] as num?)?.toDouble(),
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      status: json['status'] != null
          ? InvestmentStatus.values.firstWhere(
              (e) => e.name == json['status'],
              orElse: () => InvestmentStatus.active,
            )
          : null,
    );
  }
}

// Mock investments
List<Investment> mockAvailableInvestments = [
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
];

List<Investment> mockMyInvestments = [
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
