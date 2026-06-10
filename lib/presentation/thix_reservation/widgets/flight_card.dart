// lib/presentation/thix_reservation/widgets/flight_card.dart
import 'package:flutter/material.dart';
import '../../models/vol.dart';

class FlightCard extends StatelessWidget {
  final Vol vol;
  final VoidCallback onTap;

  const FlightCard({
    super.key,
    required this.vol,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
                Text(vol.compagnie, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: vol.escales == 0 ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    vol.escales == 0 ? 'Direct' : '${vol.escales} escale',
                    style: TextStyle(
                      color: vol.escales == 0 ? Colors.green : Colors.orange,
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
                      Text(vol.heureDepart, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(vol.depart, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(vol.duree, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const Icon(Icons.flight, size: 20, color: Color(0xFFD4AF37)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(vol.heureArrivee, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(vol.arrivee, style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
                    _buildDetailBadge(Icons.work_outline, vol.bagageCabine),
                    const SizedBox(width: 12),
                    _buildDetailBadge(Icons.work, vol.bagageSoute),
                    const SizedBox(width: 12),
                    _buildDetailBadge(Icons.restaurant, vol.repasInclus ? 'Repas' : 'Sans repas'),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${vol.prix.round()} ${vol.devise}',
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
