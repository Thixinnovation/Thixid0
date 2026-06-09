import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PharmaciesProchesPage extends StatefulWidget {
  const PharmaciesProchesPage({super.key});

  @override
  State<PharmaciesProchesPage> createState() => _PharmaciesProchesPageState();
}

class _PharmaciesProchesPageState extends State<PharmaciesProchesPage> {
  List<Map<String, dynamic>> _pharmacies = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPharmacies();
  }

  Future<void> _loadPharmacies() async {
    setState(() => _loading = true);
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.from('health_facilities').select().eq('type', 'pharmacy').eq('is_active', true);

      setState(() {
        _pharmacies = (response as List).cast<Map<String, dynamic>>();
        if (_pharmacies.isEmpty) {
          _pharmacies = [
            {'id': '1', 'name': 'Pharmacie Centrale', 'address': 'Kinshasa, Gombe', 'distance': '1.2 km', 'phone': '+243 123 456 789', 'is_24h': true},
            {'id': '2', 'name': 'Pharmacie Moderne', 'address': 'Kinshasa, Limete', 'distance': '2.5 km', 'phone': '+243 123 456 790', 'is_24h': false},
            {'id': '3', 'name': 'Pharmacie Santé Plus', 'address': 'Kinshasa, Ngaliema', 'distance': '3.8 km', 'phone': '+243 123 456 791', 'is_24h': true},
          ];
        }
      });
    } catch (e) {
      debugPrint('Error loading pharmacies: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Pharmacies proches', style: TextStyle(color: Color(0xFF0B1B3D), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF0B1B3D)),
            onPressed: () {},
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _pharmacies.length,
              itemBuilder: (context, index) => _buildPharmacieCard(_pharmacies[index]),
            ),
    );
  }

  Widget _buildPharmacieCard(Map<String, dynamic> pharmacie) {
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
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.local_pharmacy, color: Colors.green),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pharmacie['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(pharmacie['address'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20)),
                child: Text(pharmacie['distance'], style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.phone, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(pharmacie['phone']),
              const Spacer(),
              if (pharmacie['is_24h'] == true)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(20)),
                  child: const Text('24h/24', style: TextStyle(fontSize: 10, color: Colors.blue)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.directions),
                  label: const Text('Itinéraire'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.blue),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.medication),
                  label: const Text('Disponibilité'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.green),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
