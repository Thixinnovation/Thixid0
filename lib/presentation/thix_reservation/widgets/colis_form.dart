// lib/presentation/thix_reservation/widgets/colis_form.dart
import 'package:flutter/material.dart';

class ColisForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const ColisForm({super.key, required this.onSubmit});

  @override
  State<ColisForm> createState() => _ColisFormState();
}

class _ColisFormState extends State<ColisForm> {
  String _typeEnvoi = 'national';
  String _expediteurVille = 'Abidjan, Côte d\'Ivoire';
  String _expediteurAdresse = '';
  String _destinataireVille = 'Yamoussoukro, Côte d\'Ivoire';
  String _destinataireAdresse = '';
  String _typeColis = 'Document';
  RangeValues _poids = const RangeValues(0, 5);
  String _modeLivraison = 'Standard (2-3 jours)';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTypeEnvoi(),
        const SizedBox(height: 20),
        _buildExpediteur(),
        const SizedBox(height: 16),
        _buildDestinataire(),
        const SizedBox(height: 16),
        _buildTypeColisWidget(),
        const SizedBox(height: 16),
        _buildPoidsSlider(),
        const SizedBox(height: 16),
        _buildModeLivraison(),
        const SizedBox(height: 24),
        _buildSubmitButton(),
      ],
    );
  }

  Widget _buildTypeEnvoi() {
    return Row(
      children: [
        Expanded(
          child: FilterChip(
            label: const Text('National'),
            selected: _typeEnvoi == 'national',
            onSelected: (_) => setState(() => _typeEnvoi = 'national'),
            selectedColor: const Color(0xFFD4AF37),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilterChip(
            label: const Text('International'),
            selected: _typeEnvoi == 'international',
            onSelected: (_) => setState(() => _typeEnvoi = 'international'),
            selectedColor: const Color(0xFFD4AF37),
          ),
        ),
      ],
    );
  }

  Widget _buildExpediteur() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Expéditeur', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildVilleField('Ville', _expediteurVille, (val) => setState(() => _expediteurVille = val),
              ['Abidjan, Côte d\'Ivoire', 'Yamoussoukro, Côte d\'Ivoire', 'Bouaké, Côte d\'Ivoire']),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: 'Adresse complète',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.location_on, color: Colors.grey),
            ),
            onChanged: (val) => setState(() => _expediteurAdresse = val),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinataire() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Destinataire', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildVilleField('Ville', _destinataireVille, (val) => setState(() => _destinataireVille = val),
              ['Yamoussoukro, Côte d\'Ivoire', 'Abidjan, Côte d\'Ivoire', 'Bouaké, Côte d\'Ivoire']),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: 'Adresse complète',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.location_on, color: Colors.grey),
            ),
            onChanged: (val) => setState(() => _destinataireAdresse = val),
          ),
        ],
      ),
    );
  }

  Widget _buildVilleField(String label, String value, Function(String) onChanged, List<String> options) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
        onChanged: (val) => onChanged(val!),
        decoration: const InputDecoration(border: InputBorder.none),
      ),
    );
  }

  Widget _buildTypeColisWidget() {
    final types = ['Document', 'Colis', 'Fragile', 'Encombrant'];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Type de colis', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: types.map((type) {
              return FilterChip(
                label: Text(type),
                selected: _typeColis == type,
                onSelected: (_) => setState(() => _typeColis = type),
                selectedColor: const Color(0xFFD4AF37),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPoidsSlider() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Poids estimé', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          RangeSlider(
            values: _poids,
            min: 0,
            max: 50,
            divisions: 10,
            labels: RangeLabels('${_poids.start.round()} kg', '${_poids.end.round()} kg'),
            onChanged: (values) => setState(() => _poids = values),
            activeColor: const Color(0xFFD4AF37),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${_poids.start.round()} kg', style: const TextStyle(fontSize: 12)),
              Text('${_poids.end.round()} kg', style: const TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeLivraison() {
    final modes = [
      {'label': 'Standard (2-3 jours)', 'prix': '3.000 FCFA'},
      {'label': 'Express (24-48h)', 'prix': '5.000 FCFA'},
      {'label': 'Point Relais', 'prix': '2.000 FCFA'},
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mode de livraison', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...modes.map((mode) => RadioListTile<String>(
            title: Text(mode['label']!),
            subtitle: Text(mode['prix']!),
            value: mode['label']!,
            groupValue: _modeLivraison,
            onChanged: (val) => setState(() => _modeLivraison = val!),
            activeColor: const Color(0xFFD4AF37),
            contentPadding: EdgeInsets.zero,
          )),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          widget.onSubmit({
            'typeEnvoi': _typeEnvoi,
            'expediteurVille': _expediteurVille,
            'expediteurAdresse': _expediteurAdresse,
            'destinataireVille': _destinataireVille,
            'destinataireAdresse': _destinataireAdresse,
            'typeColis': _typeColis,
            'poids': _poids.end,
            'modeLivraison': _modeLivraison,
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD4AF37),
          foregroundColor: const Color(0xFF0B1B3D),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: const Text('Calculer le prix et continuer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
