import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:thix_id/auth/auth_controller.dart';
import 'package:thix_id/services/health_service.dart';
import 'widgets/health_header.dart';
import 'widgets/health_stats_grid.dart';
import 'widgets/health_service_card.dart';
import 'widgets/health_quick_action.dart';
import 'widgets/health_insurance_card.dart';
import 'widgets/health_article_card.dart';

class ThixSanteHome extends StatefulWidget {
  const ThixSanteHome({super.key});

  @override
  State<ThixSanteHome> createState() => _ThixSanteHomeState();
}

class _ThixSanteHomeState extends State<ThixSanteHome> {
  late HealthService _healthService;
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _services = [];
  List<Map<String, dynamic>> _articles = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _healthService = HealthService();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final stats = await _healthService.getStats();
      final services = await _getServices();
      final articles = await _healthService.getArticles(limit: 5);

      setState(() {
        _stats = stats;
        _services = services;
        _articles = articles.map((a) => a.toJson()).toList();
      });
    } catch (e) {
      debugPrint('Error loading health data: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<List<Map<String, dynamic>>> _getServices() async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('health_services')
        .select()
        .eq('is_active', true)
        .order('order_index');
    return (response as List).cast<Map<String, dynamic>>();
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
                  HealthHeader(
                    userName: userName,
                    onNotificationTap: () {},
                    onSettingsTap: () {},
                  ),
                  const SizedBox(height: 20),
                  HealthStatsGrid(
                    consultationsCount: _stats['consultations_count'] ?? 0,
                    examensCount: _stats['examens_count'] ?? 0,
                    ordonnancesCount: _stats['ordonnances_count'] ?? 0,
                    urgencesCount: _stats['urgences_count'] ?? 0,
                    onConsultationsTap: () => context.push('/sante/consultations'),
                    onExamensTap: () => context.push('/sante/examens'),
                    onOrdonnancesTap: () => context.push('/sante/ordonnances'),
                    onUrgencesTap: () => context.push('/sante/urgences'),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('SERVICES SANTÉ', 'Voir tout'),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.9,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _services.length,
                    itemBuilder: (context, index) {
                      final service = _services[index];
                      return HealthServiceCard(
                        icon: service['icon'] as String? ?? '🏥',
                        title: service['name'],
                        onTap: service['route'] != null ? () => context.push(service['route']) : null,
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('SERVICES RAPIDES', null),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      final actions = [
                        ('👨‍⚕️', 'Consulter un médecin', '/sante/consultation'),
                        ('📁', 'Dossier médical', '/sante/dossier'),
                        ('🔬', 'Résultats d\'examens', '/sante/resultats'),
                        ('📄', 'Mes ordonnances', '/sante/ordonnances'),
                      ];
                      return HealthQuickAction(
                        icon: actions[index].$1,
                        title: actions[index].$2,
                        onTap: () => context.push(actions[index].$3),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  HealthInsuranceCard(
                    planName: _stats['insurance_plan'] ?? 'Essentiel',
                    expiryDate: _stats['insurance_expiry'] ?? '31/12/2024',
                    hasInsurance: _stats['has_insurance'] ?? false,
                    onTap: () => context.push('/sante/assurance'),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('POUR VOUS', 'Voir tous'),
                  const SizedBox(height: 12),
                  ..._articles.map((article) => HealthArticleCard(
                    id: article['id'],
                    title: article['title'],
                    imageUrl: article['image_url'] ?? '',
                    readTime: article['read_time'] ?? 3,
                    onTap: () => context.push('/sante/article/${article['id']}'),
                  )),
                  const SizedBox(height: 24),
                  _buildEmergencyButton(),
                  const SizedBox(height: 80),
                ],
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
