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
        titleSpacing: 0,
        toolbarHeight: 48,
        title: const Text('THIX SANTÉ', style: TextStyle(fontSize: 16, color: Color(0xFF0B1B3D), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined, size: 18, color: Color(0xFF0B1B3D)), onPressed: () {}, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
          IconButton(icon: const Icon(Icons.settings_outlined, size: 18, color: Color(0xFF0B1B3D)), onPressed: () {}, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HealthHeader(),
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 16),
                  _buildSectionTitle('SERVICES SANTÉ', 'Voir tout'),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 1.1,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
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
                  const SizedBox(height: 16),
                  _buildSectionTitle('SERVICES RAPIDES', null),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 2.2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 6,
                    ),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      final actions = [
                        ('👨‍⚕️', 'Consulter', '/sante/consultation'),
                        ('📁', 'Dossier', '/sante/dossier'),
                        ('🔬', 'Examens', '/sante/resultats'),
                        ('📄', 'Ordonnances', '/sante/ordonnances'),
                      ];
                      return HealthQuickAction(
                        icon: actions[index].$1,
                        title: actions[index].$2,
                        onTap: () => context.push(actions[index].$3),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const HealthInsuranceCard(
                    planName: 'Essentiel',
                    expiryDate: '31/12/2024',
                    hasInsurance: false,
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle('POUR VOUS', 'Voir tous'),
                  const SizedBox(height: 6),
                  ..._articles.take(3).map((article) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: HealthArticleCard(
                      id: article['id'],
                      title: article['title'],
                      imageUrl: article['image_url'] ?? '',
                      readTime: article['read_time'] ?? 3,
                      onTap: () => context.push('/sante/article/${article['id']}'),
                    ),
                  )),
                  const SizedBox(height: 16),
                  _buildEmergencyButton(),
                  const SizedBox(height: 60),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title, String? seeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: -0.3)),
        if (seeAll != null)
          GestureDetector(
            onTap: () {},
            child: Text(seeAll, style: const TextStyle(fontSize: 10, color: Color(0xFFD4AF37), fontWeight: FontWeight.w500)),
          ),
      ],
    );
  }

  Widget _buildEmergencyButton() {
    return GestureDetector(
      onTap: () => context.push('/sante/urgences'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200, width: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.warning_amber_rounded, size: 16, color: Colors.red),
                SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('URGENCES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red)),
                    Text('Appel immédiat', style: TextStyle(fontSize: 9, color: Colors.red)),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
              child: const Text('15', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}
