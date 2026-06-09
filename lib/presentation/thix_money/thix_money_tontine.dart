// lib/presentation/thix_money/thix_money_tontine.dart
import 'package:flutter/material.dart';
import 'package:thix_id/presentation/thix_money/thix_money_create_tontine.dart';
import 'package:thix_id/presentation/thix_money/widgets/tontine_item.dart';
import 'package:thix_id/models/tontine.dart';

class ThixMoneyTontine extends StatelessWidget {
  const ThixMoneyTontine({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Mes tontines'),
        backgroundColor: const Color(0xFF0B1B3D),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ThixMoneyCreateTontine()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockTontines.length,
        itemBuilder: (context, index) {
          final tontine = mockTontines[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TontineItem(
              tontine: tontine,
              onTap: () {
                // Voir détails de la tontine
              },
            ),
          );
        },
      ),
    );
  }
}
