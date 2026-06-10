// lib/presentation/thix_reservation/widgets/bus_card.dart
import 'package:flutter/material.dart';

class BusCard extends StatelessWidget {
  final String compagnie;
  final String depart;
  final String arrivee;
  final String heureDepart;
  final String heureArrivee;
  final String duree;
  final String prix;
  final int siegesDisponibles;
  final VoidCallback onTap;

  const BusCard({
    super.key,
    required this.compagnie,
    required this.depart,
    required this.arrivee,
    required this.heureDepart,
    required this.heureArrivee,
    required this.duree,
    required this.prix,
    required this.siegesDisponibles,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4)],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(compagnie, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$siegesDisponibles sièges',
                    style: const TextStyle(color: Colors.green, fontSize: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(heureDepart, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(depart, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(duree, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const Icon(Icons.directions_bus, size: 20, color: Color(0xFFD4AF37)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(heureArrivee, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(arrivee, style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
                    Text(
                      prix,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD4AF37), fontSize: 16),
                    ),
                    const Text('par passager', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
                ElevatedButton(
                  onPressed: onTap,
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
      ),
    );
  }
}
