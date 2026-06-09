import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RechercheMedicamentPage extends StatefulWidget {
  const RechercheMedicamentPage({super.key});

  @override
  State<RechercheMedicamentPage> createState() => _RechercheMedicamentPageState();
}

class _RechercheMedicamentPageState extends State<RechercheMedicamentPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _medicaments = [];
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadMedicaments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMedicaments() async {
    setState(() => _loading = true);
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.from('health_medicaments').select().order('name');

      setState(() {
        _medicaments = (response as List).cast<Map<String, dynamic>>();
        if (_medicaments.isEmpty) {
          _medicaments = [
            {'id': '1', 'name': 'Paracétamol 500mg', 'type': 'Analgésique', 'price': '500 FCFA', 'pharmacies': 'Pharmacie Centrale'},
            {'id': '2', 'name': 'Ibuprofène 400mg', 'type': 'Anti-inflammatoire', 'price': '1000 FCFA', 'pharmacies': 'Pharmacie Moderne'},
            {'id': '3', 'name': 'Amoxicilline 500mg', 'type': 'Antibiotique', 'price': '2000 FCFA', 'pharmacies': 'Pharmacie Santé Plus'},
          ];
        }
        _results = _medicaments;
      });
    } catch (e) {
      debugPrint('Error loading medicaments: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _search(String query) {
    if (query.isEmpty) {
      setState(() => _results = _medicaments);
      return;
    }
    setState(() {
      _results = _medicaments.where((m) => m['name'].toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Rechercher un médicament', style: TextStyle(color: Color(0xFF0B1B3D), fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                    ? const Center(child: Text('Aucun médicament trouvé'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _results.length,
                        itemBuilder: (context, index) => _buildMedicamentCard(_results[index]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        onChanged: _search,
        decoration: InputDecoration(
          hintText: 'Nom du médicament...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                  _searchController.clear();
                  _search('');
                })
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
        ),
      ),
    );
  }

  Widget _buildMedicamentCard(Map<String, dynamic> medicament) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.medication, color: Colors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(medicament['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(medicament['type'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFD4AF37).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(medicament['price'], style: const TextStyle(fontSize: 12, color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.local_pharmacy, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text('Disponible à : ${medicament['pharmacies']}'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.location_on),
                  label: const Text('Voir en pharmacie'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.blue),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
