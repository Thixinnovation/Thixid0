import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AssuranceSantePage extends StatefulWidget {
  const AssuranceSantePage({super.key});

  @override
  State<AssuranceSantePage> createState() => _AssuranceSantePageState();
}

class _AssuranceSantePageState extends State<AssuranceSantePage> {
  Map<String, dynamic>? _insurance;
  List<Map<String, dynamic>> _plans = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final supabase = Supabase.instance.client;
      // ✅ CORRECTION: Supprimer la ligne en double et ajouter ?? ''
      final userId = supabase.auth.currentUser?.id ?? '';
      final insurance = await supabase.from('health_insurance').select().eq('user_id', userId).maybeSingle();

      setState(() {
        _insurance = insurance as Map<String, dynamic>?;
        _plans = [
          {'name': 'Essentiel', 'price': '15.000 FCFA', 'coverage': 'Consultations, Médicaments', 'popular': false},
          {'name': 'Confort', 'price': '25.000 FCFA', 'coverage': 'Consultations, Médicaments, Examens', 'popular': true},
          {'name': 'Premium', 'price': '45.000 FCFA', 'coverage': 'Consultations, Médicaments, Examens, Hospitalisation', 'popular': false},
        ];
      });
    } catch (e) {
      debugPrint('Error loading insurance: $e');
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
        title: const Text('Assurance santé', style: TextStyle(color: Color(0xFF0B1B3D), fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (_insurance != null) _buildCurrentInsurance(),
                  const SizedBox(height: 24),
                  const Text('Nos offres', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ..._plans.map((plan) => _buildPlanCard(plan)),
                  const SizedBox(height: 16),
                  _buildFAQ(),
                ],
              ),
            ),
    );
  }

  Widget _buildCurrentInsurance() {
    // ✅ CORRECTION: Vérifications de sécurité avec valeurs par défaut
    final planName = _insurance?['plan_name']?.toString() ?? 'Assurance';
    final expiryDate = _insurance?['expiry_date']?.toString() ?? 'Non définie';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0B1B3D), Color(0xFF1A2D56)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield, color: Color(0xFFD4AF37)),
              SizedBox(width: 8),
              Text('Votre assurance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(planName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Valable jusqu\'au $expiryDate', style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: const Color(0xFF0B1B3D)),
            child: const Text('Voir détails'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan) {
    // ✅ CORRECTION: Extraire les valeurs avec sécurité
    final name = plan['name']?.toString() ?? 'Offre';
    final price = plan['price']?.toString() ?? '0 FCFA';
    final coverage = plan['coverage']?.toString() ?? '';
    final isPopular = plan['popular'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPopular ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isPopular ? Colors.blue.shade200 : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              if (isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(20)),
                  child: const Text('Populaire', style: TextStyle(fontSize: 10, color: Colors.white)),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(price, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
          const SizedBox(height: 8),
          Text(coverage),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: isPopular ? const Color(0xFFD4AF37) : Colors.white,
                foregroundColor: const Color(0xFF0B1B3D),
                side: BorderSide(color: isPopular ? Colors.transparent : const Color(0xFFD4AF37)),
              ),
              child: const Text('Souscrire'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQ() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Questions fréquentes', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ExpansionTile(
            title: const Text('Comment souscrire ?'),
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Vous pouvez souscrire en ligne en quelques minutes.'),
              ),
            ],
          ),
          ExpansionTile(
            title: const Text('Quels sont les délais ?'),
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('La couverture commence 48h après souscription.'),
              ),
            ],
          ),
          ExpansionTile(
            title: const Text('Comment résilier ?'),
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Résiliation possible à tout moment.'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
