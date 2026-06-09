// lib/presentation/thix_money/thix_money_create_tontine.dart
import 'package:flutter/material.dart';
import 'package:thix_id/presentation/thix_money/widgets/custom_text_field.dart';

class ThixMoneyCreateTontine extends StatefulWidget {
  const ThixMoneyCreateTontine({super.key});

  @override
  State<ThixMoneyCreateTontine> createState() => _ThixMoneyCreateTontineState();
}

class _ThixMoneyCreateTontineState extends State<ThixMoneyCreateTontine> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _membersController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  int _frequency = 1; // 1 = Mensuel, 2 = Hebdomadaire, 3 = Trimestriel
  bool _isPrivate = true;

  final List<String> _frequencies = ['Mensuel', 'Hebdomadaire', 'Trimestriel'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Créer une tontine'),
        backgroundColor: const Color(0xFF0B1B3D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nom
            const Text('Nom de la tontine', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _nameController,
              hintText: 'Ex: Tontine Business',
              prefixIcon: Icons.group,
            ),
            const SizedBox(height: 16),
            
            // Montant
            const Text('Montant par membre', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _amountController,
              hintText: '0',
              prefixText: 'FCFA ',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.attach_money,
            ),
            const SizedBox(height: 16),
            
            // Nombre de membres
            const Text('Nombre de membres', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _membersController,
              hintText: 'Ex: 10',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.people,
            ),
            const SizedBox(height: 16),
            
            // Fréquence
            const Text('Fréquence', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Mensuel')),
                ButtonSegment(value: 1, label: Text('Hebdomadaire')),
                ButtonSegment(value: 2, label: Text('Trimestriel')),
              ],
              selected: {_frequency},
              onSelectionChanged: (Set<int> selection) {
                setState(() => _frequency = selection.first);
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Color(0xFFD4AF37);
                  }
                  return Colors.white;
                }),
              ),
            ),
            const SizedBox(height: 16),
            
            // Description
            const Text('Description (optionnelle)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _descriptionController,
              hintText: 'Décrivez le but de cette tontine',
              prefixIcon: Icons.description,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            
            // Type
            SwitchListTile(
              title: const Text('Tontine privée'),
              subtitle: const Text('Seulement sur invitation'),
              value: _isPrivate,
              onChanged: (value) => setState(() => _isPrivate = value),
              activeColor: const Color(0xFFD4AF37),
            ),
            const SizedBox(height: 32),
            
            // Bouton
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Icon(Icons.check_circle, size: 64, color: Colors.green),
                      content: const Text('Votre tontine a été créée avec succès !'),
                      actions: [
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  ).then((_) => Navigator.pop(context, true));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: const Color(0xFF0B1B3D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Créer la tontine', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
