// lib/presentation/thix_money/thix_money_savings.dart
import 'package:flutter/material.dart';
import 'package:thix_id/presentation/thix_money/widgets/custom_text_field.dart';
import 'package:thix_id/presentation/thix_money/widgets/amount_picker.dart';
import 'package:thix_id/services/wallet_service.dart';

class ThixMoneySavings extends StatefulWidget {
  const ThixMoneySavings({super.key});

  @override
  State<ThixMoneySavings> createState() => _ThixMoneySavingsState();
}

class _ThixMoneySavingsState extends State<ThixMoneySavings> {
  final WalletService _walletService = WalletService();
  final TextEditingController _amountController = TextEditingController();
  
  double _savingsBalance = 2500000;
  double _selectedAmount = 0;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Épargne planifiée'),
        backgroundColor: const Color(0xFF0B1B3D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Solde épargne
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0B1B3D), Color(0xFF1A3A6B)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total épargné', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text(
                    '${_savingsBalance.toStringAsFixed(0)} FCFA',
                    style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('Objectif: 5 000 000 FCFA', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _savingsBalance / 5000000,
                      backgroundColor: Colors.white24,
                      color: const Color(0xFFD4AF37),
                      minHeight: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Objectifs
            const Text('Mes objectifs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildGoalCard('Voyage', '500 000 FCFA', 0.3),
            const SizedBox(height: 12),
            _buildGoalCard('Achat maison', '3 000 000 FCFA', 0.15),
            const SizedBox(height: 12),
            _buildGoalCard('Études', '1 000 000 FCFA', 0.6),
            const SizedBox(height: 24),
            
            // Épargner maintenant
            const Text('Épargner maintenant', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            AmountPicker(
              amount: _selectedAmount,
              onChanged: (value) => setState(() => _selectedAmount = value),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _amountController,
              hintText: '0',
              prefixText: 'FCFA ',
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final amount = double.tryParse(value) ?? 0;
                setState(() => _selectedAmount = amount);
              },
            ),
            const SizedBox(height: 16),
            
            // Épargne automatique
            SwitchListTile(
              title: const Text('Épargne automatique'),
              subtitle: const Text('Prélever automatiquement chaque mois'),
              value: true,
              onChanged: (value) {},
              activeColor: const Color(0xFFD4AF37),
            ),
            const SizedBox(height: 24),
            
            // Bouton
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: const Color(0xFF0B1B3D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Épargner', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(String title, String target, double progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(target, style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFFD4AF37))),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              color: const Color(0xFFD4AF37),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
