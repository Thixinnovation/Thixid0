// lib/presentation/thix_reservation/pages/vol_liste.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/vol.dart';
import '../widgets/flight_card.dart';

class VolListePage extends StatefulWidget {
  const VolListePage({super.key});

  @override
  State<VolListePage> createState() => _VolListePageState();
}

class _VolListePageState extends State<VolListePage> {
  List<Vol> _vols = [];
  String _sortBy = 'best';
  String _filterEscales = 'all';
  RangeValues _priceRange = const RangeValues(0, 2000);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _vols = (ModalRoute.of(context)?.settings.arguments as List<Vol>?) ?? [];
  }

  List<Vol> get _filteredVols {
    var filtered = List.from(_vols);
    if (_filterEscales == 'direct') {
      filtered = filtered.where((v) => v.escales == 0).toList();
    } else if (_filterEscales == '1escale') {
      filtered = filtered.where((v) => v.escales == 1).toList();
    }
    filtered = filtered.where((v) => v.prix >= _priceRange.start && v.prix <= _priceRange.end).toList();

    switch (_sortBy) {
      case 'price_asc': filtered.sort((a, b) => a.prix.compareTo(b.prix)); break;
      case 'price_desc': filtered.sort((a, b) => b.prix.compareTo(a.prix)); break;
      case 'duration': filtered.sort((a, b) => a.duree.compareTo(b.duree)); break;
      default: break;
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
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () => _showFilters()),
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
                  child: FlightCard(
                    vol: vol,
                    onTap: () => context.push('/reservation/vols/details', extra: vol),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSortChip('Meilleur choix', 'best'),
          _buildSortChip('Prix croissant', 'price_asc'),
          _buildSortChip('Prix décroissant', 'price_desc'),
          _buildSortChip('Durée', 'duration'),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, String value) {
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: _sortBy == value,
      onSelected: (_) => setState(() => _sortBy = value),
      selectedColor: const Color(0xFFD4AF37).withOpacity(0.2),
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
                    FilterChip(label: const Text('Tous'), selected: _filterEscales == 'all', onSelected: (_) => setModalState(() => _filterEscales = 'all')),
                    FilterChip(label: const Text('Direct'), selected: _filterEscales == 'direct', onSelected: (_) => setModalState(() => _filterEscales = 'direct')),
                    FilterChip(label: const Text('1 escale'), selected: _filterEscales == '1escale', onSelected: (_) => setModalState(() => _filterEscales = '1escale')),
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
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
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
