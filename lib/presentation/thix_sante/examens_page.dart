import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExamensPage extends StatefulWidget {
  const ExamensPage({super.key});

  @override
  State<ExamensPage> createState() => _ExamensPageState();
}

class _ExamensPageState extends State<ExamensPage> {
  List<Map<String, dynamic>> _examens = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadExamens();
  }

  Future<void> _loadExamens() async {
    setState(() => _loading = true);
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id ?? '';

      final response = await supabase
          .from('health_examens')
          .select()
          .eq('user_id', userId)
          .order('exam_date', ascending: false);

      setState(() {
        _examens = (response as List).cast<Map<String, dynamic>>();
      });
    } catch (e) {
      debugPrint('Error loading examens: $e');
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
        title: const Text('Mes examens', style: TextStyle(color: Color(0xFF0B1B3D), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined, color: Color(0xFF0B1B3D)),
            onPressed: () {},
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _examens.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.science, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Aucun examen'),
                      Text('Les résultats d\'examens apparaîtront ici'),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _examens.length,
                  itemBuilder: (context, index) => _buildExamenCard(_examens[index]),
                ),
    );
  }

  Widget _buildExamenCard(Map<String, dynamic> examen) {
    final date = DateTime.parse(examen['exam_date']);
    final hasResult = examen['result_url'] != null;

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
                    Text(examen['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(examen['laboratory'] ?? 'Laboratoire', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              if (hasResult)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20)),
                  child: const Text('Disponible', style: TextStyle(fontSize: 11, color: Colors.green)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
              const SizedBox(width: 8),
              Text('${date.day}/${date.month}/${date.year}'),
            ],
          ),
          const SizedBox(height: 12),
          if (hasResult)
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.picture_as_pdf, size: 16),
              label: const Text('Voir le résultat'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade100, foregroundColor: Colors.blue),
            ),
        ],
      ),
    );
  }
}
