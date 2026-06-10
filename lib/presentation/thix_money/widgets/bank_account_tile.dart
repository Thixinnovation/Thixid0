// lib/presentation/thix_money/widgets/bank_account_tile.dart
import 'package:flutter/material.dart';

class BankAccountTile extends StatelessWidget {
  final String bankName;
  final String accountNumber;
  final String? accountHolder;
  final bool isDefault;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const BankAccountTile({
    super.key,
    required this.bankName,
    required this.accountNumber,
    this.accountHolder,
    this.isDefault = false,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDefault ? const Color(0xFFD4AF37) : Colors.grey.shade200,
          width: isDefault ? 2 : 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFD4AF37).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.account_balance, color: Color(0xFFD4AF37)),
        ),
        title: Text(
          bankName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Compte: $accountNumber'),
            if (accountHolder != null) Text(accountHolder!, style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isDefault)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Défaut', style: TextStyle(fontSize: 10, color: Color(0xFFD4AF37))),
              ),
            if (onDelete != null) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: onDelete,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
