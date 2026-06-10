// lib/presentation/thix_reservation/pages/reservation_colis.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ReservationColisPage extends StatefulWidget {
  const ReservationColisPage({super.key});

  @override
  State<ReservationColisPage> createState() => _ReservationColisPageState();
}

class _ReservationColisPageState extends State<ReservationColisPage> {
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Envoyer un colis'),
        backgroundColor: const Color(0xFF0B1B3D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type d'envoi
            Row(
              children: [
                _buildTypeEnvoiChip('National', 'national'),
                const SizedBox(width: 12),
                _buildTypeEnvoiChip('International', 'international'),
              ],
            ),
            const SizedBox(height: 20),

            // Expéditeur
            const Text('Expéditeur', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildVilleField('Ville', _expediteurVille, (val) => setState(() => _expediteurVille = val)),
            const SizedBox(height: 8),
            _buildAdresseField('Adresse complète', _expediteurAdresse, (val) => setState(() => _expediteurAdresse = val)),
            const SizedBox(height: 16),

            // Destinataire
            const Text('Destinataire', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildVilleField('Ville', _destinataireVille, (val) => setState(() => _destinataireVille = val)),
            const SizedBox(height: 8),
            _buildAdresseField('Adresse complète', _destinataireAdresse, (val) => setState(() => _destinataireAdresse = val)),
            const SizedBox(height: 16),

            // Type de colis
            const Text('Type de colis', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildTypeColis(),
            const SizedBox(height: 16),

            // Poids
            const Text('Poids estimé', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildPoidsSlider(),
            const SizedBox(height: 16),

            // Mode de livraison
            const Text('Mode de livraison', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildModeLivraison(),
            const SizedBox(height: 24),

            // Bouton calculer
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
                child: const Text('Calculer le prix et continuer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

  Widget _buildTypeEnvoiChip(String label, String value) {
    return Expanded(
      child: FilterChip(
        label: Text(label, style: const TextStyle(fontSize: 14)),
        selected: _typeEnvoi == value,
        onSelected: (_) => setState(() => _typeEnvoi = value),
        selectedColor: const Color(0xFFD4AF37),
        backgroundColor: Colors.white,
        showCheckmark: false,
      ),
    );
  }

  Widget _buildVilleField(String label, String value, Function(String) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_city, size: 20, color: Color(0xFFD4AF37)),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: value,
              decoration: const InputDecoration(border: InputBorder.none),
              items: ['Abidjan, Côte d\'Ivoire', 'Yamoussoukro, Côte d\'Ivoire', 'Bouaké, Côte d\'Ivoire', 'Korhogo, Côte d\'Ivoire']
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
              onChanged: (val) => onChanged(val!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdresseField(String label, String value, Function(String) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: label,
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.location_on, size: 20, color: Colors.grey),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTypeColis() {
    final types = ['Document', 'Colis', 'Fragile', 'Encombrant'];
    return Wrap(
      spacing: 12,
      children: types.map((type) {
        return FilterChip(
          label: Text(type),
          selected: _typeColis == type,
          onSelected: (_) => setState(() => _typeColis = type),
          selectedColor: const Color(0xFFD4AF37),
          backgroundColor: Colors.white,
        );
      }).toList(),
    );
  }

  Widget _buildPoidsSlider() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
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
    return Column(
      children: modes.map((mode) {
        return RadioListTile<String>(
          title: Text(mode['label']!),
          subtitle: Text(mode['prix']!),
          value: mode['label']!,
          groupValue: _modeLivraison,
          onChanged: (val) => setState(() => _modeLivraison = val!),
          activeColor: const Color(0xFFD4AF37),
        );
      }).toList(),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {'icon': Icons.local_shipping, 'label': 'Suivre un colis'},
      {'icon': Icons.inbox, 'label': 'Recevoir un colis'},
      {'icon': Icons.history, 'label': 'Mes envois'},
      {'icon': Icons.store, 'label': 'Points relais'},
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
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4)],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(action['icon'] as IconData, size: 28, color: const Color(0xFFD4AF37)),
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
      {'titre': 'Livraison Express', 'prix': '5.000 FCFA', 'promo': '4.000 FCFA'},
      {'titre': 'Livraison Standard', 'prix': '3.000 FCFA', 'promo': '2.550 FCFA'},
      {'titre': 'International', 'prix': '15.000 FCFA', 'promo': '13.500 FCFA'},
      {'titre': 'Point Relais', 'prix': '2.000 FCFA', 'promo': '1.800 FCFA'},
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(offre['titre']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(offre['prix']!, style: const TextStyle(decoration: TextDecoration.lineThrough, fontSize: 10, color: Colors.grey)),
                    const SizedBox(width: 8),
                    Text(offre['promo']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD4AF37), fontSize: 13)),
                  ],
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
      {'step': '1', 'text': 'Renseignez les détails de votre colis'},
      {'step': '2', 'text': 'Choisissez le mode de livraison'},
      {'step': '3', 'text': 'Payez en toute sécurité'},
      {'step': '4', 'text': 'Nous livrons à destination'},
    ];
    return Row(
      children: steps.map((step) {
        return Expanded(
          child: Column(
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: const BoxDecoration(
                  color: Color(0xFFD4AF37),
                  shape: BoxShape.circle,
                ),
                child: Center(child: Text(step['step']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(height: 8),
              Text(step['text']!, style: const TextStyle(fontSize: 9), textAlign: TextAlign.center),
            ],
          ),
        );
      }).toList(),
    );
  }
}
