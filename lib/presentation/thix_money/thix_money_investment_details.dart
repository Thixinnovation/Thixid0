// lib/presentation/thix_money/thix_money_investment_details.dart
import 'package:flutter/material.dart';
import 'package:thix_id/presentation/thix_money/widgets/custom_text_field.dart';
import 'package:thix_id/services/wallet_service.dart';

class ThixMoneyInvestmentDetails extends StatefulWidget {
  final String title;
  final String returnRate;
  final double minAmount;

  const ThixMoneyInvestmentDetails({
    super.key,
    required this.title,
    required this.returnRate,
    required this.minAmount,
  });

  @override
  State<ThixMoneyInvestmentDetails> createState() => _ThixMoneyInvestmentDetailsState();
}

class _ThixMoneyInvestmentDetailsState extends State<ThixMoneyInvestmentDetails> {
  final WalletService _walletService = WalletService();
  final TextEditingController _amountController = TextEditingController();
  
  double _selectedAmount = 0;
  bool _isLoading = false;

  Future<void> _invest() async {
    if (_selectedAmount < widget.minAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Montant minimum: ${widget.minAmount.toStringAsFixed(0)} FCFA')),
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
                Text('Investissement dans ${widget.title}'),
                const SizedBox(height: 8),
                Text(
                  '${_selectedAmount.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37)),
                ),
                const SizedBox(height: 8),
                Text('Retour estimé: ${widget.returnRate}', style: const TextStyle(fontSize: 16)),
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
        title: Text(widget.title),
        backgroundColor: const Color(0xFF0B1B3D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informations
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Retour estimé', style: TextStyle(color: Colors.grey)),
                      Text(widget.returnRate, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Montant minimum', style: TextStyle(color: Colors.grey)),
                      Text('${widget.minAmount.toStringAsFixed(0)} FCFA', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Niveau de risque', style: TextStyle(color: Colors.grey)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.title == 'Immobilier' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.title == 'Immobilier' ? 'Faible' : widget.title == 'Agriculture' ? 'Moyen' : 'Élevé',
                          style: TextStyle(color: widget.title == 'Immobilier' ? Colors.green : Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Description
            const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              widget.title == 'Immobilier'
                  ? 'Investissez dans des projets immobiliers sélectionnés avec soin. Rendement stable et sécurisé.'
                  : widget.title == 'Agriculture'
                      ? 'Financez des projets agricoles innovants en Afrique. Impact positif et rendement attractif.'
                      : 'Investissez dans des startups prometteuses à fort potentiel de croissance.',
              style: const TextStyle(height: 1.5),
            ),
            const SizedBox(height: 24),
            
            // Montant
            const Text('Montant à investir', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _amountController,
              hintText: widget.minAmount.toStringAsFixed(0),
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
                onPressed: _isLoading ? null : _invest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: const Color(0xFF0B1B3D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Investir', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
