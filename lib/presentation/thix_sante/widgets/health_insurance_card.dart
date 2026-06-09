import 'package:flutter/material.dart';

class HealthInsuranceCard extends StatelessWidget {
  final String planName;
  final String expiryDate;
  final VoidCallback? onTap;
  final bool hasInsurance;

  const HealthInsuranceCard({
    super.key,
    required this.planName,
    required this.expiryDate,
    this.onTap,
    this.hasInsurance = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasInsurance) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFD4AF37), Color(0xFFE5B13A)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.shield, size: 40, color: Color(0xFF0B1B3D)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Assurance santé',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B1B3D),
                    ),
                  ),
                  const Text(
                    'Bénéficiez d\'une couverture complète',
                    style: TextStyle(fontSize: 12, color: Color(0xFF0B1B3D)),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0B1B3D),
                    ),
                    child: const Text('Découvrir'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B1B3D), Color(0xFF1A2D56)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield, color: Color(0xFFD4AF37)),
              SizedBox(width: 8),
              Text(
                'Votre assurance',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            planName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Valable jusqu\'au $expiryDate',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: const Color(0xFF0B1B3D),
            ),
            child: const Text('Voir détails'),
          ),
        ],
      ),
    );
  }
}
