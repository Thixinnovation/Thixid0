// lib/presentation/thix_money/widgets/amount_picker.dart
import 'package:flutter/material.dart';

class AmountPicker extends StatelessWidget {
  final double amount;
  final ValueChanged<double> onChanged;
  final List<double>? quickAmounts;

  const AmountPicker({
    super.key,
    required this.amount,
    required this.onChanged,
    this.quickAmounts,
  });

  final List<double> _defaultAmounts = const [10000, 25000, 50000, 100000, 250000, 500000];

  @override
  Widget build(BuildContext context) {
    final amounts = quickAmounts ?? _defaultAmounts;
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: amounts.map((value) {
        final isSelected = amount == value;
        return FilterChip(
          label: Text('${value.toStringAsFixed(0)} FCFA'),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) onChanged(value);
          },
          selectedColor: const Color(0xFFD4AF37),
          showCheckmark: false,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        );
      }).toList(),
    );
  }
}
