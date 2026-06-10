// lib/presentation/thix_money/thix_money_credit.dart
import 'package:flutter/material.dart';
import 'package:thix_id/presentation/thix_money/widgets/amount_picker.dart';
import 'package:thix_id/services/wallet_service.dart';

class ThixMoneyCredit extends StatefulWidget {
  final VoidCallback? onCreditComplete;

  const ThixMoneyCredit({super.key, this.onCreditComplete});

  @override
  State<ThixMoneyCredit> createState() => _ThixMoneyCreditState();
}

class _ThixMoneyCreditState extends State<ThixMoneyCredit> {
  final WalletService _walletService = WalletService();
  final TextEditingController _amountController = TextEditingController();
  
  double _selectedAmount = 0;
  bool _isLoading = false;

  Future<void> _requestCredit() async {
    if (_selectedAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un montant valide')),
      );
      return;
    }

    if (_selectedAmount > 5000000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Montant maximum: 5 000 000 FCFA')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _walletService.requestCredit(_selectedAmount);
      widget.onCreditComplete?.call();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Crédit de ${_selectedAmount.toStringAsFixed(0)} FCFA approuvé !'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
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
      appBar: AppBar(
        title: const Text('Crédit instantané'),
        backgroundColor: const Color(0xFF0B1B3D),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFFD4AF37)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Crédit disponible', style: TextStyle(fontWeight: FontWeight.w500)),
                        Text('Jusqu\'à 5 000 000 FCFA', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Montant souhaité', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            AmountPicker(
              amount: _selectedAmount,
              onChanged: (value) => setState(() => _selectedAmount = value),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Ou saisir un montant',
                prefixText: 'FCFA ',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                final amount = double.tryParse(value) ?? 0;
                setState(() => _selectedAmount = amount);
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _requestCredit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: const Color(0xFF0B1B3D),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Demander le crédit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
