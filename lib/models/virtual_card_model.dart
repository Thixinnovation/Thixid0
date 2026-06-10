// lib/models/virtual_card_model.dart
import 'package:flutter/material.dart';

enum CardStatus {
  active,
  frozen,
  expired,
  blocked,
}

extension CardStatusExtension on CardStatus {
  String get label {
    switch (this) {
      case CardStatus.active:
        return 'Active';
      case CardStatus.frozen:
        return 'Gelée';
      case CardStatus.expired:
        return 'Expirée';
      case CardStatus.blocked:
        return 'Bloquée';
    }
  }

  Color get color {
    switch (this) {
      case CardStatus.active:
        return Colors.green;
      case CardStatus.frozen:
        return Colors.orange;
      case CardStatus.expired:
        return Colors.red;
      case CardStatus.blocked:
        return Colors.grey;
    }
  }
}

class VirtualCard {
  final String id;
  final String cardNumber;
  final String expiryDate;
  final String cvv;
  final String cardHolderName;
  final CardStatus status;
  final double limit;
  final double spent;
  final DateTime createdAt;

  VirtualCard({
    required this.id,
    required this.cardNumber,
    required this.expiryDate,
    required this.cvv,
    required this.cardHolderName,
    required this.status,
    required this.limit,
    required this.spent,
    required this.createdAt,
  });

  double get remaining => limit - spent;
  double get spentPercentage => spent / limit;
  int get spentPercent => (spentPercentage * 100).toInt();
  String get maskedNumber => '**** **** **** ${cardNumber.substring(cardNumber.length - 4)}';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'card_number': cardNumber,
      'expiry_date': expiryDate,
      'cvv': cvv,
      'card_holder_name': cardHolderName,
      'status': status.name,
      'limit': limit,
      'spent': spent,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory VirtualCard.fromJson(Map<String, dynamic> json) {
    return VirtualCard(
      id: json['id'] as String,
      cardNumber: json['card_number'] as String,
      expiryDate: json['expiry_date'] as String,
      cvv: json['cvv'] as String,
      cardHolderName: json['card_holder_name'] as String,
      status: CardStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CardStatus.active,
      ),
      limit: (json['limit'] as num).toDouble(),
      spent: (json['spent'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
