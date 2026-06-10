// lib/presentation/thix_reservation/pages/vol_details.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VolDetailsPage extends StatelessWidget {
  const VolDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args == null) {
      return const Scaffold(
        body: Center(child: Text('Aucune donnee de vol')),
      );
    }

    final vol = args['vol'] as Map<String, dynamic>;
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
    final prix = vol['prix'] as double;
    final devise = vol['devise'] as String;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Details du vol'),
        backgroundColor: const Color(0xFF0B1B3D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFlightInfo(
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
            ),
            const SizedBox(height: 20),
            const Text('Choisissez votre tarif', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildTarifCard('Economique', prix, [
              '1 bagage cabine $bagageCabine',
              '1 bagage soute $bagageSoute',
              'Repas inclus',
              'Modifications non autorisees',
            ], true, context, vol),
            const SizedBox(height: 12),
            _buildTarifCard('Economique Flex', prix * 1.3, [
              '1 bagage cabine $bagageCabine',
              '1 bagage soute $bagageSoute',
              'Repas inclus',
              'Modifications autorisees (avec frais)',
            ], false, context, vol),
            const SizedBox(height: 12),
            _buildTarifCard('Business', prix * 2.5, [
              '2 bagages cabine 7kg chacun',
              '2 bagages soute 23kg chacun',
              'Repas premium',
              'Modifications autorisees',
              'Acces salon',
            ], false, context, vol),
          ],
        ),
      ),
    );
  }

  Widget _buildFlightInfo({
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
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(compagnie, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(codeVol, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(heureDepart, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                    Text(heureArrivee, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
              _buildDetailBadge(Icons.work_outline, bagageCabine, 'Cabine'),
              _buildDetailBadge(Icons.work, bagageSoute, 'Soute'),
              _buildDetailBadge(Icons.restaurant, repasInclus ? 'Inclus' : 'Non inclus', 'Repas'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailBadge(IconData icon, String text, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: const Color(0xFFD4AF37)),
        const SizedBox(height: 4),
        Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildTarifCard(String title, double price, List<String> features, bool isRecommended, BuildContext context, Map<String, dynamic> vol) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRecommended ? const Color(0xFFD4AF37).withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isRecommended ? Border.all(color: const Color(0xFFD4AF37)) : null,
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  if (isRecommended) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFD4AF37), borderRadius: BorderRadius.circular(12)),
                      child: const Text('Recommande', style: TextStyle(color: Colors.white, fontSize: 10)),
                    ),
                  ],
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${price.round()} USD', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFFD4AF37))),
                  const Text('par passager', style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                const Icon(Icons.check_circle, size: 14, color: Colors.green),
                const SizedBox(width: 8),
                Text(f, style: const TextStyle(fontSize: 12)),
              ],
            ),
          )),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push('/reservation/vols/passagers', extra: {'vol': vol, 'tarif': title, 'prix': price}),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: const Color(0xFF0B1B3D),
              ),
              child: Text('Selectionner - ${price.round()} USD'),
            ),
          ),
        ],
      ),
    );
  }
}
