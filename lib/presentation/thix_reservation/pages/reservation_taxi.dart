// lib/presentation/thix_reservation/pages/reservation_taxi.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ReservationTaxiPage extends StatefulWidget {
  const ReservationTaxiPage({super.key});

  @override
  State<ReservationTaxiPage> createState() => _ReservationTaxiPageState();
}

class _ReservationTaxiPageState extends State<ReservationTaxiPage> {
  String _depart = 'Ma position actuelle';
  String _destination = '';
  String _typeVehicule = 'Standard';
  String _paiement = 'Mobile Money';
  String _heure = 'Maintenant';
  String _heureCustom = '';

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
            // Commander un trajet
            const Text('Commander un trajet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            _buildLocationField('Départ', _depart, (val) => setState(() => _depart = val)),
            const SizedBox(height: 12),
            _buildDestinationField(),
            const SizedBox(height: 16),
            _buildTypeVehicule(),
            const SizedBox(height: 16),
            _buildPaiement(),
            const SizedBox(height: 16),
            _buildHeure(),
            const SizedBox(height: 24),

            // Bouton commander
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: const Color(0xFF0B1B3D),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Commander un taxi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 24),

            // Actions rapides
            const Text('Actions rapides', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildQuickActions(),
            const SizedBox(height: 24),

            // Offres du moment
            const Text('Offres du moment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildOffresMoment(),
            const SizedBox(height: 24),

            // Comment ça marche ?
            const Text('Comment ça marche ?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildHowItWorks(),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationField(String label, String value, Function(String) onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: value,
            decoration: InputDecoration(
              hintText: label,
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.location_on, size: 18, color: Color(0xFFD4AF37)),
            ),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Destination', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Où allez-vous ?',
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.location_on, size: 18, color: Colors.red),
            ),
            onChanged: (val) => setState(() => _destination = val),
          ),
        ],
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
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Type de véhicule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            children: types.map((type) {
              return FilterChip(
                label: Text(type),
                selected: _typeVehicule == type,
                onSelected: (_) => setState(() => _typeVehicule = type),
                selectedColor: const Color(0xFFD4AF37),
                backgroundColor: Colors.grey.shade100,
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
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Paiement', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            children: methodes.map((methode) {
              return FilterChip(
                label: Text(methode),
                selected: _paiement == methode,
                onSelected: (_) => setState(() => _paiement = methode),
                selectedColor: const Color(0xFFD4AF37),
                backgroundColor: Colors.grey.shade100,
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
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Heure', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            children: heures.map((heure) {
              return FilterChip(
                label: Text(heure),
                selected: _heure == heure,
                onSelected: (_) => setState(() => _heure = heure),
                selectedColor: const Color(0xFFD4AF37),
                backgroundColor: Colors.grey.shade100,
              );
            }).toList(),
          ),
          if (_heure == 'Plus tard') ...[
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Sélectionner une heure',
                prefixIcon: Icon(Icons.access_time),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {'icon': Icons.history, 'label': 'Trajets récents', 'color': Colors.blue},
      {'icon': Icons.favorite, 'label': 'Favoris', 'color': Colors.red},
      {'icon': Icons.people, 'label': 'Chauffeurs favoris', 'color': Colors.green},
      {'icon': Icons.location_on, 'label': 'Lieux enregistrés', 'color': Colors.orange},
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4)],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(action['icon'] as IconData, color: action['color'] as Color, size: 28),
              const SizedBox(height: 8),
              Text(action['label'] as String, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOffresMoment() {
    final offres = [
      {'titre': 'Premier trajet', 'reduction': '-20%', 'prix': '2.000 FCFA', 'original': '2.500 FCFA'},
      {'titre': 'Trajet Aéroport', 'reduction': '-15%', 'prix': '3.000 FCFA', 'original': '3.500 FCFA'},
      {'titre': 'Trajets Confort', 'reduction': '-10%', 'prix': '2.700 FCFA', 'original': '3.000 FCFA'},
      {'titre': 'Abonnement', 'reduction': '-10%', 'prix': '15.000 FCFA', 'original': '16.500 FCFA'},
    ];
    return SizedBox(
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
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4)],
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
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: const Color(0xFF0B1B3D),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    minimumSize: const Size(double.infinity, 25),
                  ),
                  child: const Text('Profiter', style: TextStyle(fontSize: 10)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHowItWorks() {
    const steps = [
      {'step': '1', 'text': 'Entrez votre destination'},
      {'step': '2', 'text': 'Choisissez votre type de véhicule'},
      {'step': '3', 'text': 'Payez en toute sécurité'},
      {'step': '4', 'text': 'Nous vous déposons à destination'},
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: steps.map((step) {
        return Expanded(
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFD4AF37),
                  shape: BoxShape.circle,
                ),
                child: Center(child: Text(step['step']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(height: 8),
              Text(step['text']!, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center),
            ],
          ),
        );
      }).toList(),
    );
  }
}
