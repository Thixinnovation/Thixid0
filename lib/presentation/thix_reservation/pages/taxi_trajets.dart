// lib/presentation/thix_reservation/pages/taxi_trajets.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TaxiTrajetsPage extends StatelessWidget {
  const TaxiTrajetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final trajets = [
      {'date': 'Aujourd\'hui', 'depart': 'Abidjan', 'arrivee': 'Yamoussoukro', 'prix': '25.000', 'statut': 'Terminé'},
      {'date': 'Hier', 'depart': 'Abidjan', 'arrivee': 'Grand Bassam', 'prix': '15.000', 'statut': 'Terminé'},
      {'date': '18 Mai 2025', 'depart': 'Abidjan', 'arrivee': 'Aéroport', 'prix': '8.000', 'statut': 'Annulé'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Mes trajets'),
        backgroundColor: const Color(0xFF0B1B3D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: trajets.length,
        itemBuilder: (context, index) {
          final trajet = trajets[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(trajet['date']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: trajet['statut'] == 'Terminé' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(trajet['statut']!, style: TextStyle(color: trajet['statut'] == 'Terminé' ? Colors.green : Colors.red, fontSize: 10)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Color(0xFFD4AF37)),
                          Text(trajet['depart']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward, color: Colors.grey),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.red),
                          Text(trajet['arrivee']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${trajet['prix']} FCFA', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: const Color(0xFF0B1B3D),
                      ),
                      child: const Text('Recommander'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
