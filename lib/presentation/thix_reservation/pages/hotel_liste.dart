// lib/presentation/thix_reservation/pages/hotel_liste.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HotelListePage extends StatelessWidget {
  const HotelListePage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    List<Map<String, dynamic>> hotels = [];

    if (args is List) {
      hotels = List<Map<String, dynamic>>.from(args);
    } else {
      // Données mockées par défaut
      hotels = [
        {'id': '1', 'nom': 'Azalai Hotel Abidjan', 'ville': 'Abidjan', 'prix': 68000, 'prixOriginal': 85600, 'note': 4.5, 'promo': '-20%'},
        {'id': '2', 'nom': 'Onomo Hotel Dakar', 'ville': 'Dakar', 'prix': 63750, 'prixOriginal': 75000, 'note': 4.2, 'promo': '-15%'},
        {'id': '3', 'nom': 'Pullman Hotel Paris', 'ville': 'Paris', 'prix': 198, 'prixOriginal': 220, 'note': 4.6, 'promo': '-10%', 'devise': 'EUR'},
        {'id': '4', 'nom': 'Radisson Blu', 'ville': 'Brazzaville', 'prix': 72000, 'prixOriginal': 90000, 'note': 4.4, 'promo': '-20%'},
        {'id': '5', 'nom': 'Novotel', 'ville': 'Kinshasa', 'prix': 55000, 'prixOriginal': 68000, 'note': 4.0, 'promo': '-15%'},
        {'id': '6', 'nom': 'Ibis Styles', 'ville': 'Douala', 'prix': 35000, 'prixOriginal': 45000, 'note': 3.8, 'promo': '-10%'},
      ];
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Hotels disponibles'),
        backgroundColor: const Color(0xFF0B1B3D),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilters(context),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: hotels.length,
        itemBuilder: (context, index) {
          final hotel = hotels[index];
          return _buildHotelCard(hotel, context);
        },
      ),
    );
  }

  Widget _buildHotelCard(Map<String, dynamic> hotel, BuildContext context) {
    final nom = hotel['nom'] as String;
    final ville = hotel['ville'] as String;
    final note = (hotel['note'] as num).toDouble();
    final prixPromo = hotel['prix'].toString();
    final prixOriginal = hotel['prixOriginal'].toString();
    final promo = hotel['promo'] as String;
    final devise = hotel.containsKey('devise') ? hotel['devise'] as String : 'FCFA';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Center(
                  child: Icon(Icons.hotel, size: 40, color: Colors.grey.shade400),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    promo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, size: 12, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(
                        note.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nom,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 12, color: Colors.grey),
                    const SizedBox(width: 2),
                    Text(
                      ville,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          '$prixOriginal $devise',
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$prixPromo $devise',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFFD4AF37),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => context.push('/reservation/hotels/details'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: const Color(0xFF0B1B3D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: const Size(60, 30),
                      ),
                      child: const Text('Voir', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Filtres',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Prix',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              // Correction ici : RangeSlider sans const
              RangeSlider(
                values: const RangeValues(0, 200000),
                min: 0,
                max: 500000,
                divisions: 10,
                onChanged: (values) {},
              ),
              const SizedBox(height: 16),
              const Text(
                'Note',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 8,
                children: [5, 4, 3, 2].map((note) {
                  return FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(' $note+'),
                      ],
                    ),
                    selected: false,
                    onSelected: (_) {},
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  minimumSize: const Size(double.infinity, 40),
                ),
                child: const Text('Appliquer'),
              ),
            ],
          ),
        );
      },
    );
  }
}
