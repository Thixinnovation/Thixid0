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
                       transaction.amount > 0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: transaction.type.iconColor.withOpacity(0.1),
          child: Icon(transaction.type.icon, color: transaction.type.iconColor, size: 22),
        ),
        title: Text(
          transaction.merchant,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          _formatDate(transaction.date),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return "Aujourd'hui";
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

// Extension pour les couleurs des types de transaction
extension TransactionTypeColor on TransactionType {
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
    }
  }
}
