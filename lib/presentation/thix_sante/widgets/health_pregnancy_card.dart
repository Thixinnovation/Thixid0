import 'package:flutter/material.dart';

class HealthPregnancyCard extends StatelessWidget {
  final int currentWeek;
  final DateTime expectedDate;
  final DateTime lastCheckup;
  final VoidCallback? onTap;

  const HealthPregnancyCard({
    super.key,
    required this.currentWeek,
    required this.expectedDate,
    required this.lastCheckup,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final weeksLeft = expectedDate.difference(DateTime.now()).inDays ~/ 7;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFD4AF37), Color(0xFFE5B13A)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.pregnant_woman, color: Color(0xFF0B1B3D), size: 32),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Suivi grossesse',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B1B3D),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoColumn('Semaine', '$currentWeek', 'actuelle'),
                _buildInfoColumn('Restant', '$weeksLeft', 'semaines'),
                _buildInfoColumn('Prochain RDV', '${lastCheckup.day}/${lastCheckup.month}', 'à venir'),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: currentWeek / 40,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(Color(0xFF0B1B3D)),
            ),
            const SizedBox(height: 8),
            Text(
              'Bébé mesure environ ${currentWeek * 1.5} cm',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF0B1B3D),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, String subtitle) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0B1B3D),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF0B1B3D)),
        ),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 10, color: Color(0xFF0B1B3D)),
        ),
      ],
    );
  }
}
