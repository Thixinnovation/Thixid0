// lib/presentation/thix_reservation/widgets/section_header.dart
import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final bool showSeeAll;
  final VoidCallback? onSeeAllTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.showSeeAll = false,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black.withOpacity(0.8),
          ),
        ),
        if (showSeeAll)
          GestureDetector(
            onTap: onSeeAllTap,
            child: Row(
              children: const [
                Text(
                  "Voir tout",
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 12,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
