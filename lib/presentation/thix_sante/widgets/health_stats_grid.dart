import 'package:flutter/material.dart';

class HealthStatsGrid extends StatelessWidget {
  final int consultationsCount;
  final int examensCount;
  final int ordonnancesCount;
  final int urgencesCount;
  final VoidCallback? onConsultationsTap;
  final VoidCallback? onExamensTap;
  final VoidCallback? onOrdonnancesTap;
  final VoidCallback? onUrgencesTap;

  const HealthStatsGrid({
    super.key,
    required this.consultationsCount,
    required this.examensCount,
    required this.ordonnancesCount,
    required this.urgencesCount,
    this.onConsultationsTap,
    this.onExamensTap,
    this.onOrdonnancesTap,
    this.onUrgencesTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildStatCard(
          'Consultations',
          consultationsCount.toString(),
          'Cette année',
          Icons.calendar_today,
          onConsultationsTap,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          'Examens',
          examensCount.toString(),
          'En attente',
          Icons.science,
          onExamensTap,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          'Ordonnances',
          ordonnancesCount.toString(),
          'Actives',
          Icons.receipt,
          onOrdonnancesTap,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          'Urgences',
          urgencesCount.toString(),
          'Appels',
          Icons.emergency,
          onUrgencesTap,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    VoidCallback? onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: const Color(0xFFD4AF37)),
              const SizedBox(height: 8),
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
                title,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
