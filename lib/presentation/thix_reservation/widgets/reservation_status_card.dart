// lib/presentation/thix_reservation/widgets/reservation_status_card.dart
import 'package:flutter/material.dart';

class ReservationStatusCard extends StatelessWidget {
  const ReservationStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final status = [
      {'label': 'À venir', 'count': '3', 'color': Colors.blue, 'icon': Icons.business_center},
      {'label': 'En cours', 'count': '1', 'color': Colors.green, 'icon': Icons.timelapse},
      {'label': 'Terminées', 'count': '8', 'color': Colors.purple, 'icon': Icons.check_circle_outline},
      {'label': 'Annulées', 'count': '0', 'color': Colors.red, 'icon': Icons.cancel_outlined},
    ];

    return Row(
      children: status.map((item) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      color: item['color'] as Color,
                      size: 14,
                    ),
                    Text(
                      item['count'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item['label'] as String,
                  style: const TextStyle(fontSize: 9, color: Colors.grey),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
