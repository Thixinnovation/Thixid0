// lib/presentation/thix_reservation/pages/vol_recherche.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VolRecherchePage extends StatefulWidget {
  const VolRecherchePage({super.key});

  @override
  State<VolRecherchePage> createState() => _VolRecherchePageState();
}

class _VolRecherchePageState extends State<VolRecherchePage> {
  bool _isLoading = false;
  String _typeVol = 'aller_retour';
  String _origine = 'Kinshasa (FIH)';
  String _destination = 'Paris (CDG)';
  DateTime _depart = DateTime.now().add(const Duration(days: 7));
  DateTime? _retour;
  int _passagers = 1;
  String _classe = 'Economique';

  Future<void> _rechercherVols() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    
    final vols = [
      {'id': '1', 'compagnie': 'Ethiopian Airlines', 'codeVol': 'ET 914', 'depart': 'Kinshasa (FIH)', 'arrivee': 'Paris (CDG)', 'heureDepart': '23:45', 'heureArrivee': '06:10', 'duree': '10h 25min', 'escales': 0, 'prix': 780.0, 'devise': 'USD', 'bagageCabine': '7kg', 'bagageSoute': '23kg', 'repasInclus': true, 'classe': 'Economique'},
      {'id': '2', 'compagnie': 'Turkish Airlines', 'codeVol': 'TK 543', 'depart': 'Kinshasa (FIH)', 'arrivee': 'Paris (CDG)', 'heureDepart': '18:30', 'heureArrivee': '09:15', 'duree': '13h 45min', 'escales': 1, 'prix': 650.0, 'devise': 'USD', 'bagageCabine': '8kg', 'bagageSoute': '23kg', 'repasInclus': true, 'classe': 'Economique'},
      {'id': '3', 'compagnie': 'Air France', 'codeVol': 'AF 771', 'depart': 'Kinshasa (FIH)', 'arrivee': 'Paris (CDG)', 'heureDepart': '10:15', 'heureArrivee': '16:50', 'duree': '8h 35min', 'escales': 0, 'prix': 920.0, 'devise': 'USD', 'bagageCabine': '12kg', 'bagageSoute': '23kg', 'repasInclus': true, 'classe': 'Economique'},
    ];
    
    setState(() => _isLoading = false);
    if (mounted) {
      context.push('/reservation/vols/liste', extra: vols);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Reserver un vol'),
        backgroundColor: const Color(0xFF0B1B3D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTypeVol(),
            const SizedBox(height: 20),
            _buildAeroportField('De', _origine, (val) => setState(() => _origine = val),
                ['Kinshasa (FIH)', 'Abidjan (ABJ)', 'Dakar (DSS)', 'Douala (DLA)']),
            const SizedBox(height: 16),
            _buildAeroportField('A', _destination, (val) => setState(() => _destination = val),
                ['Paris (CDG)', 'Paris (ORY)', 'Bruxelles (BRU)', 'Geneve (GVA)']),
            const SizedBox(height: 16),
            _buildDateRow(),
            const SizedBox(height: 16),
            _buildPassagersClasse(),
            const SizedBox(height: 24),
            _buildSearchButton(),
            const SizedBox(height: 24),
            _buildOffresSpeciales(),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeVol() {
    return Row(
      children: [
        _buildTypeChip('Aller-retour', 'aller_retour'),
        const SizedBox(width: 8),
        _buildTypeChip('Aller simple', 'aller_simple'),
        const SizedBox(width: 8),
        _buildTypeChip('Multi-destinations', 'multi_destinations'),
      ],
    );
  }

  Widget _buildTypeChip(String label, String value) {
    return Expanded(
      child: FilterChip(
        label: Text(label),
        selected: _typeVol == value,
        onSelected: (_) => setState(() => _typeVol = value),
        selectedColor: const Color(0xFFD4AF37),
      ),
    );
  }

  Widget _buildAeroportField(String label, String value, Function(String) onChanged, List<String> options) {
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
          DropdownButtonFormField<String>(
            value: value,
            decoration: const InputDecoration(border: InputBorder.none),
            items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
            onChanged: (val) => onChanged(val!),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow() {
    return Row(
      children: [
        Expanded(child: _buildDateField('Depart', _depart, (date) => setState(() => _depart = date))),
        const SizedBox(width: 12),
        if (_typeVol == 'aller_retour')
          Expanded(child: _buildDateField('Retour', _retour ?? _depart.add(const Duration(days: 7)), (date) => setState(() => _retour = date))),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime date, Function(DateTime) onSelected) {
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
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: date,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) onSelected(picked);
            },
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Color(0xFFD4AF37)),
                const SizedBox(width: 8),
                Text('${date.day}/${date.month}/${date.year}', style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassagersClasse() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Passagers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 18),
                      onPressed: _passagers > 1 ? () => setState(() => _passagers--) : null,
                    ),
                    Text('$_passagers', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    IconButton(
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: _passagers < 9 ? () => setState(() => _passagers++) : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _classe,
                  items: ['Economique', 'Economique Flex', 'Business']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => setState(() => _classe = val!),
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchButton() {
    return SizedBox(
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
    );
  }

  Widget _buildOffresSpeciales() {
    final offres = [
      {'depart': 'Kinshasa', 'arrivee': 'Douala', 'prix': '230 USD'},
      {'depart': 'Kinshasa', 'arrivee': 'Paris', 'prix': '650 USD'},
      {'depart': 'Kinshasa', 'arrivee': 'Dubai', 'prix': '580 USD'},
      {'depart': 'Kinshasa', 'arrivee': 'Casablanca', 'prix': '420 USD'},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Offres speciales', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
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
                    const Text('A partir de', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text(offre['prix']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD4AF37), fontSize: 14)),
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
