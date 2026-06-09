import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrdonnancesPage extends StatefulWidget {
  const OrdonnancesPage({super.key});

  @override
  State<OrdonnancesPage> createState() => _OrdonnancesPageState();
}

class _OrdonnancesPageState extends State<OrdonnancesPage> {
  List<Map<String, dynamic>> _ordonnances = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadOrdonnances();
  }

  Future<void> _loadOrdonnances() async {
    setState(() => _loading = true);
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id ?? '';

      final response = await supabase
          .from('health_ordonnances')
          .select('''
            *,
            doctor:doctor_id (
              id, name, specialty
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      setState(() {
        _ordonnances = (response as List).cast<Map<String, dynamic>>();
      });
    } catch (e) {
      debugPrint('Error loading ordonnances: $e');
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
        title: const Text('Mes ordonnances', style: TextStyle(color: Color(0xFF0B1B3D), fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _ordonnances.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Aucune ordonnance'),
                      Text('Les ordonnances apparaîtront ici'),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _ordonnances.length,
                  itemBuilder: (context, index) => _buildOrdonnanceCard(_ordonnances[index]),
                ),
    );
  }

  Widget _buildOrdonnanceCard(Map<String, dynamic> ordonnance) {
    final doctor = ordonnance['doctor'] as Map<String, dynamic>?;
    final date = DateTime.parse(ordonnance['created_at']);
    final isActive = ordonnance['expires_at'] == null || DateTime.parse(ordonnance['expires_at']).isAfter(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isActive ? Colors.green.shade200 : Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.receipt, color: Colors.purple),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ordonnance du ${date.day}/${date.month}/${date.year}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (doctor != null) Text('Dr. ${doctor['name']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive ? Colors.green.shade50 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(isActive ? 'Active' : 'Expirée', style: TextStyle(fontSize: 11, color: isActive ? Colors.green.shade700 : Colors.grey)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (ordonnance['medicaments'] != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: (ordonnance['medicaments'] as List).map<Widget>((med) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.medication, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            med['name'],
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        Text(med['dosage'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('Voir'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.blue),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isActive ? () {} : null,
                  icon: const Icon(Icons.replay, size: 16),
                  label: const Text('Renouveler'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: const Color(0xFF0B1B3D)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
