// lib/presentation/thix_reservation/pages/reservation_vols.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/flight_search_bar.dart';
import '../services/vol_service.dart';
import 'vol_liste.dart';

class ReservationVolsPage extends StatefulWidget {
  const ReservationVolsPage({super.key});

  @override
  State<ReservationVolsPage> createState() => _ReservationVolsPageState();
}

class _ReservationVolsPageState extends State<ReservationVolsPage> {
  final VolService _volService = VolService();
  bool _isLoading = false;
  String _typeVol = 'aller_retour';
  String _origine = 'Kinshasa (FIH)';
  String _destination = 'Paris (CDG)';
  DateTime _depart = DateTime.now().add(const Duration(days: 7));
  DateTime? _retour;
  int _passagers = 1;
  String _classe = 'Économique';

  Future<void> _rechercherVols() async {
    setState(() => _isLoading = true);
    final vols = await _volService.rechercherVols(
      origine: _origine,
      destination: _destination,
      depart: _depart,
      retour: _typeVol == 'aller_retour' ? _retour : null,
      passagers: _passagers,
      classe: _classe,
    );
    setState(() => _isLoading = false);
    if (context.mounted) {
      context.push('/reservation/vols/liste', extra: vols);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Réserver un vol'),
        backgroundColor: const Color(0xFF0B1B3D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type de vol
            Row(
              children: [
                _buildTypeVolChip('Aller-retour', 'aller_retour'),
                const SizedBox(width: 8),
                _buildTypeVolChip('Aller simple', 'aller_simple'),
                const SizedBox(width: 8),
                _buildTypeVolChip('Multi-destinations', 'multi_destinations'),
              ],
            ),
            const SizedBox(height: 20),

            // Formulaire de recherche
            FlightSearchBar(
              origine: _origine,
              destination: _destination,
              depart: _depart,
              retour: _retour,
              passagers: _passagers,
              classe: _classe,
              onOrigineChanged: (val) => setState(() => _origine = val),
              onDestinationChanged: (val) => setState(() => _destination = val),
              onDepartChanged: (date) => setState(() => _depart = date),
              onRetourChanged: (date) => setState(() => _retour = date),
              onPassagersChanged: (val) => setState(() => _passagers = val),
              onClasseChanged: (val) => setState(() => _classe = val),
            ),
            const SizedBox(height: 24),

            // Bouton rechercher
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _rechercherVols,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: const Color(0xFF0B1B3D),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Rechercher un vol', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 24),

            // THIX VOL PREMIUM
            _buildPremiumBanner(),

            const SizedBox(height: 20),

            // Offres spéciales
            const Text('Offres spéciales', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildOffresSpeciale(),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeVolChip(String label, String value) {
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: _typeVol == value,
      onSelected: (_) => setState(() => _typeVol = value),
      selectedColor: const Color(0xFFD4AF37),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildPremiumBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B1B3D), Color(0xFFD4AF37)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.stars, color: Color(0xFFD4AF37), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('THIX VOL PREMIUM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                Text('Plus de confort, plus d\'avantages !', style: TextStyle(color: Colors.white70, fontSize: 10)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0B1B3D),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Découvrir', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildOffresSpeciale() {
    final offres = [
      {'depart': 'Kinshasa', 'arrivee': 'Douala', 'prix': '230 USD'},
      {'depart': 'Kinshasa', 'arrivee': 'Paris', 'prix': '650 USD'},
      {'depart': 'Kinshasa', 'arrivee': 'Dubai', 'prix': '580 USD'},
      {'depart': 'Kinshasa', 'arrivee': 'Casablanca', 'prix': '420 USD'},
    ];
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: offres.length,
        itemBuilder: (context, index) {
          final offre = offres[index];
          return Container(
            width: 150,
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
                Text('${offre['depart']} → ${offre['arrivee']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                const Text('À partir de', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                Text(offre['prix']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD4AF37), fontSize: 14)),
              ],
            ),
          );
        },
      ),
    );
  }
}
