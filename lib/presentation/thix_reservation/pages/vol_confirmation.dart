// lib/presentation/thix_reservation/pages/vol_confirmation.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VolConfirmationPage extends StatelessWidget {
  const VolConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    
    if (data == null) {
      return const Scaffold(
        body: Center(child: Text('Aucune donnee de confirmation')),
      );
    }

    final vol = data['vol'] as Map<String, dynamic>;
    final tarif = data['tarif'] as String;
    final prix = data['prix'] as double;
    final total = (prix + 120).round();
    final codeReservation = 'THIX${DateTime.now().millisecondsSinceEpoch.toString().substring(8, 12)}'.toUpperCase();

    final compagnie = vol['compagnie'] as String;
    final codeVol = vol['codeVol'] as String;
    final depart = vol['depart'] as String;
    final arrivee = vol['arrivee'] as String;
    final heureDepart = vol['heureDepart'] as String;
    final heureArrivee = vol['heureArrivee'] as String;
    final duree = vol['duree'] as String;
    final escales = vol['escales'] as int;
    final bagageCabine = vol['bagageCabine'] as String;
    final bagageSoute = vol['bagageSoute'] as String;
    final repasInclus = vol['repasInclus'] as bool;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Reservation confirmee'),
        backgroundColor: const Color(0xFF0B1B3D),
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSuccessHeader(),
            const SizedBox(height: 20),
            _buildInfoRow('Code de reservation', codeReservation),
            _buildInfoRow('Date de reservation', '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} a ${DateTime.now().hour}:${DateTime.now().minute}'),
            const SizedBox(height: 20),
            _buildFlightDetails(
              compagnie: compagnie,
              codeVol: codeVol,
              depart: depart,
              arrivee: arrivee,
              heureDepart: heureDepart,
              heureArrivee: heureArrivee,
              duree: duree,
              escales: escales,
              bagageCabine: bagageCabine,
              bagageSoute: bagageSoute,
              repasInclus: repasInclus,
              tarif: tarif,
            ),
            const SizedBox(height: 20),
            _buildPassengerInfo(),
            const SizedBox(height: 20),
            _buildPaymentInfo(total),
            const SizedBox(height: 20),
            _buildActions(codeReservation, context),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle, size: 60, color: Colors.green),
          const SizedBox(height: 12),
          const Text('Reservation confirmee !', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
          const SizedBox(height: 8),
          const Text('Votre vol a ete reserve avec succes. Un email de confirmation a ete envoye.',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFlightDetails({
    required String compagnie,
    required String codeVol,
    required String depart,
    required String arrivee,
    required String heureDepart,
    required String heureArrivee,
    required String duree,
    required int escales,
    required String bagageCabine,
    required String bagageSoute,
    required bool repasInclus,
    required String tarif,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Details de votre vol', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(compagnie, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(codeVol, style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(heureDepart, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(depart, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(duree, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const Icon(Icons.flight, size: 20, color: Color(0xFFD4AF37)),
                    if (escales > 0) Text('$escales escale', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(heureArrivee, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(arrivee, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailChip('Bagage cabine', bagageCabine),
              _buildDetailChip('Bagage soute', bagageSoute),
              _buildDetailChip('Repas', repasInclus ? 'Inclus' : 'Non inclus'),
              _buildDetailChip('Classe', tarif),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildPassengerInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Passager', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Jean KABASELE (Adulte)', style: TextStyle(fontWeight: FontWeight.w500)),
          const Text('Passeport: A1234567 • Nationalite: Congolaise', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo(int total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Paiement', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tarif de base', style: TextStyle(color: Colors.grey)),
              Text('${total - 120} USD'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Taxes et frais', style: TextStyle(color: Colors.grey)),
              const Text('120 USD'),
            ],
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total paye', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('$total USD', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions(String codeReservation, BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Voir mon billet'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: const Color(0xFF0B1B3D),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.calendar_today, size: 18),
                label: const Text('Ajouter au calendrier'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.share, size: 18),
                label: const Text('Partager'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => context.go('/reservation'),
            child: const Text('Retour a l\'accueil'),
          ),
        ),
      ],
    );
  }
}
