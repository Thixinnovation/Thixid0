// lib/presentation/thix_reservation/widgets/reassurance_badges.dart
import 'package:flutter/material.dart';

class ReassuranceBadges extends StatelessWidget {
  const ReassuranceBadges({super.key});

  @override
  Widget build(BuildContext context) {
    final badges = [
      {'icon': Icons.verified_user_outlined, 'text': 'Paiement sécurisé'},
      {'icon': Icons.support_agent, 'text': 'Support 24/7'},
      {'icon': Icons.workspace_premium_outlined, 'text': 'Meilleurs prix'},
      {'icon': Icons.cancel_schedule_send_outlined, 'text': 'Annulation facile'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: badges.map((badge) {
        return Column(
          children: [
            Icon(badge['icon'] as IconData, size: 14, color: const Color(0xFF1A73E8)),
            const SizedBox(height: 2),
            Text(
              badge['text'] as String,
              style: const TextStyle(fontSize: 7.5, color: Colors.black54),
            ),
          ],
        );
      }).toList(),
    );
  }
}
