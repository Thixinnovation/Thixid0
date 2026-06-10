// lib/presentation/thix_reservation/widgets/flight_card.dart
import 'package:flutter/material.dart';

class FlightCard extends StatelessWidget {
  final Map<String, dynamic> vol;
  final VoidCallback onTap;

  const FlightCard({
    super.key,
    required this.vol,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final compagnie = vol['compagnie'] as String;
    final codeVol = vol['codeVol'] as String;
    final depart = vol['depart'] as String;
    final arrivee = vol['arrivee'] as String;
    final heureDepart = vol['heureDepart'] as String;
    final heureArrivee = vol['heureArrivee'] as String;
    final duree = vol['duree'] as String;
    final escales = vol['escales'] as int;
    final bagageCabine = vol['bagageCabine'] as String;
    final bagageSoute = vol['bagageSoute'] as String;
    final repasInclus = vol['repasInclus'] as bool;
    final prix = vol['prix'] as double;
    final devise = vol['devise'] as String;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(compagnie, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: escales == 0 ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    escales == 0 ? 'Direct' : '$escales escale',
                    style: TextStyle(
                      color: escales == 0 ? Colors.green : Colors.orange,
                      fontSize: 10,
                    ),
                  ),
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
                      Text(heureDepart, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(depart, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(duree, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const Icon(Icons.flight, size: 20, color: Color(0xFFD4AF37)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
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
                Row(
                  children: [
                    _buildDetailBadge(Icons.work_outline, bagageCabine),
                    const SizedBox(width: 12),
                    _buildDetailBadge(Icons.work, bagageSoute),
                    const SizedBox(width: 12),
                    _buildDetailBadge(Icons.restaurant, repasInclus ? 'Repas' : 'Sans repas'),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${prix.round()} $devise',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFD4AF37)),
                    ),
                    const Text('par passager', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailBadge(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFFD4AF37)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}
