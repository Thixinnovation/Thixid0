// lib/presentation/thix_reservation/pages/hotel_details.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HotelDetailsPage extends StatelessWidget {
  const HotelDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Details de l\'hotel'),
        backgroundColor: const Color(0xFF0B1B3D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageGallery(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHotelInfo(),
                  const SizedBox(height: 16),
                  _buildAmenities(),
                  const SizedBox(height: 16),
                  _buildRooms(),
                  const SizedBox(height: 16),
                  _buildReviews(),
                  const SizedBox(height: 24),
                  _buildBookButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery() {
    return SizedBox(
      height: 250,
      child: PageView(
        children: [
          Container(color: Colors.grey.shade300, child: const Center(child: Icon(Icons.hotel, size: 50, color: Colors.grey))),
          Container(color: Colors.grey.shade400, child: const Center(child: Icon(Icons.bed, size: 50, color: Colors.grey))),
          Container(color: Colors.grey.shade500, child: const Center(child: Icon(Icons.restaurant, size: 50, color: Colors.grey))),
        ],
      ),
    );
  }

  Widget _buildHotelInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Azalai Hotel Abidjan', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on, size: 16, color: Colors.grey),
            const Text(' Abidjan, Cote d\'Ivoire', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 16),
            ...List.generate(5, (i) => Icon(Icons.star, size: 16, color: i < 4 ? Colors.amber : Colors.grey)),
            const SizedBox(width: 8),
            const Text('4.5', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'L\'Azalai Hotel Abidjan est un etablissement 4 etoiles situe en plein coeur du Plateau. '
          'Il propose des chambres luxueuses, une piscine exterieure, un spa et un restaurant gastronomique.',
          style: TextStyle(fontSize: 14, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildAmenities() {
    final amenities = [
      {'icon': Icons.wifi, 'label': 'Wi-Fi gratuit'},
      {'icon': Icons.pool, 'label': 'Piscine'},
      {'icon': Icons.fitness_center, 'label': 'Salle de sport'},
      {'icon': Icons.restaurant, 'label': 'Restaurant'},
      {'icon': Icons.local_parking, 'label': 'Parking'},
      {'icon': Icons.spa, 'label': 'Spa'},
    ];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Services & equipements', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: amenities.map((a) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(a['icon'] as IconData, size: 14, color: const Color(0xFFD4AF37)),
                    const SizedBox(width: 4),
                    Text(a['label'] as String, style: const TextStyle(fontSize: 11)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRooms() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Chambres disponibles', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildRoomCard('Chambre Standard', '1 lit double ou 2 lits simples', '68.000 FCFA'),
          const SizedBox(height: 8),
          _buildRoomCard('Chambre Superieure', 'Lit king size, vue sur ville', '85.000 FCFA'),
          const SizedBox(height: 8),
          _buildRoomCard('Suite Junior', 'Salon separe, vue sur mer', '120.000 FCFA'),
        ],
      ),
    );
  }

  Widget _buildRoomCard(String title, String description, String price) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(description, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
              const Text('par nuit', style: TextStyle(fontSize: 9, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviews() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Avis clients', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const ListTile(
            leading: CircleAvatar(child: Text('KA')),
            title: Text('Kouame A.'),
            subtitle: Text('Sejour parfait ! L\'hotel etait propre, le personnel tres accueillant.'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, size: 14, color: Colors.amber),
                Text(' 5.0'),
              ],
            ),
          ),
          const Divider(),
          const ListTile(
            leading: CircleAvatar(child: Text('M')),
            title: Text('Mari'),
            subtitle: Text('Tres bon recommande'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, size: 14, color: Colors.amber),
                Text(' 5.0'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () => context.push('/reservation/hotels/reservation'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD4AF37),
          foregroundColor: const Color(0xFF0B1B3D),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: const Text('Reserver maintenant', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
