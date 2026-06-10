// lib/presentation/thix_money/thix_money_transfer.dart
import 'package:flutter/material.dart';
import 'package:thix_id/presentation/thix_money/widgets/contact_tile.dart';
import 'package:thix_id/presentation/thix_money/widgets/amount_picker.dart';
import 'package:thix_id/presentation/thix_money/widgets/custom_text_field.dart';
import 'package:thix_id/services/wallet_service.dart';

class ThixMoneyTransfer extends StatefulWidget {
  final String? contactName;
  final String? contactPhone;
  final VoidCallback? onTransferComplete;

  const ThixMoneyTransfer({
    super.key,
    this.contactName,
    this.contactPhone,
    this.onTransferComplete,
  });

  @override
  State<ThixMoneyTransfer> createState() => _ThixMoneyTransferState();
}

class _ThixMoneyTransferState extends State<ThixMoneyTransfer> {
  final WalletService _walletService = WalletService();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  
  double _selectedAmount = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.contactName != null && widget.contactPhone != null) {
      _phoneController.text = widget.contactPhone!;
    }
  }

  Future<void> _sendTransfer() async {
    if (_selectedAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un montant valide')),
      );
      return;
    }

    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un numéro de téléphone')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _walletService.debit(_selectedAmount);
      widget.onTransferComplete?.call();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_selectedAmount.toStringAsFixed(0)} FCFA envoyés'),
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
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Envoyer de l\'argent'),
        backgroundColor: const Color(0xFF0B1B3D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Destinataire', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _phoneController,
              hintText: 'Numéro de téléphone',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
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
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendTransfer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: const Color(0xFF0B1B3D),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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
