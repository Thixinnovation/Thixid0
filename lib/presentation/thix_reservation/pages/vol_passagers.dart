// lib/presentation/thix_reservation/pages/vol_passagers.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VolPassagersPage extends StatefulWidget {
  const VolPassagersPage({super.key});

  @override
  State<VolPassagersPage> createState() => _VolPassagersPageState();
}

class _VolPassagersPageState extends State<VolPassagersPage> {
  late Map<String, dynamic> _vol;
  late String _tarif;
  late double _prix;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final data = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (data != null) {
      _vol = data['vol'] as Map<String, dynamic>;
      _tarif = data['tarif'] as String;
      _prix = data['prix'] as double;
    }
    _initControllers();
  }

  void _initControllers() {
    _controllers['prenom'] = TextEditingController();
    _controllers['nom'] = TextEditingController();
    _controllers['dateNaissance'] = TextEditingController();
    _controllers['nationalite'] = TextEditingController();
    _controllers['passeport'] = TextEditingController();
    _controllers['email'] = TextEditingController();
    _controllers['telephone'] = TextEditingController();
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_vol == null) {
      return const Scaffold(
        body: Center(child: Text('Aucune donnee de vol')),
      );
    }

    final compagnie = _vol['compagnie'] as String;
    final codeVol = _vol['codeVol'] as String;
    final depart = _vol['depart'] as String;
    final arrivee = _vol['arrivee'] as String;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Informations passagers'),
        backgroundColor: const Color(0xFF0B1B3D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFlightSummary(compagnie, codeVol, depart, arrivee),
            const SizedBox(height: 20),
            const Text('Passager 1 (Adulte)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildPassengerForm(),
            const SizedBox(height: 20),
            _buildServicesAdditionnels(),
            const SizedBox(height: 20),
            _buildContactInfo(),
            const SizedBox(height: 20),
            _buildSummary(),
            const SizedBox(height: 24),
            _buildContinueButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildFlightSummary(String compagnie, String codeVol, String depart, String arrivee) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.flight_takeoff, color: Color(0xFFD4AF37)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$depart → $arrivee', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('$compagnie • $codeVol • $_tarif', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Text('${_prix.round()} USD', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
        ],
      ),
    );
  }

  Widget _buildPassengerForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildTextField('Civilite', 'M.', _controllers['civilite']!, isEnabled: false)),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField('Prenom', 'Jean', _controllers['prenom']!)),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField('Nom', 'KABASELE', _controllers['nom']!),
          const SizedBox(height: 12),
          _buildTextField('Date de naissance', '12/05/1990', _controllers['dateNaissance']!, isDate: true),
          const SizedBox(height: 12),
          _buildTextField('Nationalite', 'Congolaise', _controllers['nationalite']!),
          const SizedBox(height: 12),
          _buildTextField('Numero de passeport', 'A1234567', _controllers['passeport']!),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Ajouter un passager'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController? controller, {bool isDate = false, bool isEnabled = true}) {
    return TextField(
      controller: controller,
      enabled: isEnabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: isDate ? const Icon(Icons.calendar_today, size: 16) : null,
      ),
    );
  }

  Widget _buildServicesAdditionnels() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Services additionnels', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ListTile(
            title: const Text('Bagage supplementaire'),
            subtitle: const Text('A partir de 30 USD'),
            trailing: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
              child: const Text('Ajouter', style: TextStyle(fontSize: 12)),
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Choix du siege'),
            subtitle: const Text('A partir de 15 USD'),
            trailing: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
              child: const Text('Ajouter', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Coordonnees', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildTextField('Email', 'jean.kabasele@email.com', _controllers['email']!),
          const SizedBox(height: 12),
          _buildTextField('Telephone', '+243 97 123 45 67', _controllers['telephone']!),
          const SizedBox(height: 8),
          Row(
            children: [
              Checkbox(value: true, onChanged: (_) {}),
              const Text('Recevoir les informations de vol par email et SMS', style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    final total = (_prix + 120).round();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('1 Adulte', style: TextStyle(fontWeight: FontWeight.w500)),
              Text('${_prix.round()} USD', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Taxes et frais', style: TextStyle(fontWeight: FontWeight.w500)),
              const Text('120 USD', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total a payer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('$total USD', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    final total = (_prix + 120).round();
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () => context.push('/reservation/vols/paiement', extra: {'vol': _vol, 'tarif': _tarif, 'prix': _prix}),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD4AF37),
          foregroundColor: const Color(0xFF0B1B3D),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Text('Continuer vers le paiement - $total USD', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
