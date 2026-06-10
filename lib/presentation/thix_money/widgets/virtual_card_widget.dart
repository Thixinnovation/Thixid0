// lib/presentation/thix_money/widgets/virtual_card_widget.dart
import 'package:flutter/material.dart';

class VirtualCardWidget extends StatelessWidget {
  final String? cardNumber;
  final String? expiryDate;
  final String? cardHolderName;

  const VirtualCardWidget({
    super.key,
    this.cardNumber,
    this.expiryDate,
    this.cardHolderName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF111827), Color(0xFF1F2937)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'THIX VIRTUAL CARD',
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 12,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Icon(Icons.credit_card, color: Color(0xFFD4AF37), size: 28),
            ],
          ),
          const Spacer(),
          Text(
            cardNumber ?? '**** **** **** 4587',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'VALID THRU',
                    style: TextStyle(color: Colors.white54, fontSize: 8),
                  ),
                  Text(
                    expiryDate ?? '12/29',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'CARD HOLDER',
                    style: TextStyle(color: Colors.white54, fontSize: 8),
                  ),
                  Text(
                    cardHolderName ?? 'JEAN DUPONT',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
