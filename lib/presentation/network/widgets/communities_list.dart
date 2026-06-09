import 'package:flutter/material.dart';

class CommunitiesList extends StatelessWidget {
  const CommunitiesList({super.key});

  final List<Map<String, dynamic>> _communities = const [
    {'name': 'Fintech Afrique', 'members': 12500},
    {'name': 'Développeurs Flutter', 'members': 18000},
    {'name': 'Entrepreneurs Afrique', 'members': 24500},
    {'name': 'IA & Innovation', 'members': 9200},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Communautés populaires',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._communities.map((community) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.people, color: Color(0xFFD4AF37)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      community['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${community['members']} membres',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFD4AF37)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Rejoindre',
                  style: TextStyle(fontSize: 11, color: Color(0xFFD4AF37)),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}
