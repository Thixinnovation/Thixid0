// lib/presentation/thix_reservation/widgets/special_offer_card.dart
import 'package:flutter/material.dart';

class SpecialOfferCard extends StatelessWidget {
  final bool isSmallScreen;

  const SpecialOfferCard({super.key, required this.isSmallScreen});

  @override
  Widget build(BuildContext context) {
    final offers = [
      {'title': 'Hôtels', 'promo': '-30%', 'desc': 'Séjournez plus,\npayez moins', 'color': Colors.red.shade50},
      {'title': 'Vols', 'promo': '-20%', 'desc': 'Sur tous les vols', 'color': Colors.blue.shade50},
      {'title': 'Bus', 'promo': '-15%', 'desc': 'Voyagez en toute\nconfiance', 'color': Colors.indigo.shade50},
      {'title': 'Livraison', 'promo': '-10%', 'desc': 'Envoi express', 'color': Colors.green.shade50},
    ];

    return SizedBox(
      height: isSmallScreen ? 70 : 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: offers.length,
        itemBuilder: (context, index) {
          final offer = offers[index];
          return Container(
            width: 105,
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: offer['color'] as Color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  offer['title'] as String,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  offer['promo'] as String,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A73E8),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  offer['desc'] as String,
                  style: const TextStyle(
                    fontSize: 8,
                    color: Colors.black54,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
