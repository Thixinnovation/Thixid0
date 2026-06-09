import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EventsList extends StatelessWidget {
  final Function(String)? onEventTap;
  final Function(String)? onInterestedTap;

  const EventsList({
    super.key,
    this.onEventTap,
    this.onInterestedTap,
  });

  final List<Map<String, dynamic>> _events = const [
    {'id': '1', 'title': 'Forum Fintech Afrique', 'date': '15 JUIN 2024', 'location': 'Abidjan', 'participants': 120},
    {'id': '2', 'title': 'Tech Summit', 'date': '22 JUIN 2024', 'location': 'Dakar', 'participants': 85},
    {'id': '3', 'title': 'Startup Weekend', 'date': '5 JUILLET 2024', 'location': 'Kinshasa', 'participants': 200},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Événements à venir',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._events.map((event) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => onEventTap?.call(event['id'] as String),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.calendar_today, color: Color(0xFFD4AF37)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event['title'],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${event['date']} • ${event['location']}',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                        Text(
                          '${event['participants']} participants',
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => onInterestedTap?.call(event['id'] as String),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFD4AF37)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Intéressé', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
            ),
          ),
        )),
      ],
    );
  }
}
