// lib/presentation/thix_money/widgets/credit_card.dart
import 'package:flutter/material.dart';

class CreditCard extends StatelessWidget {
  final VoidCallback? onTap;
  final double? maxAmount;

  const CreditCard({
    super.key,
    this.onTap,
    this.maxAmount,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1B3D),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            const Icon(Icons.flash_on, color: Color(0xFFD4AF37), size: 40),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CRÉDIT INSTANTANÉ',
                    style: TextStyle(color: Color(0xFFD4AF37), fontSize: 12, letterSpacing: 1),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Besoin d\'argent ?',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    maxAmount != null ? 'Jusqu\'à ${maxAmount!.toStringAsFixed(0)} FCFA' : 'Jusqu\'à 5 000 000 FCFA',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Color(0xFFD4AF37), shape: BoxShape.circle),
              child: const Icon(Icons.arrow_forward, color: Color(0xFF0B1B3D), size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
