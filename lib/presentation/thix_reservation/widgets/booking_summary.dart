// lib/presentation/thix_reservation/widgets/booking_summary.dart
import 'package:flutter/material.dart';

class BookingSummary extends StatelessWidget {
  final double subtotal;
  final double taxes;
  final double total;
  final VoidCallback onConfirm;

  const BookingSummary({
    super.key,
    required this.subtotal,
    required this.taxes,
    required this.total,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Sous-total', style: TextStyle(color: Colors.grey)),
              Text('${subtotal.round()} FCFA', style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Taxes et frais', style: TextStyle(color: Colors.grey)),
              Text('${taxes.round()} FCFA', style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(
                '${total.round()} FCFA',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: const Color(0xFF0B1B3D),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Confirmer la réservation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
