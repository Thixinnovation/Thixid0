// lib/presentation/thix_money/widgets/services_grid.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ServicesGrid extends StatelessWidget {
  const ServicesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final services = [
      {'icon': Icons.flash_on, 'label': 'Crédit', 'color': const Color(0xFFD4AF37), 'route': '/thix-money/credit'},
      {'icon': Icons.shield, 'label': 'Assurance', 'color': Colors.blue, 'route': '/thix-money/insurance'},
      {'icon': Icons.savings, 'label': 'Épargne', 'color': Colors.green, 'route': '/thix-money/savings'},
      {'icon': Icons.currency_exchange, 'label': 'Change', 'color': Colors.orange, 'route': '/thix-money/exchange'},
      {'icon': Icons.store, 'label': 'Marchand', 'color': Colors.purple, 'route': '/thix-money/merchant'},
      {'icon': Icons.favorite, 'label': 'Don', 'color': Colors.red, 'route': '/thix-money/donations'},
      {'icon': Icons.groups, 'label': 'Tontine', 'color': Colors.teal, 'route': '/thix-money/tontine'},
      {'icon': Icons.school, 'label': 'Éducation', 'color': Colors.indigo, 'route': '/thix-money/education'},
      {'icon': Icons.public, 'label': 'Virement', 'color': Colors.cyan, 'route': '/thix-money/international'},
      {'icon': Icons.account_balance, 'label': 'Microfinance', 'color': Colors.brown, 'route': '/thix-money/microfinance'},
      {'icon': Icons.show_chart, 'label': 'Investir', 'color': Colors.lime, 'route': '/thix-money/investment'},
      {'icon': Icons.analytics, 'label': 'Planifier', 'color': Colors.deepPurple, 'route': '/thix-money/planning'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,  // 4 colonnes au lieu de 3
        childAspectRatio: 0.85,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return GestureDetector(
          onTap: () => context.push(service['route'] as String),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 2)],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: (service['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(service['icon'] as IconData, color: service['color'] as Color, size: 20),
                ),
                const SizedBox(height: 4),
                Text(
                  service['label'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
