// lib/presentation/thix_reservation/pages/vol_liste.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VolListePage extends StatefulWidget {
  const VolListePage({super.key});

  @override
  State<VolListePage> createState() => _VolListePageState();
}

class _VolListePageState extends State<VolListePage> {
  List<Map<String, dynamic>> _vols = [];
  String _sortBy = 'best';
  String _filterEscales = 'all';
  RangeValues _priceRange = const RangeValues(0, 2000);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is List) {
      _vols = List<Map<String, dynamic>>.from(args);
    } else {
      _vols = _getMockVols();
    }
  }

  List<Map<String, dynamic>> _getMockVols() {
    return [
      {'id': '1', 'compagnie': 'Ethiopian Airlines', 'codeVol': 'ET 914', 'depart': 'Kinshasa (FIH)', 'arrivee': 'Paris (CDG)', 'heureDepart': '23:45', 'heureArrivee': '06:10', 'duree': '10h 25min', 'escales': 0, 'prix': 780.0, 'devise': 'USD', 'bagageCabine': '7kg', 'bagageSoute': '23kg', 'repasInclus': true, 'classe': 'Economique'},
      {'id': '2', 'compagnie': 'Turkish Airlines', 'codeVol': 'TK 543', 'depart': 'Kinshasa (FIH)', 'arrivee': 'Paris (CDG)', 'heureDepart': '18:30', 'heureArrivee': '09:15', 'duree': '13h 45min', 'escales': 1, 'prix': 650.0, 'devise': 'USD', 'bagageCabine': '8kg', 'bagageSoute': '23kg', 'repasInclus': true, 'classe': 'Economique'},
      {'id': '3', 'compagnie': 'Air France', 'codeVol': 'AF 771', 'depart': 'Kinshasa (FIH)', 'arrivee': 'Paris (CDG)', 'heureDepart': '10:15', 'heureArrivee': '16:50', 'duree': '8h 35min', 'escales': 0, 'prix': 920.0, 'devise': 'USD', 'bagageCabine': '12kg', 'bagageSoute': '23kg', 'repasInclus': true, 'classe': 'Economique'},
      {'id': '4', 'compagnie': 'Qatar Airways', 'codeVol': 'QR 1490', 'depart': 'Kinshasa (FIH)', 'arrivee': 'Paris (CDG)', 'heureDepart': '01:20', 'heureArrivee': '13:40', 'duree': '14h 20min', 'escales': 1, 'prix': 670.0, 'devise': 'USD', 'bagageCabine': '7kg', 'bagageSoute': '25kg', 'repasInclus': true, 'classe': 'Economique'},
    ];
  }

  List<Map<String, dynamic>> get _filteredVols {
    List<Map<String, dynamic>> filtered = List.from(_vols);
    
    if (_filterEscales == 'direct') {
      filtered = filtered.where((v) => v['escales'] == 0).toList();
    } else if (_filterEscales == '1escale') {
      filtered = filtered.where((v) => v['escales'] == 1).toList();
    }
    
    filtered = filtered.where((v) {
      final prix = v['prix'] is int ? (v['prix'] as int).toDouble() : v['prix'] as double;
      return prix >= _priceRange.start && prix <= _priceRange.end;
    }).toList();

    switch (_sortBy) {
      case 'price_asc':
        filtered.sort((a, b) {
          final prixA = a['prix'] is int ? (a['prix'] as int).toDouble() : a['prix'] as double;
          final prixB = b['prix'] is int ? (b['prix'] as int).toDouble() : b['prix'] as double;
          return prixA.compareTo(prixB);
        });
        break;
      case 'price_desc':
        filtered.sort((a, b) {
          final prixA = a['prix'] is int ? (a['prix'] as int).toDouble() : a['prix'] as double;
          final prixB = b['prix'] is int ? (b['prix'] as int).toDouble() : b['prix'] as double;
          return prixB.compareTo(prixA);
        });
        break;
      case 'duration':
        filtered.sort((a, b) => (a['duree'] as String).compareTo(b['duree'] as String));
        break;
      default:
        break;
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Vols disponibles'),
        backgroundColor: const Color(0xFF0B1B3D),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilters(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSortBar(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredVols.length,
              itemBuilder: (context, index) {
                final vol = _filteredVols[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildFlightCard(vol),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortBar() {
    final sorts = [
      {'label': 'Meilleur choix', 'value': 'best'},
      {'label': 'Prix croissant', 'value': 'price_asc'},
      {'label': 'Prix decroissant', 'value': 'price_desc'},
      {'label': 'Duree', 'value': 'duration'},
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: sorts.map((sort) {
          return FilterChip(
            label: Text(sort['label'] as String, style: const TextStyle(fontSize: 12)),
            selected: _sortBy == sort['value'],
            onSelected: (_) => setState(() => _sortBy = sort['value'] as String),
            selectedColor: const Color(0xFFD4AF37).withOpacity(0.2),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFlightCard(Map<String, dynamic> vol) {
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
    final prix = vol['prix'] is int ? (vol['prix'] as int).toDouble() : vol['prix'] as double;
    final devise = vol['devise'] as String;

    return GestureDetector(
      onTap: () => context.push('/reservation/vols/details', extra: {'vol': vol}),
      child: Container(
        padding: const EdgeInsets.all(16),
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
                Text(compagnie, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: escales == 0 ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    escales == 0 ? 'Direct' : '$escales escale',
                    style: TextStyle(
                      color: escales == 0 ? Colors.green : Colors.orange,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
                Row(
                  children: [
                    _buildDetailBadge(Icons.work_outline, bagageCabine),
                    const SizedBox(width: 12),
                    _buildDetailBadge(Icons.work, bagageSoute),
                    const SizedBox(width: 12),
                    _buildDetailBadge(Icons.restaurant, repasInclus ? 'Repas' : 'Sans repas'),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${prix.round()} $devise',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFD4AF37)),
                    ),
                    const Text('par passager', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailBadge(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFFD4AF37)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Filtres', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text('Escales', style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Tous'),
                      selected: _filterEscales == 'all',
                      onSelected: (_) => setModalState(() => _filterEscales = 'all'),
                    ),
                    FilterChip(
                      label: const Text('Direct'),
                      selected: _filterEscales == 'direct',
                      onSelected: (_) => setModalState(() => _filterEscales = 'direct'),
                    ),
                    FilterChip(
                      label: const Text('1 escale'),
                      selected: _filterEscales == '1escale',
                      onSelected: (_) => setModalState(() => _filterEscales = '1escale'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Prix (USD)', style: TextStyle(fontWeight: FontWeight.bold)),
                RangeSlider(
                  values: _priceRange,
                  min: 0,
                  max: 2000,
                  divisions: 20,
                  labels: RangeLabels('${_priceRange.start.round()} USD', '${_priceRange.end.round()} USD'),
                  onChanged: (values) => setModalState(() => _priceRange = values),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _filterEscales = _filterEscales;
                      _priceRange = _priceRange;
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  child: const Text('Appliquer'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
