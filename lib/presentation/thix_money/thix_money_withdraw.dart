// lib/presentation/thix_money/thix_money_withdraw.dart
import 'package:flutter/material.dart';
import 'package:thix_id/presentation/thix_money/widgets/custom_text_field.dart';
import 'package:thix_id/presentation/thix_money/widgets/amount_picker.dart';
import 'package:thix_id/presentation/thix_money/widgets/bank_account_tile.dart';
import 'package:thix_id/services/wallet_service.dart';

class ThixMoneyWithdraw extends StatefulWidget {
  const ThixMoneyWithdraw({super.key});

  @override
  State<ThixMoneyWithdraw> createState() => _ThixMoneyWithdrawState();
}

class _ThixMoneyWithdrawState extends State<ThixMoneyWithdraw> {
  final WalletService _walletService = WalletService();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  
  double _selectedAmount = 0;
  double _balance = 0;
  bool _isLoading = false;
  int _selectedMethod = 0; // 0 = Orange Money, 1 = MTN, 2 = Banque

  final List<Map<String, dynamic>> _withdrawMethods = [
    {'name': 'Orange Money', 'icon': Icons.phone_android, 'color': Color(0xFFFF6600)},
    {'name': 'MTN Mobile Money', 'icon': Icons.phone_android, 'color': Color(0xFFFFCC00)},
    {'name': 'Compte bancaire', 'icon': Icons.account_balance, 'color': Color(0xFF0B1B3D)},
  ];

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final balance = await _walletService.getBalance();
    setState(() => _balance = balance);
  }

  Future<void> _processWithdraw() async {
    if (_selectedAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un montant valide')),
      );
      return;
    }

    if (_selectedAmount > _balance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Montant supérieur au solde disponible')),
      );
      return;
    }

    if (_accountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer votre numéro de compte')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _walletService.debit(_selectedAmount);
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Icon(Icons.check_circle, size: 64, color: Colors.green),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Retrait effectué avec succès !'),
                const SizedBox(height: 8),
                Text(
                  '${_selectedAmount.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37)),
                ),
                const SizedBox(height: 8),
                Text('Vers: ${_withdrawMethods[_selectedMethod]['name']}', style: const TextStyle(fontSize: 12)),
                Text('Compte: ${_accountController.text}', style: const TextStyle(fontSize: 12)),
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
        title: const Text('Retrait d\'argent'),
        backgroundColor: const Color(0xFF0B1B3D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Solde disponible
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Solde disponible', style: TextStyle(fontWeight: FontWeight.w500)),
                  Text(
                    '${_balance.toStringAsFixed(0)} FCFA',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFFD4AF37)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Méthode de retrait
            const Text('Méthode de retrait', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            Row(
              children: List.generate(_withdrawMethods.length, (index) {
                final method = _withdrawMethods[index];
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
            
            // Numéro de compte
            const Text('Numéro de compte', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _accountController,
              hintText: _selectedMethod == 2 ? 'Numéro de compte bancaire' : 'Numéro de téléphone',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
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
            const SizedBox(height: 24),
            
            // Frais
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Frais de retrait', style: TextStyle(color: Colors.grey)),
                  Text(
                    '${(_selectedAmount * 0.01).toStringAsFixed(0)} FCFA',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Total
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total à débiter', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    '${(_selectedAmount + (_selectedAmount * 0.01)).toStringAsFixed(0)} FCFA',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFFD4AF37)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Bouton
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _processWithdraw,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: const Color(0xFF0B1B3D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Retirer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
