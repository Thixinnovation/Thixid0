import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SuiviGrossessePage extends StatefulWidget {
  const SuiviGrossessePage({super.key});

  @override
  State<SuiviGrossessePage> createState() => _SuiviGrossessePageState();
}

class _SuiviGrossessePageState extends State<SuiviGrossessePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _pregnancy;
  List<Map<String, dynamic>> _appointments = [];
  List<Map<String, dynamic>> _symptoms = [];
  bool _loading = true;
  int _currentWeek = 12;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
  setState(() => _loading = true);
  try {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id ?? '';

    final pregnancy = await supabase.from('health_pregnancies').select().eq('user_id', userId).maybeSingle();

    setState(() {
      _pregnancy = pregnancy as Map<String, dynamic>?;
      _appointments = [];
      _symptoms = [];
      
      // ✅ CORRECTION: Vérification de null avant d'utiliser DateTime.parse
      if (_pregnancy != null && _pregnancy!['start_date'] != null) {
        final startDateStr = _pregnancy!['start_date'] as String;
        _currentWeek = DateTime.now().difference(DateTime.parse(startDateStr)).inDays ~/ 7;
      } else {
        _currentWeek = 12;
      }
    });
  } catch (e) {
    debugPrint('Error loading pregnancy data: $e');
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
        title: const Text('Suivi grossesse', style: TextStyle(color: Color(0xFF0B1B3D), fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFD4AF37),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFD4AF37),
          tabs: const [
            Tab(text: 'Semaine'),
            Tab(text: 'RDV'),
            Tab(text: 'Symptômes'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _pregnancy == null
              ? _buildStartPregnancy()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildWeekTab(),
                    _buildAppointmentsTab(),
                    _buildSymptomsTab(),
                  ],
                ),
    );
  }

  Widget _buildStartPregnancy() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.pregnant_woman, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Aucun suivi de grossesse'),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => _showStartPregnancyDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Commencer le suivi'),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFD4AF37), Color(0xFFE5B13A)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text('Semaine actuelle', style: TextStyle(color: Color(0xFF0B1B3D), fontSize: 14)),
                Text('$_currentWeek', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF0B1B3D))),
                const Text('semaines de grossesse', style: TextStyle(color: Color(0xFF0B1B3D), fontSize: 14)),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: _currentWeek / 40,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF0B1B3D)),
                ),
                const SizedBox(height: 8),
                Text('${(40 - _currentWeek)} semaines restantes', style: const TextStyle(color: Color(0xFF0B1B3D), fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard('Taille du bébé', '${_currentWeek * 1.5} cm', Icons.height),
          _buildInfoCard('Poids estimé', '${_currentWeek * 50} g', Icons.monitor_weight),
          _buildInfoCard('Développement', 'Le bébé commence à bouger régulièrement', Icons.psychology),
          const SizedBox(height: 16),
          _buildTipCard(),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: Colors.pink.shade50, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.pink),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Conseil de la semaine', style: TextStyle(fontWeight: FontWeight.bold)),
                const Text('Pensez à boire beaucoup d\'eau et à vous reposer suffisamment.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsTab() {
    if (_appointments.isEmpty) {
      return const Center(child: Text('Aucun rendez-vous programmé'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _appointments.length,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.calendar_today, color: Colors.purple),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_appointments[index]['title'] ?? 'Rendez-vous', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(_appointments[index]['date'] ?? 'Date non définie'),
              Text(_appointments[index]['doctor'] ?? 'Médecin', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ])),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomsTab() {
    if (_symptoms.isEmpty) {
      return const Center(child: Text('Aucun symptôme enregistré'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _symptoms.length,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.sick, color: Colors.orange),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(_symptoms[index]['name'] ?? 'Symptôme')),
            Text(_symptoms[index]['date'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  void _showStartPregnancyDialog() {
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
              const Text('Début du suivi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Date des dernières règles', border: OutlineInputBorder()),
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
                    const SnackBar(content: Text('Suivi de grossesse démarré !'), backgroundColor: Colors.green),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: const Color(0xFF0B1B3D),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('COMMENCER'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
