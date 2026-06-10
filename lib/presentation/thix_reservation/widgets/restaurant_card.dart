// lib/presentation/thix_reservation/widgets/restaurant_card.dart
import 'package:flutter/material.dart';

class RestaurantCard extends StatelessWidget {
  final bool isSmallScreen;

  const RestaurantCard({super.key, required this.isSmallScreen});

  @override
  Widget build(BuildContext context) {
    final restaurants = [
      {'name': "Le Goût d'Ici", 'type': 'Africaine', 'time': '20-30 min', 'price': '\$\$', 'rating': '4.6'},
      {'name': 'Fast & Good', 'type': 'Fast Food', 'time': '15-25 min', 'price': '\$\$', 'rating': '4.8'},
      {'name': 'Pizza Time', 'type': 'Italienne', 'time': '20-30 min', 'price': '\$\$', 'rating': '4.5'},
      {'name': 'Sushi House', 'type': 'Japonaise', 'time': '25-35 min', 'price': '\$\$', 'rating': '4.7'},
    ];

    return SizedBox(
      height: isSmallScreen ? 115 : 125,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: restaurants.length,
        itemBuilder: (context, index) {
          final restau = restaurants[index];
          return Container(
            width: 115,
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
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 8),
                                Text(
                                  " ${restau['rating']}",
                                  style: const TextStyle(color: Colors.white, fontSize: 8),
                                ),
                              ],
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
                        restau['name']!,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 9),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        restau['type']!,
                        style: const TextStyle(fontSize: 7.5, color: Colors.grey),
                      ),
                      const SizedBox(height: 1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            restau['time']!,
                            style: const TextStyle(fontSize: 7.5, color: Colors.black54),
                          ),
                          const Icon(Icons.favorite_border, size: 10, color: Colors.black54),
                        ],
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
