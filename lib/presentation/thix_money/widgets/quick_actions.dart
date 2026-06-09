// lib/presentation/thix_money/widgets/quick_actions.dart
import 'package:flutter/material.dart';

class QuickActions extends StatelessWidget {
  final VoidCallback onSendTap;
  final VoidCallback onDepositTap;
  final VoidCallback onScannerTap;
  final VoidCallback onWithdrawTap;

  const QuickActions({
    super.key,
    required this.onSendTap,
    required this.onDepositTap,
    required this.onScannerTap,
    required this.onWithdrawTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildAction(Icons.send, 'Envoyer', Colors.blue, onSendTap),
        _buildAction(Icons.add_card, 'Recharger', Colors.green, onDepositTap),
        _buildAction(Icons.qr_code_scanner, 'Scanner', Colors.deepPurple, onScannerTap),
        _buildAction(Icons.account_balance_wallet, 'Retrait', Colors.orange, onWithdrawTap),
      ],
    );
  }

  Widget _buildAction(IconData icon, String title, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
