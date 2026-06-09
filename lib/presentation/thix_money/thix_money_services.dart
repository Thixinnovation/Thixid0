// lib/presentation/thix_money/thix_money_services.dart
import 'package:flutter/material.dart';
import 'package:thix_id/presentation/thix_money/widgets/service_tile.dart';
import 'package:thix_id/presentation/thix_money/widgets/section_title.dart';
import 'package:thix_id/presentation/thix_money/thix_money_credit.dart';
import 'package:thix_id/presentation/thix_money/thix_money_savings.dart';
import 'package:thix_id/presentation/thix_money/thix_money_tontine.dart';
import 'package:thix_id/presentation/thix_money/thix_money_investment.dart';
import 'package:thix_id/presentation/thix_money/thix_money_insurance.dart';
import 'package:thix_id/presentation/thix_money/thix_money_international_transfer.dart';
import 'package:thix_id/presentation/thix_money/thix_money_cards.dart';
import 'package:thix_id/models/money_service_model.dart';

class ThixMoneyServices extends StatelessWidget {
  const ThixMoneyServices({super.key});

  void _navigateToService(BuildContext context, MoneyServiceModel service) {
    switch (service.id) {
      case 'credit':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ThixMoneyCredit()));
        break;
      case 'savings':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ThixMoneySavings()));
        break;
      case 'tontine':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ThixMoneyTontine()));
        break;
      case 'investment':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ThixMoneyInvestment()));
        break;
      case 'insurance':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ThixMoneyInsurance()));
        break;
      case 'international':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ThixMoneyInternationalTransfer()));
        break;
      case 'cards':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ThixMoneyCards()));
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service bientôt disponible')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Tous les services'),
        backgroundColor: const Color(0xFF0B1B3D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(title: 'Finances', onSeeAll: null),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.9,
              children: mockMoneyServices.where((s) => s.category == 'finance').map((service) {
                return ServiceTile(
                  service: service,
                  onTap: () => _navigateToService(context, service),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const SectionTitle(title: 'Paiements', onSeeAll: null),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.9,
              children: mockMoneyServices.where((s) => s.category == 'payment').map((service) {
                return ServiceTile(
                  service: service,
                  onTap: () => _navigateToService(context, service),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const SectionTitle(title: 'Épargne & Investissement', onSeeAll: null),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.9,
              children: mockMoneyServices.where((s) => s.category == 'investment').map((service) {
                return ServiceTile(
                  service: service,
                  onTap: () => _navigateToService(context, service),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
