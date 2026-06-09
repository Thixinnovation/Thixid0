import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CarnetVaccinationPage extends StatefulWidget {
  const CarnetVaccinationPage({super.key});

  @override
  State<CarnetVaccinationPage> createState() => _CarnetVaccinationPageState();
}

class _CarnetVaccinationPageState extends State<CarnetVaccinationPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _vaccins = [];
  List<Map<String, dynamic>> _recommendations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadVaccins();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadVaccins() async {
    setState(() => _loading = true);
    try {
      final supabase = Supabase.instance.client;
      // ✅ CORRECTION: Ajout de ?? '' pour éviter null
      final userId = supabase.auth.currentUser?.id ?? '';

      final response = await supabase
          .from('health_vaccins')
          .select()
          .eq('user_id', userId)
          .order('date_administered', ascending: false);

      setState(() {
        _vaccins = (response as List).cast<Map<String, dynamic>>();
        _recommendations = [
          {'name': 'DT Polio', 'due_date': DateTime.now().add(const Duration(days: 30))},
          {'name': 'Hépatite B', 'due_date': DateTime.now().add(const Duration(days: 60))},
          {'name': 'ROR', 'due_date': DateTime.now().add(const Duration(days: 90))},
        ];
      });
    } catch (e) {
      debugPrint('Error loading vaccins: $e');
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
        title: const Text('Carnet de vaccination', style: TextStyle(color: Color(0xFF0B1B3D), fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFD4AF37),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFD4AF37),
          tabs: const [
            Tab(text: 'Vaccins reçus'),
            Tab(text: 'À venir'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildVaccinsList(),
                _buildRecommendationsList(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddVaccinDialog(),
        backgroundColor: const Color(0xFFD4AF37),
        child: const Icon(Icons.add, color: Color(0xFF0B1B3D)),
      ),
    );
  }

  Widget _buildVaccinsList() {
    if (_vaccins.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.vaccines, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Aucun vaccin enregistré'),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _vaccins.length,
      itemBuilder: (context, index) => _buildVaccinCard(_vaccins[index]),
    );
  }

  Widget _buildVaccinCard(Map<String, dynamic> vaccin) {
    // ✅ CORRECTION: Vérifications de sécurité
    final dateStr = vaccin['date_administered'] as String?;
    final date = dateStr != null ? DateTime.tryParse(dateStr) : null;
    final name = vaccin['name']?.toString() ?? 'Vaccin';
    final location = vaccin['location']?.toString();
    final nextDueDate = vaccin['next_due_date']?.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.vaccines, color: Colors.green),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(date != null ? 'Administré le ${date.day}/${date.month}/${date.year}' : 'Date non spécifiée'),
                if (location != null && location.isNotEmpty) 
                  Text(location, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          if (nextDueDate != null && nextDueDate.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(20)),
              child: Text('Prochain: $nextDueDate', style: const TextStyle(fontSize: 10, color: Colors.orange)),
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsList() {
    if (_recommendations.isEmpty) {
      return const Center(child: Text('Aucun rappel à venir'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _recommendations.length,
      itemBuilder: (context, index) {
        final rec = _recommendations[index];
        final dueDate = rec['due_date'] as DateTime;
        final daysLeft = dueDate.difference(DateTime.now()).inDays;
        final name = rec['name']?.toString() ?? 'Vaccin';
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: daysLeft <= 30 ? Colors.orange.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: daysLeft <= 30 ? Colors.orange.shade200 : Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.notifications_active, color: Colors.blue),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('À faire avant le ${dueDate.day}/${dueDate.month}/${dueDate.year}'),
                    Text('${daysLeft} jours restants', style: TextStyle(fontSize: 12, color: daysLeft <= 30 ? Colors.orange : Colors.grey)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Planifier'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddVaccinDialog() {
    final nameController = TextEditingController();
    final dateController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Ajouter un vaccin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nom du vaccin', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Date d\'administration', border: OutlineInputBorder()),
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    dateController.text = '${date.day}/${date.month}/${date.year}';
                  }
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vaccin ajouté !'), backgroundColor: Colors.green),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: const Color(0xFF0B1B3D),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('AJOUTER'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
