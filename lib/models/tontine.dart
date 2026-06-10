// lib/models/tontine.dart
import 'package:flutter/material.dart';

enum TontineStatus {
  active,
  completed,
  pending,
  cancelled,
}

extension TontineStatusExtension on TontineStatus {
  String get label {
    switch (this) {
      case TontineStatus.active:
        return 'Active';
      case TontineStatus.completed:
        return 'Terminée';
      case TontineStatus.pending:
        return 'En attente';
      case TontineStatus.cancelled:
        return 'Annulée';
    }
  }

  Color get color {
    switch (this) {
      case TontineStatus.active:
        return Colors.green;
      case TontineStatus.completed:
        return Colors.blue;
      case TontineStatus.pending:
        return Colors.orange;
      case TontineStatus.cancelled:
        return Colors.red;
    }
  }
}

enum TontineFrequency {
  weekly,
  monthly,
  quarterly,
}

extension TontineFrequencyExtension on TontineFrequency {
  String get label {
    switch (this) {
      case TontineFrequency.weekly:
        return 'Hebdomadaire';
      case TontineFrequency.monthly:
        return 'Mensuel';
      case TontineFrequency.quarterly:
        return 'Trimestriel';
    }
  }
}

class Tontine {
  final String id;
  final String name;
  final double progress;
  final int currentMembers;
  final int maxMembers;
  final double contributionAmount;
  final TontineFrequency frequency;
  final TontineStatus status;
  final String? description;
  final DateTime? startDate;
  final DateTime? nextPaymentDate;
  final List<TontineMember>? members;
  final List<TontinePayment>? payments;

  Tontine({
    required this.id,
    required this.name,
    required this.progress,
    required this.currentMembers,
    required this.maxMembers,
    required this.contributionAmount,
    required this.frequency,
    this.status = TontineStatus.active,
    this.description,
    this.startDate,
    this.nextPaymentDate,
    this.members,
    this.payments,
  });

  int get remainingMembers => maxMembers - currentMembers;
  bool get isFull => currentMembers >= maxMembers;
  String get formattedContribution => '${contributionAmount.toStringAsFixed(0)} FCFA';
  int get progressPercent => (progress * 100).toInt();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'progress': progress,
      'currentMembers': currentMembers,
      'maxMembers': maxMembers,
      'contributionAmount': contributionAmount,
      'frequency': frequency.name,
      'status': status.name,
      'description': description,
      'startDate': startDate?.toIso8601String(),
      'nextPaymentDate': nextPaymentDate?.toIso8601String(),
    };
  }

  factory Tontine.fromJson(Map<String, dynamic> json) {
    return Tontine(
      id: json['id'] as String,
      name: json['name'] as String,
      progress: (json['progress'] as num).toDouble(),
      currentMembers: json['currentMembers'] as int,
      maxMembers: json['maxMembers'] as int,
      contributionAmount: (json['contributionAmount'] as num).toDouble(),
      frequency: TontineFrequency.values.firstWhere(
        (e) => e.name == json['frequency'],
        orElse: () => TontineFrequency.monthly,
      ),
      status: TontineStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TontineStatus.active,
      ),
      description: json['description'] as String?,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      nextPaymentDate: json['nextPaymentDate'] != null
          ? DateTime.parse(json['nextPaymentDate'] as String)
          : null,
    );
  }
}

class TontineMember {
  final String id;
  final String name;
  final String? avatar;
  final DateTime joinedAt;
  final List<DateTime> paymentsMade;

  TontineMember({
    required this.id,
    required this.name,
    this.avatar,
    required this.joinedAt,
    this.paymentsMade = const [],
  });

  int get paymentsCount => paymentsMade.length;
  bool hasPaidFor(DateTime period) => paymentsMade.contains(period);
}

class TontinePayment {
  final String id;
  final String memberId;
  final String memberName;
  final double amount;
  final DateTime date;
  final bool isPaid;

  TontinePayment({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.amount,
    required this.date,
    this.isPaid = false,
  });
}

// Mock tontines
List<Tontine> mockTontines = [
  Tontine(
    id: '1',
    name: 'Tontine Business',
    progress: 0.78,
    currentMembers: 7,
    maxMembers: 10,
    contributionAmount: 50000,
    frequency: TontineFrequency.monthly,
    status: TontineStatus.active,
    description: 'Tontine pour entrepreneurs',
    startDate: DateTime.now().subtract(const Duration(days: 60)),
    nextPaymentDate: DateTime.now().add(const Duration(days: 5)),
  ),
  Tontine(
    id: '2',
    name: 'Projet Maison',
    progress: 0.52,
    currentMembers: 5,
    maxMembers: 10,
    contributionAmount: 100000,
    frequency: TontineFrequency.monthly,
    status: TontineStatus.active,
    description: 'Épargne pour construction maison',
    startDate: DateTime.now().subtract(const Duration(days: 30)),
    nextPaymentDate: DateTime.now().add(const Duration(days: 12)),
  ),
  Tontine(
    id: '3',
    name: 'Tontine Famille',
    progress: 0.33,
    currentMembers: 4,
    maxMembers: 10,
    contributionAmount: 25000,
    frequency: TontineFrequency.weekly,
    status: TontineStatus.active,
    description: 'Tontine familiale',
    startDate: DateTime.now().subtract(const Duration(days: 15)),
    nextPaymentDate: DateTime.now().add(const Duration(days: 2)),
  ),
];
