// lib/presentation/network/widgets/events_list.dart
import 'package:flutter/material.dart';

class EventsList extends StatelessWidget {
  final void Function(String) onEventTap;
  final void Function(String) onInterestedTap;

  const EventsList({
    super.key,
    required this.onEventTap,
    required this.onInterestedTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 2)],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.event, color: Colors.purple),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Événements', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Découvrez les événements à venir', style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => onEventTap(''),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: const Color(0xFF0B1B3D),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Voir', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
