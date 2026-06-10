// lib/presentation/thix_reservation/widgets/annonce_card.dart
import 'package:flutter/material.dart';

class AnnonceCard extends StatelessWidget {
  final bool isSmallScreen;

  const AnnonceCard({super.key, required this.isSmallScreen});

  @override
  Widget build(BuildContext context) {
    final annonces = [
      {'tag': 'À VENDRE', 'tagColor': Colors.green, 'title': 'Toyota RAV4 2021', 'price': '25.000.000 FC'},
      {'tag': 'À LOUER', 'tagColor': Colors.red, 'title': 'Appartement 3 pièces', 'price': '600.000 FC / mois'},
      {'tag': 'SERVICE', 'tagColor': Colors.teal, 'title': 'Ménage à domicile', 'price': 'À partir de 10.000 FC'},
    ];

    return SizedBox(
      height: isSmallScreen ? 110 : 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: annonces.length,
        itemBuilder: (context, index) {
          final item = annonces[index];
          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: item['tagColor'] as Color,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item['tag'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 7,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 9),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        item['price'] as String,
                        style: const TextStyle(
                          fontSize: 8.5,
                          color: Color(0xFF1A73E8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
