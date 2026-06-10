// lib/presentation/thix_reservation/pages/hotel_liste.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HotelListePage extends StatelessWidget {
  const HotelListePage({super.key});

  @override
  Widget build(BuildContext context) {
    final hotels = (ModalRoute.of(context)?.settings.arguments as List?) ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Hôtels disponibles'),
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
        padding: const EdgeInsets.all(16),
        itemCount: hotels.isEmpty ? 5 : hotels.length,
        itemBuilder: (context, index) {
          if (hotels.isEmpty) {
            return _buildHotelCard(
              'Azalai Hôtel Abidjan',
              'Abidjan, Côte d\'Ivoire',
              4.5,
              '68.000',
              '85.600',
              '-20%',
            );
          }
          final hotel = hotels[index];
          return _buildHotelCard(
            hotel['nom'],
            hotel['ville'],
            hotel['note'],
            hotel['prixPromo'],
            hotel['prixOriginal'],
            hotel['promo'],
          );
        },
      ),
    );
  }

  Widget _buildHotelCard(String nom, String ville, double note, String prixPromo, String prixOriginal, String promo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
              ),
              Positioned(
                top: 12, left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
                  child: Text(promo, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
              Positioned(
                top: 12, right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      Text(' $note', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nom, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    Text(ville, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text('$prixOriginal FCFA', style: const TextStyle(decoration: TextDecoration.lineThrough, fontSize: 12, color: Colors.grey)),
                        const SizedBox(width: 8),
                        Text('$prixPromo FCFA', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFD4AF37))),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => context.push('/reservation/hotels/details'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: const Color(0xFF0B1B3D),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('Voir'),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Filtres', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Prix', style: TextStyle(fontWeight: FontWeight.bold)),
            const RangeSlider(values: RangeValues(0, 200000), min: 0, max: 500000, onChanged: (_) {}),
            const SizedBox(height: 16),
            const Text('Note', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: [5, 4, 3, 2].map((note) {
                return FilterChip(
                  label: Row(
                    children: [
                      Icon(Icons.star, size: 14, color: Colors.amber),
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
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
              child: const Text('Appliquer'),
            ),
          ],
        ),
      ),
    );
  }
}
