import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResultatExamenPage extends StatefulWidget {
  final String? examenId;
  const ResultatExamenPage({super.key, this.examenId});

  @override
  State<ResultatExamenPage> createState() => _ResultatExamenPageState();
}

class _ResultatExamenPageState extends State<ResultatExamenPage> {
  Map<String, dynamic>? _examen;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadExamen();
  }

  Future<void> _loadExamen() async {
    setState(() => _loading = true);
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id ?? '';

      // ✅ CORRECTION: Déclarer query avec le bon type et réorganiser
      PostgrestFilterBuilder<PostgrestList> query = supabase
          .from('health_examens')
          .select()
          .eq('user_id', userId)
          .order('exam_date', ascending: false)
          .limit(1) as PostgrestFilterBuilder<PostgrestList>;

      if (widget.examenId != null && widget.examenId!.isNotEmpty) {
        query = query.eq('id', widget.examenId!);
      }

      final response = await query.maybeSingle();

      setState(() {
        _examen = response as Map<String, dynamic>?;
      });
    } catch (e) {
      debugPrint('Error loading examen: $e');
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
        title: const Text('Résultat d\'examen', style: TextStyle(color: Color(0xFF0B1B3D), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined, color: Color(0xFF0B1B3D)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Color(0xFF0B1B3D)),
            onPressed: () {},
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _examen == null
              ? const Center(child: Text('Aucun résultat disponible'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInfoCard(),
                      const SizedBox(height: 16),
                      _buildResultsTable(),
                      const SizedBox(height: 16),
                      _buildDoctorComment(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoCard() {
    final title = _examen?['title']?.toString() ?? 'Examen médical';
    final laboratory = _examen?['laboratory']?.toString();
    final doctorName = _examen?['doctor_name']?.toString();
    
    final dateStr = _examen?['exam_date'] as String?;
    final date = dateStr != null ? DateTime.tryParse(dateStr) : null;

    return Container(
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
                child: const Icon(Icons.science, color: Colors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    if (laboratory != null && laboratory.isNotEmpty)
                      Text(laboratory, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
              const SizedBox(width: 8),
              Text(date != null ? 'Date : ${date.day}/${date.month}/${date.year}' : 'Date non spécifiée'),
            ],
          ),
          if (doctorName != null && doctorName.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 14, color: Colors.grey),
                const SizedBox(width: 8),
                Text('Médecin : $doctorName'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultsTable() {
    final results = _examen?['results'] as List? ?? [
      {'parametre': 'Globules blancs', 'valeur': '7.2', 'unite': 'G/L', 'norme': '4.0-10.0', 'statut': 'normal'},
      {'parametre': 'Globules rouges', 'valeur': '4.8', 'unite': 'T/L', 'norme': '4.5-5.9', 'statut': 'normal'},
      {'parametre': 'Hémoglobine', 'valeur': '14.2', 'unite': 'g/dL', 'norme': '13.5-17.5', 'statut': 'normal'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Résultats', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const Divider(),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: results.length,
            itemBuilder: (context, index) => _buildResultRow(results[index] as Map<String, dynamic>),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(Map<String, dynamic> result) {
    final parametre = result['parametre']?.toString() ?? '';
    final valeur = result['valeur']?.toString() ?? '';
    final unite = result['unite']?.toString() ?? '';
    final norme = result['norme']?.toString() ?? '';
    final statut = result['statut']?.toString() ?? 'normal';
    final isAbnormal = statut != 'normal';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(parametre, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '$valeur $unite',
              style: TextStyle(color: isAbnormal ? Colors.red : Colors.green.shade700, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(norme, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorComment() {
    final comment = _examen?['doctor_comment']?.toString();
    if (comment == null || comment.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Commentaire du médecin', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(comment),
        ],
      ),
    );
  }
}
