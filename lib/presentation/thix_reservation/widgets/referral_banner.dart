// lib/presentation/thix_reservation/widgets/referral_banner.dart
import 'package:flutter/material.dart';

class ReferralBanner extends StatelessWidget {
  final VoidCallback? onTap;

  const ReferralBanner({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F3FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.card_giftcard, color: Colors.purple, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Parrainez & Gagnez !",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: Colors.purple,
                    ),
                  ),
                  Text(
                    "Invitez vos proches et gagnez jusqu'à 10.000 FC par parrainage.",
                    style: TextStyle(fontSize: 8.5, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Row(
              children: List.generate(
                3,
                (index) => const Align(
                  widthFactor: 0.6,
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, size: 10, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 14),
          ],
        ),
      ),
    );
  }
}
