import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:thix_id/auth/auth_controller.dart';
import 'package:thix_id/services/health_service.dart';
import 'widgets/health_header.dart';
import 'widgets/health_stats_grid.dart';
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
      final articles = await _healthService.getArticles(limit: 4);

      setState(() {
        _stats = stats;
        _services = services;
        _articles = articles.map((a) => a.toJson()).toList();
      });
    } catch (e) {
      debugPrint('Error loading health data: $e');
      _setMockData();
    } finally {
      setState(() => _loading = false);
    }
  }

  void _setMockData() {
    _stats = {
      'consultations_count': 12,
      'examens_count': 8,
      'ordonnances_count': 5,
      'urgences_count': 2,
    };
    _services = [
      {'id': '1', 'name': 'Santé des enfants', 'icon': '👶', 'route': '/sante/enfants'},
      {'id': '2', 'name': 'Carnet de vaccination', 'icon': '💉', 'route': '/sante/vaccination'},
      {'id': '3', 'name': 'Suivi grossesses', 'icon': '🤰', 'route': '/sante/grossesse'},
      {'id': '4', 'name': 'Assurance santé', 'icon': '🛡️', 'route': '/sante/assurance'},
      {'id': '5', 'name': 'Téléconsultation', 'icon': '📱', 'route': '/sante/teleconsultation'},
      {'id': '6', 'name': 'Plus de services', 'icon': '✨', 'route': '/sante/services'},
    ];
    _articles = [
      {'id': '1', 'title': '5 conseils pour rester en bonne santé', 'image_url': '', 'read_time': 3},
      {'id': '2', 'title': 'Alimentation équilibrée : les bases', 'image_url': '', 'read_time': 4},
      {'id': '3', 'title': 'Gérer le stress au quotidien', 'image_url': '', 'read_time': 3},
      {'id': '4', 'title': 'Prévention : un geste qui sauve', 'image_url': '', 'read_time': 2},
    ];
  }

  Future<List<Map<String, dynamic>>> _getServices() async {
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase
          .from('health_services')
          .select()
          .eq('is_active', true)
          .order('order_index');
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      return [
        {'id': '1', 'name': 'Santé des enfants', 'icon': '👶', 'route': '/sante/enfants'},
        {'id': '2', 'name': 'Carnet de vaccination', 'icon': '💉', 'route': '/sante/vaccination'},
        {'id': '3', 'name': 'Suivi grossesses', 'icon': '🤰', 'route': '/sante/grossesse'},
        {'id': '4', 'name': 'Assurance santé', 'icon': '🛡️', 'route': '/sante/assurance'},
        {'id': '5', 'name': 'Téléconsultation', 'icon': '📱', 'route': '/sante/teleconsultation'},
        {'id': '6', 'name': 'Plus de services', 'icon': '✨', 'route': '/sante/services'},
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthController>(context);
    final userName = auth.currentUser?.displayName?.split(' ').first ?? 'Visiteur';
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        toolbarHeight: 45,
        title: const Text('THIX SANTÉ', style: TextStyle(fontSize: 14, color: Color(0xFF0B1B3D), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 16, color: Color(0xFF0B1B3D)),
            onPressed: () => context.push('/sante/notifications'),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 16, color: Color(0xFF0B1B3D)),
            onPressed: () => context.push('/sante/settings'),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              height: screenHeight - 45,
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    HealthHeader(),
                    const SizedBox(height: 8),
                    
                    // Stats Grid
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
                    const SizedBox(height: 12),
                    
                    // Services santé en GRILLE (MOSAIC)
                    _buildSectionTitle('Services santé', 'Voir tout'),
                    const SizedBox(height: 8),
                    _buildServicesGrid(),
                    const SizedBox(height: 12),
                    
                    // Services rapides en GRILLE
                    _buildSectionTitle('Services rapides', null),
                    const SizedBox(height: 8),
                    _buildQuickServicesGrid(),
                    const SizedBox(height: 12),
                    
                    // Assurances santé en GRILLE
                    _buildSectionTitle('Assurances santé', 'Voir tout'),
                    const SizedBox(height: 8),
                    _buildHealthInsuranceGrid(),
                    const SizedBox(height: 12),
                    
                    // Articles (Pour vous)
                    _buildSectionTitle('Pour vous', 'Voir tous'),
                    const SizedBox(height: 8),
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
                    const SizedBox(height: 12),
                    
                    // Bouton urgence 15
                    _buildEmergencyButton(),
                    const SizedBox(height: 50),
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
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0B1B3D))),
        if (seeAll != null)
          GestureDetector(
            onTap: () => context.push('/sante/services'),
            child: Text(seeAll, style: const TextStyle(fontSize: 10, color: Color(0xFFD4AF37), fontWeight: FontWeight.w500)),
          ),
      ],
    );
  }

  // ==================== SERVICES SANTÉ EN GRILLE (MOSAIC) ====================
  Widget _buildServicesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _services.length,
      itemBuilder: (context, index) {
        final service = _services[index];
        return GestureDetector(
          onTap: () {
            if (service['route'] != null) {
              context.push(service['route']);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 2)],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(service['icon'] ?? '🏥', style: const TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  service['name'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF0B1B3D)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==================== SERVICES RAPIDES EN GRILLE ====================
  Widget _buildQuickServicesGrid() {
    final quickServices = [
      ('👨‍⚕️', 'Consulter médecin', '/sante/consultation'),
      ('📁', 'Dossier médical', '/sante/dossier'),
      ('🔬', 'Résultats examens', '/sante/resultats'),
      ('📄', 'Mes ordonnances', '/sante/ordonnances'),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.0,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => context.push(quickServices[index].$3),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 2)],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(quickServices[index].$1, style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 4),
                Text(
                  quickServices[index].$2,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500, color: Color(0xFF0B1B3D)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==================== ASSURANCES SANTÉ EN GRILLE ====================
  Widget _buildHealthInsuranceGrid() {
    final insuranceServices = [
      ('🏥', 'Trouver hôpital', 'Proche de vous', '/sante/hopitaux'),
      ('💊', 'Trouver médicament', 'Disponibilité', '/sante/recherche-medicament'),
      ('🏪', 'Pharmacies proches', 'À proximité', '/sante/pharmacies'),
      ('🚑', 'Urgences proches', '24h/24', '/sante/urgences'),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.0,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => context.push(insuranceServices[index].$4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 2)],
            ),
            child: Row(
              children: [
                Text(insuranceServices[index].$1, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(insuranceServices[index].$2, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                      Text(insuranceServices[index].$3, style: const TextStyle(fontSize: 9, color: Colors.grey)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, size: 14, color: Colors.grey),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==================== BOUTON URGENCE ====================
  Widget _buildEmergencyButton() {
    return GestureDetector(
      onTap: () => context.push('/sante/urgences'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 4)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.warning_amber_rounded, size: 20, color: Colors.white),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('URGENCES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('Appel immédiat', style: TextStyle(fontSize: 9, color: Colors.white70)),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Text('15', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }
}
