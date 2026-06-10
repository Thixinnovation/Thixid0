// lib/models/savings_model.dart
import 'package:flutter/material.dart';

enum SavingsGoalStatus {
  active,
  completed,
  cancelled,
}

extension SavingsGoalStatusExtension on SavingsGoalStatus {
  String get label {
    switch (this) {
      case SavingsGoalStatus.active:
        return 'En cours';
      case SavingsGoalStatus.completed:
        return 'Atteint';
      case SavingsGoalStatus.cancelled:
        return 'Annulé';
    }
  }

  Color get color {
    switch (this) {
      case SavingsGoalStatus.active:
        return Colors.blue;
      case SavingsGoalStatus.completed:
        return Colors.green;
      case SavingsGoalStatus.cancelled:
        return Colors.grey;
    }
  }
}

class SavingsGoal {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime deadline;
  final IconData icon;
  final SavingsGoalStatus status;
  final DateTime? startDate;
  final double? monthlyContribution;

  SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    required this.icon,
    this.status = SavingsGoalStatus.active,
    this.startDate,
    this.monthlyContribution,
  });

  double get progress => currentAmount / targetAmount;
  int get progressPercent => (progress * 100).toInt();
  double get remaining => targetAmount - currentAmount;
  bool get isCompleted => currentAmount >= targetAmount;
  
  int get daysRemaining {
    final difference = deadline.difference(DateTime.now());
    return difference.inDays.clamp(0, difference.inDays);
  }

  String get formattedTarget => '${targetAmount.toStringAsFixed(0)} FCFA';
  String get formattedCurrent => '${currentAmount.toStringAsFixed(0)} FCFA';
  String get formattedRemaining => '${remaining.toStringAsFixed(0)} FCFA';

  double get dailyNeed {
    final days = daysRemaining;
    if (days <= 0) return 0;
    return remaining / days;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'deadline': deadline.toIso8601String(),
      'status': status.name,
      'start_date': startDate?.toIso8601String(),
      'monthly_contribution': monthlyContribution,
    };
  }

  factory SavingsGoal.fromJson(Map<String, dynamic> json) {
    return SavingsGoal(
      id: json['id'] as String,
      name: json['name'] as String,
      targetAmount: (json['target_amount'] as num).toDouble(),
      currentAmount: (json['current_amount'] as num).toDouble(),
      deadline: DateTime.parse(json['deadline'] as String),
      icon: Icons.savings,
      status: SavingsGoalStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SavingsGoalStatus.active,
      ),
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      monthlyContribution: json['monthly_contribution'] as double?,
    );
  }
}

class GroupSavings {
  final String id;
  final String name;
  final int memberCount;
  final double targetAmount;
  final double currentAmount;
  final List<GroupSavingsMember> members;

  GroupSavings({
    required this.id,
    required this.name,
    required this.memberCount,
    required this.targetAmount,
    required this.currentAmount,
    required this.members,
  });

  double get progress => currentAmount / targetAmount;
  int get progressPercent => (progress * 100).toInt();
  double get remaining => targetAmount - currentAmount;
}

class GroupSavingsMember {
  final String id;
  final String name;
  final double contributedAmount;

  GroupSavingsMember({
    required this.id,
    required this.name,
    required this.contributedAmount,
  });
}

// Mock savings goals
List<SavingsGoal> mockSavingsGoals = [
  SavingsGoal(
    id: '1',
    name: 'Voyage',
    targetAmount: 500000,
    currentAmount: 150000,
    deadline: DateTime.now().add(const Duration(days: 180)),
    icon: Icons.flight_takeoff,
    startDate: DateTime.now().subtract(const Duration(days: 30)),
    monthlyContribution: 50000,
  ),
  SavingsGoal(
    id: '2',
    name: 'Achat maison',
    targetAmount: 3000000,
    currentAmount: 450000,
    deadline: DateTime.now().add(const Duration(days: 730)),
    icon: Icons.home,
    startDate: DateTime.now().subtract(const Duration(days: 90)),
    monthlyContribution: 150000,
  ),
  SavingsGoal(
    id: '3',
    name: 'Études',
    targetAmount: 1000000,
    currentAmount: 600000,
    deadline: DateTime.now().add(const Duration(days: 365)),
    icon: Icons.school,
    startDate: DateTime.now().subtract(const Duration(days: 200)),
    monthlyContribution: 75000,
  ),
];
