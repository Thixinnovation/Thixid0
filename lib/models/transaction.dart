// lib/models/transaction.dart
import 'package:flutter/material.dart';

enum TransactionType {
  payment,
  transfer,
  cashback,
  credit,
  savings,
  investment,
  insurance,
  tontine,
  withdrawal,
  deposit,
}

extension TransactionTypeExtension on TransactionType {
  String get label {
    switch (this) {
      case TransactionType.payment:
        return 'Paiement';
      case TransactionType.transfer:
        return 'Virement';
      case TransactionType.cashback:
        return 'Cashback';
      case TransactionType.credit:
        return 'Crédit';
      case TransactionType.savings:
        return 'Épargne';
      case TransactionType.investment:
        return 'Investissement';
      case TransactionType.insurance:
        return 'Assurance';
      case TransactionType.tontine:
        return 'Tontine';
      case TransactionType.withdrawal:
        return 'Retrait';
      case TransactionType.deposit:
        return 'Dépôt';
    }
  }

  IconData get icon {
    switch (this) {
      case TransactionType.payment:
        return Icons.shopping_cart;
      case TransactionType.transfer:
        return Icons.swap_horiz;
      case TransactionType.cashback:
        return Icons.percent;
      case TransactionType.credit:
        return Icons.bolt;
      case TransactionType.savings:
        return Icons.savings;
      case TransactionType.investment:
        return Icons.trending_up;
      case TransactionType.insurance:
        return Icons.shield;
      case TransactionType.tontine:
        return Icons.group;
      case TransactionType.withdrawal:
        return Icons.account_balance_wallet;
      case TransactionType.deposit:
        return Icons.add_card;
    }
  }

  Color get iconColor {
    switch (this) {
      case TransactionType.payment:
        return Colors.red;
      case TransactionType.transfer:
        return Colors.blue;
      case TransactionType.cashback:
        return Colors.orange;
      case TransactionType.credit:
        return const Color(0xFFD4AF37);
      case TransactionType.savings:
        return Colors.green;
      case TransactionType.investment:
        return Colors.purple;
      case TransactionType.insurance:
        return Colors.teal;
      case TransactionType.tontine:
        return Colors.indigo;
      case TransactionType.withdrawal:
        return Colors.deepOrange;
      case TransactionType.deposit:
        return Colors.lightGreen;
    }
  }

  bool get isPositive {
    switch (this) {
      case TransactionType.cashback:
      case TransactionType.credit:
      case TransactionType.deposit:
      case TransactionType.transfer:
        return true;
      default:
        return false;
    }
  }
}

class Transaction {
  final String id;
  final double amount;
  final DateTime date;
  final String merchant;
  final TransactionType type;
  final String? reference;
  final String? description;
  final Map<String, dynamic>? metadata;

  Transaction({
    required this.id,
    required this.amount,
    required this.date,
    required this.merchant,
    required this.type,
    this.reference,
    this.description,
    this.metadata,
  });

  double get absoluteAmount => amount.abs();
  bool get isIncome => type.isPositive || amount > 0;
  bool get isExpense => !isIncome;

  String get formattedAmount {
    final prefix = isIncome ? '+' : '-';
    return '$prefix ${absoluteAmount.toStringAsFixed(0)} FCFA';
  }

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return "Aujourd'hui à ${_formatTime(date)}";
    } else if (difference.inDays == 1) {
      return 'Hier à ${_formatTime(date)}';
    } else if (difference.inDays < 7) {
      return _getDayName(date) + ' à ${_formatTime(date)}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getDayName(DateTime date) {
    const days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    return days[date.weekday - 1];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
      'merchant': merchant,
      'type': type.name,
      'reference': reference,
      'description': description,
      'metadata': metadata,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      merchant: json['merchant'] as String,
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.payment,
      ),
      reference: json['reference'] as String?,
      description: json['description'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

// Mock transactions
List<Transaction> mockTransactions = [
  Transaction(
    id: '1',
    amount: 250000,
    date: DateTime.now().subtract(const Duration(hours: 2)),
    merchant: 'Orange Money',
    type: TransactionType.deposit,
    reference: 'DEP-001',
    description: 'Rechargement compte',
  ),
  Transaction(
    id: '2',
    amount: 35000,
    date: DateTime.now().subtract(const Duration(days: 1)),
    merchant: 'Market Store',
    type: TransactionType.payment,
    reference: 'PAY-001',
    description: 'Courses alimentaires',
  ),
  Transaction(
    id: '3',
    amount: 5000,
    date: DateTime.now().subtract(const Duration(days: 1)),
    merchant: 'Cashback THIX',
    type: TransactionType.cashback,
    reference: 'CB-001',
    description: 'Cashback sur achat',
  ),
  Transaction(
    id: '4',
    amount: 500000,
    date: DateTime.now().subtract(const Duration(days: 3)),
    merchant: 'Crédit THIX',
    type: TransactionType.credit,
    reference: 'CR-001',
    description: 'Crédit instantané',
  ),
  Transaction(
    id: '5',
    amount: 150000,
    date: DateTime.now().subtract(const Duration(days: 5)),
    merchant: 'Tontine Business',
    type: TransactionType.tontine,
    reference: 'TON-001',
    description: 'Contribution tontine',
  ),
  Transaction(
    id: '6',
    amount: 75000,
    date: DateTime.now().subtract(const Duration(days: 7)),
    merchant: 'Restaurant Le Délice',
    type: TransactionType.payment,
    reference: 'PAY-002',
    description: 'Dîner',
  ),
  Transaction(
    id: '7',
    amount: 100000,
    date: DateTime.now().subtract(const Duration(days: 10)),
    merchant: 'Jean Dupont',
    type: TransactionType.transfer,
    reference: 'TRF-001',
    description: 'Virement reçu',
  ),
];
