// lib/presentation/thix_money/widgets/transaction_item.dart
import 'package:flutter/material.dart';
import 'package:thix_id/models/transaction.dart';

class TransactionItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;

  const TransactionItem({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = transaction.type == TransactionType.cashback || 
                       transaction.type == TransactionType.credit ||
                       transaction.type == TransactionType.deposit ||
                       transaction.amount > 0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: _getIconColor(transaction.type).withOpacity(0.1),
          child: Icon(_getIcon(transaction.type), color: _getIconColor(transaction.type), size: 22),
        ),
        title: Text(
          transaction.merchant,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          transaction.formattedDate,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isPositive ? '+' : ''}${transaction.amount.abs().toStringAsFixed(0)} FCFA',
              style: TextStyle(
                color: isPositive ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            if (transaction.reference != null)
              Text(
                transaction.reference!,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(TransactionType type) {
    switch (type) {
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

  Color _getIconColor(TransactionType type) {
    switch (type) {
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
}
