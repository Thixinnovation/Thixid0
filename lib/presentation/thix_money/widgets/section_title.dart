// lib/presentation/thix_money/widgets/section_title.dart
import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  final String? seeAllText;

  const SectionTitle({
    super.key,
    required this.title,
    this.onSeeAll,
    this.seeAllText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0B1B3D),
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFD4AF37),
              padding: EdgeInsets.zero,
            ),
            child: Text(seeAllText ?? 'Voir tout'),
          ),
      ],
    );
  }
}
