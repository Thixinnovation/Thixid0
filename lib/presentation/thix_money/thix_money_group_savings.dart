// lib/presentation/thix_money/thix_money_group_savings.dart
import 'package:flutter/material.dart';
import 'package:thix_id/presentation/thix_money/widgets/custom_text_field.dart';
import 'package:thix_id/presentation/thix_money/widgets/amount_picker.dart';

class ThixMoneyGroupSavings extends StatefulWidget {
  const ThixMoneyGroupSavings({super.key});

  @override
  State<ThixMoneyGroupSavings> createState() => _ThixMoneyGroupSavingsState();
}

class _ThixMoneyGroupSavingsState extends State<ThixMoneyGroupSavings> {
  final TextEditingController _amountController = TextEditingController();
  double _selectedAmount = 0;
  int _selectedGroup = 0;

  final List<Map<String, dynamic>> _groups = [
    {'name': 'Épargne Voyage', 'members': 12, 'goal': '5 000 000 FCFA', 'current': '2 500 000 FCFA'},
    {'name': 'Épargne Projet', 'members': 8, 'goal': '10 000 000 FCFA', 'current': '3 200 000 FCFA'},
    {'name': 'Épargne Urgence', 'members': 15, 'goal': '2 000 000 FCFA', 'current': '1 800 000 FCFA'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Épargne groupe'),
        backgroundColor: const Color(0xFF0B1B3D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Groupes actifs
            const Text('Mes groupes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._groups.asMap().entries.map((entry) {
              final index = entry.key;
              final group = entry.value;
              final isSelected = _selectedGroup == index;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFD4AF37).withOpacity(0.1) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFD4AF37) : Colors.grey.shade200,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: RadioListTile<int>(
                  value: index,
                  groupValue: _selectedGroup,
                  onChanged: (value) => setState(() => _selectedGroup = value!),
                  title: Text(group['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${group['members']} membres'),
                      const SizedBox(height: 4),
                      Text('Objectif: ${group['goal']}', style: const TextStyle(fontSize: 12)),
                      Text('Collecté: ${group['current']}', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  activeColor: const Color(0xFFD4AF37),
                ),
              );
            }),
            const SizedBox(height: 24),
            
            // Contribution
            const Text('Ma contribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
            
            // Fréquence
            const Text('Fréquence', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildFrequencyChip('Hebdomadaire', true),
                const SizedBox(width: 8),
                _buildFrequencyChip('Mensuelle', false),
                const SizedBox(width: 8),
                _buildFrequencyChip('Trimestrielle', false),
              ],
            ),
            const SizedBox(height: 32),
            
            // Bouton
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: const Color(0xFF0B1B3D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Contribuer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencyChip(String label, bool isSelected) {
    return Expanded(
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {},
        selectedColor: const Color(0xFFD4AF37),
        showCheckmark: false,
      ),
    );
  }
}
