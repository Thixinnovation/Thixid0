// lib/presentation/thix_money/thix_money_deposit.dart
import 'package:flutter/material.dart';
import 'package:thix_id/presentation/thix_money/widgets/custom_text_field.dart';
import 'package:thix_id/presentation/thix_money/widgets/amount_picker.dart';
import 'package:thix_id/services/wallet_service.dart';

class ThixMoneyDeposit extends StatefulWidget {
  const ThixMoneyDeposit({super.key});

  @override
  State<ThixMoneyDeposit> createState() => _ThixMoneyDepositState();
}

class _ThixMoneyDepositState extends State<ThixMoneyDeposit> {
  final WalletService _walletService = WalletService();
  final TextEditingController _amountController = TextEditingController();
  
  double _selectedAmount = 0;
  bool _isLoading = false;
  int _selectedMethod = 0; // 0 = Orange Money, 1 = MTN, 2 = Carte

  final List<Map<String, dynamic>> _depositMethods = [
    {'name': 'Orange Money', 'icon': Icons.phone_android, 'color': Color(0xFFFF6600)},
    {'name': 'MTN Mobile Money', 'icon': Icons.phone_android, 'color': Color(0xFFFFCC00)},
    {'name': 'Carte bancaire', 'icon': Icons.credit_card, 'color': Color(0xFF0B1B3D)},
  ];

  Future<void> _processDeposit() async {
    if (_selectedAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un montant valide')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _walletService.credit(_selectedAmount);
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Icon(Icons.check_circle, size: 64, color: Colors.green),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Dépôt effectué avec succès !'),
                const SizedBox(height: 8),
                Text(
                  '+${_selectedAmount.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37)),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
                child: const Text('OK'),
              ),
            ],
          ),
        ).then((_) => Navigator.pop(context, true));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Recharger mon compte'),
        backgroundColor: const Color(0xFF0B1B3D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Méthode de dépôt
            const Text('Méthode de paiement', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            Row(
              children: List.generate(_depositMethods.length, (index) {
                final method = _depositMethods[index];
                final isSelected = _selectedMethod == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedMethod = index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFD4AF37).withOpacity(0.1) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFD4AF37) : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(method['icon'], color: method['color']),
                          const SizedBox(height: 4),
                          Text(
                            method['name'],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            
            // Montant
            const Text('Montant', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
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
            const SizedBox(height: 32),
            
            // Bouton
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _processDeposit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: const Color(0xFF0B1B3D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Recharger', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
