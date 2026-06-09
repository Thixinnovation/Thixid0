import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:thix_id/auth/auth_controller.dart';

class ThixSanteHome extends StatefulWidget {
  const ThixSanteHome({super.key});

  @override
  State<ThixSanteHome> createState() => _ThixSanteHomeState();
}

class _ThixSanteHomeState extends State<ThixSanteHome> {
  Map<String, dynamic>? _stats;
  List<Map<String, dynamic>> _services = [];
  List<Map<String, dynamic>> _articles = [];
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
      final userId = supabase.auth.currentUser?.id;

      // Charger les statistiques
      final stats = await supabase
          .from('health_stats')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      // Charger les services
      final services = await supabase
          .from('health_services')
          .select()
          .eq('is_active', true)
          .order('order_index');

      // Charger les articles
      final articles = await supabase
          .from('health_articles')
          .select()
          .eq('is_published', true)
          .order('created_at', ascending: false)
          .limit(5);

      setState(() {
        _stats = stats as Map<String, dynamic>?;
        _services = (services as List).cast<Map<String, dynamic>>();
        _articles = (articles as List).cast<Map<String, dynamic>>();
      });
    } catch (e) {
      debugPrint('Error loading health data: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthController>(context);
    final userName = auth.currentUser?.displayName?.split(' ').first ?? 'Visiteur';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('THIX SANTÉ', style: TextStyle(color: Color(0xFF0B1B3D), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined, color: Color(0xFF0B1B3D)), onPressed: () {}),
          IconButton(icon: const Icon(Icons.settings_outlined, color: Color(0xFF0B1B3D)), onPressed: () {}),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(userName),
                  const SizedBox(height: 20),
                  _buildStatsGrid(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('SERVICES SANTÉ', 'Voir tout'),
                  const SizedBox(height: 12),
                  _buildServicesGrid(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('SERVICES RAPIDES', null),
                  const SizedBox(height: 12),
                  _buildQuickActions(),
                  const SizedBox(height: 24),
                  _buildInsuranceCard(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('POUR VOUS', 'Voir tous'),
                  const SizedBox(height: 12),
                  _buildArticlesList(),
                  const SizedBox(height: 24),
                  _buildEmergencyButton(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader(String userName) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0B1B3D), Color(0xFF1A2D56)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bonjour, $userName 👋', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Votre santé entre de bonnes mains', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
            child: const Text('Dossier de santé', style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        _buildStatCard('Consultations', '${_stats?['consultations_count'] ?? 0}', 'Cette année', () => context.push('/sante/consultations')),
        const SizedBox(width: 12),
        _buildStatCard('Examens', '${_stats?['examens_count'] ?? 0}', 'En attente', () => context.push('/sante/examens')),
        const SizedBox(width: 12),
        _buildStatCard('Ordonnances', '${_stats?['ordonnances_count'] ?? 0}', 'Actives', () => context.push('/sante/ordonnances')),
        const SizedBox(width: 12),
        _buildStatCard('Urgences', '${_stats?['urgences_count'] ?? 0}', 'Appels', () => context.push('/sante/urgences')),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0B1B3D))),
              const SizedBox(height: 4),
              Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String? seeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        if (seeAll != null)
          GestureDetector(
            onTap: () {},
            child: Text(seeAll, style: const TextStyle(fontSize: 12, color: Color(0xFFD4AF37))),
          ),
      ],
    );
  }

  Widget _buildServicesGrid() {
    if (_services.isEmpty) {
      return const Center(child: Text('Aucun service disponible'));
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.9, crossAxisSpacing: 8, mainAxisSpacing: 8),
      itemCount: _services.length,
      itemBuilder: (context, index) {
        final service = _services[index];
        return _buildServiceCard(service['icon'] as String? ?? '🏥', service['name'], service['route'] as String?);
      },
    );
  }

  Widget _buildServiceCard(String icon, String name, String? route) {
    return GestureDetector(
      onTap: route != null ? () => context.push(route) : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      ('👨‍⚕️', 'Consulter un médecin', '/sante/consultation'),
      ('📁', 'Dossier médical', '/sante/dossier'),
      ('🔬', 'Résultats d\'examens', '/sante/resultats'),
      ('📄', 'Mes ordonnances', '/sante/ordonnances'),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.5, crossAxisSpacing: 12, mainAxisSpacing: 12),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return GestureDetector(
          onTap: () => context.push(action.$3),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
            child: Row(
              children: [
                Text(action.$1, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(child: Text(action.$2, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInsuranceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFD4AF37), Color(0xFFE5B13A)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield, size: 40, color: Color(0xFF0B1B3D)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Assurance santé', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0B1B3D))),
                const Text('Bénéficiez d\'une couverture complète', style: TextStyle(fontSize: 12, color: Color(0xFF0B1B3D))),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => context.push('/sante/assurance'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF0B1B3D)),
                  child: const Text('Découvrir'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticlesList() {
    if (_articles.isEmpty) {
      return const Center(child: Text('Aucun article disponible'));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _articles.length,
      itemBuilder: (context, index) {
        final article = _articles[index];
        return GestureDetector(
          onTap: () => context.push('/sante/article/${article['id']}'),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.article, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(article['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('${article['read_time'] ?? 3} min de lecture', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmergencyButton() {
    return GestureDetector(
      onTap: () => context.push('/sante/urgences'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('BESOIN D\'AIDE IMMÉDIATE ?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red)),
                Text('Contactez les urgences en un clic', style: TextStyle(fontSize: 11, color: Colors.red)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(30)),
              child: const Text('Appeler 15', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
