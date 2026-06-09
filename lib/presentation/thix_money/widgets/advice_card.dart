// lib/presentation/thix_money/widgets/ai_advice_card.dart
import 'package:flutter/material.dart';

class AiAdviceCard extends StatelessWidget {
  final String? advice;
  final VoidCallback? onSeeMore;

  const AiAdviceCard({
    super.key,
    this.advice,
    this.onSeeMore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37).withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, size: 42, color: Color(0xFFD4AF37)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              advice ?? 'THIX AI : Vous pouvez économiser 150 000 FCFA ce mois.',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          if (onSeeMore != null)
            TextButton(
              onPressed: onSeeMore,
              style: TextButton.styleFrom(foregroundColor: const Color(0xFFD4AF37)),
              child: const Text('Voir plus'),
            ),
        ],
      ),
    );
  }
}
