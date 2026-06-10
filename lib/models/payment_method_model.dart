// lib/models/payment_method_model.dart
import 'package:flutter/material.dart';

enum PaymentMethodType {
  mobileMoney,
  bankCard,
  bankTransfer,
  cash,
}

extension PaymentMethodTypeExtension on PaymentMethodType {
  String get label {
    switch (this) {
      case PaymentMethodType.mobileMoney:
        return 'Mobile Money';
      case PaymentMethodType.bankCard:
        return 'Carte bancaire';
      case PaymentMethodType.bankTransfer:
        return 'Virement bancaire';
      case PaymentMethodType.cash:
        return 'Espèces';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethodType.mobileMoney:
        return Icons.phone_android;
      case PaymentMethodType.bankCard:
        return Icons.credit_card;
      case PaymentMethodType.bankTransfer:
        return Icons.account_balance;
      case PaymentMethodType.cash:
        return Icons.money;
    }
  }
}

class PaymentMethod {
  final String id;
  final String name;
  final PaymentMethodType type;
  final String? lastFourDigits;
  final String? holderName;
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.type,
    this.lastFourDigits,
    this.holderName,
    this.isDefault = false,
  });

  String get displayName {
    if (lastFourDigits != null) {
      return '$name •••• $lastFourDigits';
    }
    return name;
  }
}
