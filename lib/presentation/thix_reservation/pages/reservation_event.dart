// lib/presentation/thix_reservation/pages/reservation_event.dart
import 'package:flutter/material.dart';

class ReservationEventPage extends StatelessWidget {
  const ReservationEventPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Événements'),
        backgroundColor: const Color(0xFF0B1B3D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0B1B3D), Color(0xFFD4AF37)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🎉 Événements à venir', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Découvrez les meilleurs événements près de chez vous',
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Catégories
            const Text('Catégories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildCategories(),
            const SizedBox(height: 20),

            // Événements populaires
            const Text('Événements populaires', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildPopularEvents(),
            const SizedBox(height: 20),

            // Événements gratuits
            const Text('Événements gratuits', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildFreeEvents(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories() {
    final categories = [
      {'icon': '🎵', 'label': 'Concerts'},
      {'icon': '🎭', 'label': 'Théâtre'},
      {'icon': '⚽', 'label': 'Sports'},
      {'icon': '🎨', 'label': 'Art'},
      {'icon': '🍽️', 'label': 'Gastronomie'},
      {'icon': '👨‍💻', 'label': 'Tech'},
    ];
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Container(
            width: 80,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4)],
                  ),
                  child: Text(cat['icon']!, style: const TextStyle(fontSize: 28)),
                ),
                const SizedBox(height: 8),
                Text(cat['label']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPopularEvents() {
    final events = [
      {'titre': 'Concert de Fally Ipupa', 'date': '25 Mai 2025', 'lieu': 'Kinshasa', 'prix': '25.000 FCFA', 'image': '🎤'},
      {'titre': 'Festival de danse', 'date': '30 Mai 2025', 'lieu': 'Abidjan', 'prix': '15.000 FCFA', 'image': '💃'},
      {'titre': 'Match de football', 'date': '01 Juin 2025', 'lieu': 'Dakar', 'prix': '10.000 FCFA', 'image': '⚽'},
    ];
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4)],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text(event['image']!, style: const TextStyle(fontSize: 30))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event['titre']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('${event['date']} • ${event['lieu']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(event['prix']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
                  const SizedBox(height: 4),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: const Color(0xFF0B1B3D),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      minimumSize: const Size(70, 30),
                    ),
                    child: const Text('Réserver', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFreeEvents() {
    final events = [
      {'titre': 'Exposition d\'art', 'date': '20 Mai 2025', 'lieu': 'Abidjan', 'image': '🎨'},
      {'titre': 'Conférence tech', 'date': '22 Mai 2025', 'lieu': 'Dakar', 'image': '👨‍💻'},
      {'titre': 'Journée portes ouvertes', 'date': '28 Mai 2025', 'lieu': 'Kinshasa', 'image': '🚪'},
    ];
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green.shade100),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text(event['image']!, style: const TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event['titre']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('${event['date']} • ${event['lieu']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('GRATUIT', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }
}
