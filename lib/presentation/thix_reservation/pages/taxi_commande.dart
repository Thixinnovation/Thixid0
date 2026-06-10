// lib/presentation/thix_reservation/pages/taxi_commande.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TaxiCommandePage extends StatefulWidget {
  const TaxiCommandePage({super.key});

  @override
  State<TaxiCommandePage> createState() => _TaxiCommandePageState();
}

class _TaxiCommandePageState extends State<TaxiCommandePage> {
  String _depart = 'Ma position actuelle';
  String _destination = '';
  String _typeVehicule = 'Standard';
  String _paiement = 'Mobile Money';
  String _heure = 'Maintenant';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Commander un taxi'),
        backgroundColor: const Color(0xFF0B1B3D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Commander un trajet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildLocationField('Départ', _depart, (val) => setState(() => _depart = val), Icons.my_location),
            const SizedBox(height: 12),
            _buildLocationField('Destination', _destination, (val) => setState(() => _destination = val), Icons.location_on),
            const SizedBox(height: 16),
            _buildTypeVehicule(),
            const SizedBox(height: 16),
            _buildPaiement(),
            const SizedBox(height: 16),
            _buildHeure(),
            const SizedBox(height: 24),
            _buildCommanderButton(),
            const SizedBox(height: 24),
            _buildOffresMoment(),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationField(String label, String value, Function(String) onChanged, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4)],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: label,
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: label == 'Départ' ? const Color(0xFFD4AF37) : Colors.red),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTypeVehicule() {
    final types = ['Standard', 'Confort', 'Berline', 'Van'];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Type de véhicule', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: types.map((type) {
              return FilterChip(
                label: Text(type),
                selected: _typeVehicule == type,
                onSelected: (_) => setState(() => _typeVehicule = type),
                selectedColor: const Color(0xFFD4AF37),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPaiement() {
    final methodes = ['Mobile Money', 'Carte bancaire', 'Cash', 'THIX Money'];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Paiement', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: methodes.map((methode) {
              return FilterChip(
                label: Text(methode),
                selected: _paiement == methode,
                onSelected: (_) => setState(() => _paiement = methode),
                selectedColor: const Color(0xFFD4AF37),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeure() {
    final heures = ['Maintenant', 'Plus tard'];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Heure', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: heures.map((heure) {
              return FilterChip(
                label: Text(heure),
                selected: _heure == heure,
                onSelected: (_) => setState(() => _heure = heure),
                selectedColor: const Color(0xFFD4AF37),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCommanderButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () => context.push('/reservation/taxi/trajets'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD4AF37),
          foregroundColor: const Color(0xFF0B1B3D),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: const Text('Commander un taxi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Widget _buildOffresMoment() {
    final offres = [
      {'titre': 'Premier trajet', 'reduction': '-20%', 'prix': '2.000 FCFA', 'original': '2.500 FCFA'},
      {'titre': 'Trajet Aéroport', 'reduction': '-15%', 'prix': '3.000 FCFA', 'original': '3.500 FCFA'},
      {'titre': 'Trajets Confort', 'reduction': '-10%', 'prix': '2.700 FCFA', 'original': '3.000 FCFA'},
      {'titre': 'Abonnement', 'reduction': '-10%', 'prix': '15.000 FCFA', 'original': '16.500 FCFA'},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Offres du moment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: offres.length,
            itemBuilder: (context, index) {
              final offre = offres[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(offre['titre']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
                          child: Text(offre['reduction']!, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(offre['original']!, style: const TextStyle(decoration: TextDecoration.lineThrough, fontSize: 10, color: Colors.grey)),
                        const SizedBox(width: 8),
                        Text(offre['prix']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD4AF37), fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
