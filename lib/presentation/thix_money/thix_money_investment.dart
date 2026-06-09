// lib/presentation/thix_money/thix_money_investment.dart
import 'package:flutter/material.dart';
import 'package:thix_id/presentation/thix_money/thix_money_investment_details.dart';
import 'package:thix_id/presentation/thix_money/widgets/investment_card.dart';

class ThixMoneyInvestment extends StatelessWidget {
  const ThixMoneyInvestment({super.key});

  final List<Map<String, dynamic>> _investments = const [
    {
      'title': 'Immobilier',
      'description': 'Investissez dans l\'immobilier africain',
      'return': '+9%',
      'risk': 'Faible',
      'minAmount': 100000,
      'color': Color(0xFF1E88E5),
    },
    {
      'title': 'Agriculture',
      'description': 'Projets agricoles rentables',
      'return': '+12%',
      'risk': 'Moyen',
      'minAmount': 50000,
      'color': Color(0xFF43A047),
    },
    {
      'title': 'Startup',
      'description': 'Investissez dans les startups innovantes',
      'return': '+17%',
      'risk': 'Élevé',
      'minAmount': 250000,
      'color': Color(0xFFD4AF37),
    },
    {
      'title': 'Obligations d\'État',
      'description': 'Placement sécurisé',
      'return': '+6%',
      'risk': 'Très faible',
      'minAmount': 50000,
      'color': Color(0xFF0B1B3D),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Investissements'),
        backgroundColor: const Color(0xFF0B1B3D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portefeuille total
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0B1B3D), Color(0xFF1A3A6B)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Votre portefeuille', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  const Text(
                    '1 250 000 FCFA',
                    style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.trending_up, color: Colors.green, size: 16),
                      const SizedBox(width: 4),
                      const Text('+8.5%', style: TextStyle(color: Colors.green)),
                      const SizedBox(width: 8),
                      const Text('vs mois dernier', style: TextStyle(color: Colors.white54)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Opportunités d'investissement
            const Text(
              'Opportunités',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._investments.map((investment) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InvestmentCard(
                title: investment['title'],
                description: investment['description'],
                returnRate: investment['return'],
                risk: investment['risk'],
                minAmount: investment['minAmount'],
                color: investment['color'],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ThixMoneyInvestmentDetails(
                        title: investment['title'],
                        returnRate: investment['return'],
                        minAmount: investment['minAmount'],
                      ),
                    ),
                  );
                },
              ),
            )),
          ],
        ),
      ),
    );
  }
}
