// lib/presentation/thix_money/thix_money_insurance.dart
import 'package:flutter/material.dart';

class ThixMoneyInsurance extends StatelessWidget {
  const ThixMoneyInsurance({super.key});

  final List<Map<String, dynamic>> _insurances = const [
    {
      'title': 'Assurance Santé',
      'description': 'Couverture médicale complète',
      'price': '15 000 FCFA/mois',
      'icon': Icons.health_and_safety,
      'color': Color(0xFF4CAF50),
    },
    {
      'title': 'Assurance Vie',
      'description': 'Protection pour vos proches',
      'price': '25 000 FCFA/mois',
      'icon': Icons.favorite,
      'color': Color(0xFFE91E63),
    },
    {
      'title': 'Assurance Auto',
      'description': 'Protection pour votre véhicule',
      'price': '20 000 FCFA/mois',
      'icon': Icons.directions_car,
      'color': Color(0xFF2196F3),
    },
    {
      'title': 'Assurance Habitation',
      'description': 'Protection pour votre logement',
      'price': '10 000 FCFA/mois',
      'icon': Icons.home,
      'color': Color(0xFFFF9800),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Assurances'),
        backgroundColor: const Color(0xFF0B1B3D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mes assurances actives
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mes assurances actives',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildActiveInsurance('Assurance Santé', 'Validée', 'Prochaine échéance: 15/01/2025'),
                  const Divider(),
                  _buildActiveInsurance('Assurance Auto', 'En attente', 'Souscription en cours'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Découvrir
            const Text(
              'Découvrir',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._insurances.map((insurance) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildInsuranceCard(insurance),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveInsurance(String title, String status, String date) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: status == 'Validée' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status,
            style: TextStyle(color: status == 'Validée' ? Colors.green : Colors.orange, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildInsuranceCard(Map<String, dynamic> insurance) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: insurance['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(insurance['icon'], color: insurance['color'], size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(insurance['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(insurance['description'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(insurance['price'], style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFFD4AF37))),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: const Color(0xFF0B1B3D),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Souscrire'),
          ),
        ],
      ),
    );
  }
}
