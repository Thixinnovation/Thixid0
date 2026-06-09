// lib/presentation/thix_money/thix_money_international_transfer.dart
import 'package:flutter/material.dart';
import 'package:thix_id/presentation/thix_money/widgets/custom_text_field.dart';
import 'package:thix_id/presentation/thix_money/widgets/amount_picker.dart';
import 'package:thix_id/services/wallet_service.dart';

class ThixMoneyInternationalTransfer extends StatefulWidget {
  const ThixMoneyInternationalTransfer({super.key});

  @override
  State<ThixMoneyInternationalTransfer> createState() => _ThixMoneyInternationalTransferState();
}

class _ThixMoneyInternationalTransferState extends State<ThixMoneyInternationalTransfer> {
  final WalletService _walletService = WalletService();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _beneficiaryController = TextEditingController();
  final TextEditingController _ibanController = TextEditingController();
  final TextEditingController _bicController = TextEditingController();
  
  double _selectedAmount = 0;
  String _selectedCountry = 'France';
  String _selectedCurrency = 'EUR';
  bool _isLoading = false;

  final List<String> _countries = ['France', 'Canada', 'Belgique', 'Suisse', 'USA', 'UK'];
  final Map<String, String> _currencies = {
    'France': 'EUR',
    'Canada': 'CAD',
    'Belgique': 'EUR',
    'Suisse': 'CHF',
    'USA': 'USD',
    'UK': 'GBP',
  };
  final Map<String, double> _exchangeRates = {
    'EUR': 655.96,
    'CAD': 445.00,
    'CHF': 680.00,
    'USD': 610.00,
    'GBP': 770.00,
  };

  double get _convertedAmount {
    final rate = _exchangeRates[_selectedCurrency] ?? 1;
    return _selectedAmount / rate;
  }

  Future<void> _sendTransfer() async {
    if (_selectedAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un montant valide')),
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
                const Text('Virement international envoyé !'),
                const SizedBox(height: 8),
                Text(
                  '${_selectedAmount.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37)),
                ),
                const SizedBox(height: 8),
                Text('Soit ${_convertedAmount.toStringAsFixed(2)} $_selectedCurrency'),
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
        title: const Text('Virement international'),
        backgroundColor: const Color(0xFF0B1B3D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pays
            const Text('Pays de destination', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCountry,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.public),
              ),
              items: _countries.map((country) {
                return DropdownMenuItem(value: country, child: Text(country));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCountry = value!;
                  _selectedCurrency = _currencies[_selectedCountry]!;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Bénéficiaire
            const Text('Nom du bénéficiaire', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _beneficiaryController,
              hintText: 'Nom complet',
              prefixIcon: Icons.person,
            ),
            const SizedBox(height: 16),
            
            // IBAN
            const Text('IBAN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _ibanController,
              hintText: 'Numéro IBAN',
              prefixIcon: Icons.credit_card,
            ),
            const SizedBox(height: 16),
            
            // BIC/SWIFT
            const Text('BIC/SWIFT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _bicController,
              hintText: 'Code BIC/SWIFT',
              prefixIcon: Icons.code,
            ),
            const SizedBox(height: 24),
            
            // Montant en FCFA
            const Text('Montant (FCFA)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
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
            
            // Conversion
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Montant reçu', style: TextStyle(fontWeight: FontWeight.w500)),
                  Text(
                    '${_convertedAmount.toStringAsFixed(2)} $_selectedCurrency',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFFD4AF37)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
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
                  const Text('Frais de transfert', style: TextStyle(color: Colors.grey)),
                  Text('${(_selectedAmount * 0.02).toStringAsFixed(0)} FCFA', style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Bouton
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendTransfer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: const Color(0xFF0B1B3D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Envoyer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
