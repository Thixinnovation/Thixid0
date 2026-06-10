// lib/presentation/thix_reservation/widgets/payment_methods.dart
import 'package:flutter/material.dart';

class PaymentMethods extends StatefulWidget {
  final Function(String) onMethodSelected;
  final String? initialMethod;

  const PaymentMethods({
    super.key,
    required this.onMethodSelected,
    this.initialMethod,
  });

  @override
  State<PaymentMethods> createState() => _PaymentMethodsState();
}

class _PaymentMethodsState extends State<PaymentMethods> {
  late String _selectedMethod;

  final List<Map<String, dynamic>> _methods = [
    {'label': 'Carte bancaire', 'value': 'carte', 'icon': Icons.credit_card, 'color': Color(0xFF1A73E8)},
    {'label': 'Mobile Money', 'value': 'mobile', 'icon': Icons.phone_android, 'color': Color(0xFFFF6600)},
    {'label': 'THIX Money', 'value': 'thix', 'icon': Icons.account_balance_wallet, 'color': Color(0xFFD4AF37)},
    {'label': 'PayPal', 'value': 'paypal', 'icon': Icons.payment, 'color': Color(0xFF003087)},
  ];

  @override
  void initState() {
    super.initState();
    _selectedMethod = widget.initialMethod ?? 'carte';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Moyen de paiement',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          ..._methods.map((method) => RadioListTile<String>(
            title: Text(method['label']),
            value: method['value'],
            groupValue: _selectedMethod,
            onChanged: (value) {
              setState(() => _selectedMethod = value!);
              widget.onMethodSelected(value!);
            },
            activeColor: const Color(0xFFD4AF37),
            contentPadding: EdgeInsets.zero,
            secondary: Icon(method['icon'], color: method['color']),
          )),
        ],
      ),
    );
  }
}
