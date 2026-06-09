import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HopitauxProchesPage extends StatefulWidget {
  const HopitauxProchesPage({super.key});

  @override
  State<HopitauxProchesPage> createState() => _HopitauxProchesPageState();
}

class _HopitauxProchesPageState extends State<HopitauxProchesPage> {
  List<Map<String, dynamic>> _hopitaux = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHopitaux();
  }

  Future<void> _loadHopitaux() async {
    setState(() => _loading = true);
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.from('health_facilities').select().eq('type', 'hospital').eq('is_active', true);

      setState(() {
        _hopitaux = (response as List).cast<Map<String, dynamic>>();
        if (_hopitaux.isEmpty) {
          _hopitaux = [
            {'id': '1', 'name': 'Clinique Ngaliema', 'address': 'Kinshasa, Gombe', 'distance': '2.3 km', 'phone': '+243 123 456 789', 'rating': 4.8, 'emergency': true},
            {'id': '2', 'name': 'Hôpital du Cinquantenaire', 'address': 'Kinshasa, Limete', 'distance': '5.1 km', 'phone': '+243 123 456 790', 'rating': 4.6, 'emergency': true},
            {'id': '3', 'name': 'Clinique Kinoise', 'address': 'Kinshasa, Ngaliema', 'distance': '3.5 km', 'phone': '+243 123 456 791', 'rating': 4.5, 'emergency': false},
          ];
        }
      });
    } catch (e) {
      debugPrint('Error loading hopitaux: $e');
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
        title: const Text('Hôpitaux proches', style: TextStyle(color: Color(0xFF0B1B3D), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.map, color: Color(0xFF0B1B3D)),
            onPressed: () {},
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _hopitaux.length,
              itemBuilder: (context, index) => _buildHopitalCard(_hopitaux[index]),
            ),
    );
  }

  Widget _buildHopitalCard(Map<String, dynamic> hopital) {
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
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.local_hospital, color: Colors.red),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hopital['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(hopital['address'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20)),
                child: Text(hopital['distance'], style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.star, size: 14, color: Color(0xFFD4AF37)),
              const SizedBox(width: 4),
              Text(hopital['rating'].toString()),
              const SizedBox(width: 16),
              const Icon(Icons.phone, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(hopital['phone']),
              const Spacer(),
              if (hopital['emergency'] == true)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(20)),
                  child: const Text('Urgences 24/7', style: TextStyle(fontSize: 10, color: Colors.red)),
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
                  icon: const Icon(Icons.phone),
                  label: const Text('Appeler'),
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
