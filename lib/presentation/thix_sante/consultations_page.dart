import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ConsultationsPage extends StatefulWidget {
  const ConsultationsPage({super.key});

  @override
  State<ConsultationsPage> createState() => _ConsultationsPageState();
}

class _ConsultationsPageState extends State<ConsultationsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _consultations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadConsultations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadConsultations() async {
    setState(() => _loading = true);
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id ?? '';

      final response = await supabase
          .from('health_consultations')
          .select('''
            *,
            doctors:doctor_id (
              id, name, specialty, avatar_url
            )
          ''')
          .eq('user_id', userId)
          .order('appointment_date', ascending: false);

      setState(() {
        _consultations = (response as List).cast<Map<String, dynamic>>();
      });
    } catch (e) {
      debugPrint('Error loading consultations: $e');
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
        title: const Text('Mes consultations', style: TextStyle(color: Color(0xFF0B1B3D), fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFD4AF37),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFD4AF37),
          tabs: const [
            Tab(text: 'À venir'),
            Tab(text: 'Passées'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildConsultationsList(isPast: false),
                _buildConsultationsList(isPast: true),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFFD4AF37),
        child: const Icon(Icons.add, color: Color(0xFF0B1B3D)),
      ),
    );
  }

  Widget _buildConsultationsList({required bool isPast}) {
    final filtered = _consultations.where((c) {
      final date = DateTime.parse(c['appointment_date']);
      return isPast ? date.isBefore(DateTime.now()) : date.isAfter(DateTime.now());
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isPast ? Icons.history : Icons.calendar_today, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(isPast ? 'Aucune consultation passée' : 'Aucune consultation à venir'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final consultation = filtered[index];
        final doctor = consultation['doctors'] as Map<String, dynamic>?;
        return _buildConsultationCard(consultation, doctor);
      },
    );
  }

  Widget _buildConsultationCard(Map<String, dynamic> consultation, Map<String, dynamic>? doctor) {
    final date = DateTime.parse(consultation['appointment_date']);
    final isVirtual = consultation['is_virtual'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: doctor?['avatar_url'] != null ? NetworkImage(doctor!['avatar_url']) : null,
                child: doctor?['avatar_url'] == null ? const Icon(Icons.person, color: Colors.grey) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doctor?['name'] ?? 'Médecin', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(doctor?['specialty'] ?? 'Généraliste', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isVirtual ? Colors.blue.shade50 : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isVirtual ? 'Visio' : 'Présentiel',
                  style: TextStyle(fontSize: 11, color: isVirtual ? Colors.blue.shade700 : Colors.green.shade700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
              const SizedBox(width: 8),
              Text('${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}'),
              const SizedBox(width: 16),
              const Icon(Icons.location_on, size: 14, color: Colors.grey),
              const SizedBox(width: 8),
              Text(consultation['location'] ?? 'En ligne'),
            ],
          ),
          const SizedBox(height: 12),
          if (consultation['status'] == 'confirmed')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20)),
              child: Text('Confirmé', style: TextStyle(fontSize: 11, color: Colors.green.shade700)),
            ),
          if (consultation['status'] == 'cancelled')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(20)),
              child: Text('Annulé', style: TextStyle(fontSize: 11, color: Colors.red.shade700)),
            ),
        ],
      ),
    );
  }
}
