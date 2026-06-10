// lib/presentation/thix_reservation/pages/vol_paiement.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VolPaiementPage extends StatefulWidget {
  const VolPaiementPage({super.key});

  @override
  State<VolPaiementPage> createState() => _VolPaiementPageState();
}

class _VolPaiementPageState extends State<VolPaiementPage> {
  Map<String, dynamic>? _vol;
  String _tarif = '';
  double _prix = 0;
  String _paiementMethod = 'carte';
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  bool _isProcessing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final data = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (data != null) {
      _vol = data['vol'] as Map<String, dynamic>;
      _tarif = data['tarif'] as String;
      _prix = data['prix'] as double;
    }
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isProcessing = false);
    if (mounted) {
      context.push('/reservation/vols/confirmation', extra: {'vol': _vol, 'tarif': _tarif, 'prix': _prix});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_vol == null) {
      return const Scaffold(
        body: Center(child: Text('Aucune donnee de paiement')),
      );
    }

    final total = (_prix + 120).round();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Paiement securise'),
        backgroundColor: const Color(0xFF0B1B3D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFlightSummary(),
            const SizedBox(height: 20),
            _buildPaymentMethods(),
            const SizedBox(height: 20),
            _buildCardForm(),
            const SizedBox(height: 20),
            _buildSecureBadges(),
            const SizedBox(height: 24),
            _buildPayButton(total),
          ],
        ),
      ),
    );
  }

  Widget _buildFlightSummary() {
    if (_vol == null) return const SizedBox();
    
    final depart = _vol!['depart'] as String;
    final arrivee = _vol!['arrivee'] as String;
    final total = (_prix + 120).round();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$depart → $arrivee', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(_tarif, style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('$total USD', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Moyen de paiement', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildMethodCard('Carte bancaire', 'carte', Icons.credit_card),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMethodCard('Mobile Money', 'mobile', Icons.phone_android),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildMethodCard('THIX Money', 'thix', Icons.account_balance_wallet),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMethodCard('PayPal', 'paypal', Icons.payment),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMethodCard(String label, String value, IconData icon) {
    final isSelected = _paiementMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _paiementMethod = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD4AF37).withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? const Color(0xFFD4AF37) : Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFFD4AF37) : Colors.grey),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, color: isSelected ? const Color(0xFFD4AF37) : Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildCardForm() {
    if (_paiementMethod != 'carte') return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          TextField(
            controller: _cardNumberController,
            decoration: InputDecoration(
              labelText: 'Numero de carte',
              hintText: '1234 5678 9012 3456',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.credit_card),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _expiryController,
                  decoration: InputDecoration(
                    labelText: 'MM/YY',
                    hintText: '12/25',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _cvvController,
                  decoration: InputDecoration(
                    labelText: 'CVV',
                    hintText: '123',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  obscureText: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecureBadges() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_outline, size: 14, color: Colors.green),
        const SizedBox(width: 4),
        const Text('Paiement 100% securise', style: TextStyle(fontSize: 11, color: Colors.green)),
        const SizedBox(width: 16),
        Icon(Icons.verified_user, size: 14, color: Colors.blue),
        const SizedBox(width: 4),
        const Text('Donnees cryptees', style: TextStyle(fontSize: 11, color: Colors.blue)),
      ],
    );
  }

  Widget _buildPayButton(int total) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD4AF37),
          foregroundColor: const Color(0xFF0B1B3D),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: _isProcessing
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : Text('Payer $total USD', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
