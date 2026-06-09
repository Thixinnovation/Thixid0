// lib/presentation/thix_money/thix_money_cards.dart
import 'package:flutter/material.dart';
import 'package:thix_id/presentation/thix_money/widgets/virtual_card_widget.dart';

class ThixMoneyCards extends StatelessWidget {
  const ThixMoneyCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Mes cartes'),
        backgroundColor: const Color(0xFF0B1B3D),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Nouvelle carte virtuelle'),
                  content: const Text('Souhaitez-vous créer une nouvelle carte virtuelle ?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
                      child: const Text('Créer'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const VirtualCardWidget(),
            const SizedBox(height: 24),
            const Text(
              'Transactions récentes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: const [
                  ListTile(
                    leading: CircleAvatar(child: Icon(Icons.shopping_cart)),
                    title: Text('Market Store'),
                    subtitle: Text('Aujourd\'hui'),
                    trailing: Text('-15 000 FCFA', style: TextStyle(color: Colors.red)),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: CircleAvatar(child: Icon(Icons.restaurant)),
                    title: Text('Restaurant Le Délice'),
                    subtitle: Text('Hier'),
                    trailing: Text('-35 000 FCFA', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
