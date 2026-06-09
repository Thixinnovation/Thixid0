import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ArticleSantePage extends StatelessWidget {
  final String articleId;
  const ArticleSantePage({super.key, required this.articleId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Article', style: TextStyle(color: Color(0xFF0B1B3D), fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _loadArticle(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('Article non trouvé'));
          }
          final article = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                    image: article['image_url'] != null
                        ? DecorationImage(image: NetworkImage(article['image_url']), fit: BoxFit.cover)
                        : null,
                  ),
                  child: article['image_url'] == null
                      ? const Icon(Icons.image, size: 50, color: Colors.grey)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(article['title'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('${article['read_time'] ?? 3} min de lecture', style: const TextStyle(color: Colors.grey)),
                    const SizedBox(width: 16),
                    const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(article['created_at'].toString().substring(0, 10)),
                  ],
                ),
                const SizedBox(height: 24),
                Text(article['content'], style: const TextStyle(height: 1.5)),
                const SizedBox(height: 24),
                _buildShareButtons(),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>?> _loadArticle() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.from('health_articles').select().eq('id', articleId).maybeSingle();
      return response as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('Error loading article: $e');
      return null;
    }
  }

  Widget _buildShareButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.share),
            label: const Text('Partager'),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.blue),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.bookmark_border),
            label: const Text('Enregistrer'),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.green),
          ),
        ),
      ],
    );
  }
}
