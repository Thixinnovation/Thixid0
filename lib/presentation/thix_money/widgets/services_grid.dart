// lib/presentation/thix_money/widgets/services_grid.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ServicesGrid extends StatelessWidget {
  final VoidCallback? onCreditTap;
  final VoidCallback? onSavingsTap;
  final VoidCallback? onTontineTap;
  final VoidCallback? onInvestmentTap;
  final VoidCallback? onInsuranceTap;
  final VoidCallback? onCardsTap;
  final VoidCallback? onInternationalTap;

  const ServicesGrid({
    super.key,
    this.onCreditTap,
    this.onSavingsTap,
    this.onTontineTap,
    this.onInvestmentTap,
    this.onInsuranceTap,
    this.onCardsTap,
    this.onInternationalTap,
  });

  @override
  Widget build(BuildContext context) {
    final services = [
      {'icon': Icons.flash_on, 'label': 'Crédit', 'color': const Color(0xFFD4AF37), 'onTap': onCreditTap},
      {'icon': Icons.savings, 'label': 'Épargne', 'color': Colors.green, 'onTap': onSavingsTap},
      {'icon': Icons.groups, 'label': 'Tontine', 'color': Colors.teal, 'onTap': onTontineTap},
      {'icon': Icons.show_chart, 'label': 'Investir', 'color': Colors.lime, 'onTap': onInvestmentTap},
      {'icon': Icons.shield, 'label': 'Assurance', 'color': Colors.blue, 'onTap': onInsuranceTap},
      {'icon': Icons.credit_card, 'label': 'Cartes', 'color': Colors.purple, 'onTap': onCardsTap},
      {'icon': Icons.public, 'label': 'International', 'color': Colors.cyan, 'onTap': onInternationalTap},
      {'icon': Icons.analytics, 'label': 'Planifier', 'color': Colors.deepPurple, 'onTap': null},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.9,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return GestureDetector(
          onTap: service['onTap'] as VoidCallback?,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4)],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (service['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(service['icon'] as IconData, color: service['color'] as Color, size: 22),
                ),
                const SizedBox(height: 6),
                Text(
                  service['label'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
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
