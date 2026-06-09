import 'package:flutter/material.dart';

class OpportunitiesList extends StatelessWidget {
  const OpportunitiesList({super.key});

  final List<Map<String, dynamic>> _opportunities = const [
    {'title': 'Product Designer', 'company': 'Creative Studio', 'location': 'Abidjan', 'type': 'Temps plein'},
    {'title': 'Partenariat Fintech', 'company': 'PayPal Solutions', 'location': 'Côte d\'Ivoire', 'type': 'Partenariat'},
    {'title': 'Levée de fonds', 'company': 'Startup en phase seed', 'location': 'Côte d\'Ivoire', 'type': 'Investissement'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Opportunités pour vous',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._opportunities.map((opp) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opp['title'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${opp['company']} • ${opp['location']}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        opp['type'],
                        style: TextStyle(
                          fontSize: 10,
                          color: const Color(0xFFD4AF37),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: const Color(0xFF0B1B3D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Postuler', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }
}
