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

  // Bandes filantes (annonces)
  final List<String> _marqueeMessages = [
    '🏥 Nouveau : Téléconsultation disponible 24h/24',
    '💉 Campagne de vaccination gratuite dans tous les centres partenaires',
    '🩺 Consultation à domicile : réservez dès maintenant',
    '📱 Dossier médical numérique - Accédez à vos résultats en temps réel',
    '🏥 Assurance santé : -20% sur la première année',
  ];

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
      {'id': '5', 'name': 'Plus de services', 'icon': '✨', 'route': '/sante/services'},
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
        {'id': '5', 'name': 'Assurance', 'icon': '🏥', 'route': '/sante/insurance'},
        {'id': '6', 'name': 'Plus de services', 'icon': '✨', 'route': '/sante/services'},
      ];
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
                  // Bande filament défilante
                  _buildMarqueeBanner(),
                  const SizedBox(height: 12),
                  
                  // Header avec message de bienvenue
                  HealthHeader(),
                  const SizedBox(height: 12),
                  
                  // Résumé de santé (stats)
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
                  const SizedBox(height: 20),
                  
                  // Services santé (liste verticale comme sur la photo)
                  _buildSectionTitle('Services santé', 'Voir tout'),
                  const SizedBox(height: 8),
                  ..._services.map((service) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildServiceListItem(service),
                  )),
                  const SizedBox(height: 16),
                  
                  // Services rapides
                  _buildSectionTitle('Services rapides', null),
                  const SizedBox(height: 8),
                  _buildQuickServicesGrid(),
                  const SizedBox(height: 16),
                  
                  // Assurance santé
                  _buildSectionTitle('Assurances santé', 'Voir tout'),
                  const SizedBox(height: 8),
                  _buildHealthInsuranceGrid(),
                  const SizedBox(height: 16),
                  
                  // Pour vous (articles)
                  _buildSectionTitle('Pour vous', 'Voir tous'),
                  const SizedBox(height: 8),
                  ..._articles.take(4).map((article) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: HealthArticleCard(
                      id: article['id'],
                      title: article['title'],
                      imageUrl: article['image_url'] ?? '',
                      readTime: article['read_time'] ?? 3,
                      onTap: () => context.push('/sante/article/${article['id']}'),
                    ),
                  )),
                  const SizedBox(height: 16),
                  
                  // Bouton urgence 15
                  _buildEmergencyButton(),
                  const SizedBox(height: 60),
                ],
              ),
            ),
    );
  }

  // Bande filament défilante
  Widget _buildMarqueeBanner() {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFF0B1B3D),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _marqueeMessages.length * 10,
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final message = _marqueeMessages[index % _marqueeMessages.length];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.volume_up, size: 14, color: Color(0xFFD4AF37)),
                  const SizedBox(width: 8),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 24),
                  Container(width: 1, height: 20, color: Colors.white24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Service item en liste verticale (comme sur la photo)
  Widget _buildServiceListItem(Map<String, dynamic> service) {
    return GestureDetector(
      onTap: service['route'] != null ? () => context.push(service['route']) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 1))],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(service['icon'] ?? '🏥', style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service['name'],
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0B1B3D)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getServiceSubtitle(service['name']),
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  String _getServiceSubtitle(String serviceName) {
    final subtitles = {
      'Santé des enfants': 'Suivez la santé de vos enfants',
      'Carnet de vaccination': 'Consultez et gérez les vaccins',
      'Suivi grossesses': 'Suivez votre grossesse pas à pas',
      'Assurance santé': 'Protégez votre santé et celle de vos proches',
      'Assurance': 'Découvrez nos solutions d\'assurance adaptées',
      'Plus de services': 'Découvrez tous nos services',
    };
    return subtitles[serviceName] ?? 'Service disponible 24h/24';
  }

  Widget _buildSectionTitle(String title, String? seeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0B1B3D))),
        if (seeAll != null)
          GestureDetector(
            onTap: () {},
            child: Text(seeAll, style: const TextStyle(fontSize: 12, color: Color(0xFFD4AF37), fontWeight: FontWeight.w500)),
          ),
      ],
    );
  }

  // Grille des services rapides (4 items comme sur la photo)
  Widget _buildQuickServicesGrid() {
    final quickServices = [
      ('👨‍⚕️', 'Consulter\nun médecin', '/sante/consultation'),
      ('📁', 'Dossier\nmédical', '/sante/dossier'),
      ('🔬', 'Résultats\nd\'examens', '/sante/resultats'),
      ('📄', 'Mes\nordonnances', '/sante/ordonnances'),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => context.push(quickServices[index].$3),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4)],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(quickServices[index].$1, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 6),
                Text(
                  quickServices[index].$2,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF0B1B3D)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Grille des assurances santé (hôpital, médicament, pharmacie, urgences)
  Widget _buildHealthInsuranceGrid() {
    final insuranceServices = [
      ('🏥', 'Trouver un hôpital', 'Trouvez l\'hôpital le plus proche', '/sante/hopitaux'),
      ('💊', 'Trouver un médicament', 'Vérifiez la disponibilité', '/sante/recherche-medicament'),
      ('🏪', 'Pharmacies proches', 'Trouvez la pharmacie', '/sante/pharmacies'),
      ('🚑', 'Urgences proches', 'Services disponibles 24/7', '/sante/urgences'),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => context.push(insuranceServices[index].$4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4)],
            ),
            child: Row(
              children: [
                Text(insuranceServices[index].$1, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(insuranceServices[index].$2, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      Text(insuranceServices[index].$3, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.warning_amber_rounded, size: 28, color: Colors.white),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('URGENCES MÉDICALES', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('Besoin d\'aide immédiate ?', style: TextStyle(fontSize: 11, color: Colors.white70)),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text('15', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
