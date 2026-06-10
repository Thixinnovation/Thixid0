// lib/presentation/thix_reservation/pages/bus_liste.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BusListePage extends StatelessWidget {
  const BusListePage({super.key});

  @override
  Widget build(BuildContext context) {
    final bus = [
      {'compagnie': 'Rapide Bus', 'depart': '08:00', 'arrivee': '12:00', 'prix': '5.000', 'sieges': 45},
      {'compagnie': 'Confort Lines', 'depart': '10:00', 'arrivee': '14:00', 'prix': '6.500', 'sieges': 50},
      {'compagnie': 'Express Voyages', 'depart': '14:00', 'arrivee': '18:00', 'prix': '5.500', 'sieges': 40},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Bus disponibles'),
        backgroundColor: const Color(0xFF0B1B3D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bus.length,
        itemBuilder: (context, index) {
          final item = bus[index];
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
                    Text(item['compagnie'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Disponible', style: TextStyle(color: Colors.green, fontSize: 10)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(item['depart'] as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const Text('Abidjan', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    ),
                    const Expanded(
                      child: Column(
                        children: [
                          Icon(Icons.arrow_forward, color: Color(0xFFD4AF37)),
                          Text('4h', style: TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(item['arrivee'] as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const Text('Yamoussoukro', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${item['prix'] as String} FCFA', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD4AF37), fontSize: 16)),
                        const Text('par passager', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => context.push('/reservation/bus/reservation'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: const Color(0xFF0B1B3D),
                      ),
                      child: const Text('Choisir'),
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
