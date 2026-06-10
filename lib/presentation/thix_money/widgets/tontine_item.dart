// lib/presentation/thix_money/widgets/tontine_item.dart
import 'package:flutter/material.dart';
import 'package:thix_id/models/tontine.dart';

class TontineItem extends StatelessWidget {
  final Tontine tontine;
  final VoidCallback? onTap;

  const TontineItem({
    super.key,
    required this.tontine,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    tontine.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${(tontine.progress * 100).toInt()}%',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: tontine.progress,
                backgroundColor: Colors.grey.shade200,
                color: const Color(0xFFD4AF37),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${tontine.currentMembers}/${tontine.maxMembers} membres',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const Text(
                  'Voir',
                  style: TextStyle(fontSize: 12, color: Color(0xFFD4AF37), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
