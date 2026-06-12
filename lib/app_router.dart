import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thix_id/auth/auth_controller.dart';
import 'package:thix_id/models/app_user.dart';

// Pages
import 'presentation/home/home_page.dart';
import 'presentation/auth/login_page.dart';
import 'presentation/auth/personal_registration_page.dart';
import 'presentation/auth/enterprise_registration_page.dart';
import 'presentation/payment/payment_gateway_page.dart';
import 'presentation/payment/activation_receipt_page.dart';
import 'presentation/profile/public_profile_page.dart';
import 'presentation/dashboard/user_dashboard_page.dart';
import 'presentation/enterprise/enterprise_dashboard_page.dart';
import 'presentation/chat/thix_chat_page.dart';
import 'presentation/vault/document_vault_page.dart';
import 'presentation/settings/settings_page.dart';

// ==================== RÉSEAU PRO ====================
import 'presentation/network/network_pro_home.dart';
import 'presentation/network/member_profile.dart';
import 'presentation/network/post_detail_page.dart';
import 'presentation/network/search_network_page.dart';
import 'presentation/network/community_detail_page.dart';
import 'presentation/network/settings_network_page.dart';
import 'presentation/network/blocked_users_page.dart';
import 'presentation/network/network_groups_list.dart';
import 'presentation/network/messages/conversations_list.dart';
import 'presentation/network/messages/chat_screen.dart';
import 'presentation/network/notifications/notifications_page.dart';

// ==================== THIX SANTÉ ====================
import 'presentation/thix_sante/thix_sante_home.dart';
import 'presentation/thix_sante/consultations_page.dart';
import 'presentation/thix_sante/examens_page.dart';
import 'presentation/thix_sante/ordonnances_page.dart';
import 'presentation/thix_sante/dossier_medical_page.dart';
import 'presentation/thix_sante/consultation_medecin_page.dart';
import 'presentation/thix_sante/teleconsultation_page.dart';
import 'presentation/thix_sante/resultat_examen_page.dart';
import 'presentation/thix_sante/carnet_vaccination_page.dart';
import 'presentation/thix_sante/suivi_grossesse_page.dart';
import 'presentation/thix_sante/assurance_sante_page.dart';
import 'presentation/thix_sante/hopitaux_proches_page.dart';
import 'presentation/thix_sante/pharmacies_proches_page.dart';
import 'presentation/thix_sante/urgences_page.dart';
import 'presentation/thix_sante/article_sante_page.dart';
import 'presentation/thix_sante/recherche_medicament_page.dart';

// ==================== AUTRES SERVICES ====================
import 'presentation/jobs/jobs_page.dart';
import 'presentation/jobs/job_apply_page.dart';
import 'presentation/jobs/job_details_page.dart';
import 'presentation/jobs/job_dashboard_page.dart';
import 'presentation/recruiter/recruiter_portal_page.dart';
import 'presentation/opportunities/opportunities_page.dart';
import 'presentation/opportunities/opportunity_apply_page.dart';
import 'presentation/opportunities/opportunity_details_page.dart';
import 'presentation/education/education_page.dart';
import 'presentation/training/training_home_page.dart';
import 'presentation/training/training_details_page.dart';
import 'presentation/training/learning_dashboard_page.dart';
import 'presentation/training/lesson_player_page.dart';
import 'presentation/admin/admin_page.dart';
import 'presentation/thix_market/thix_market_page.dart';
import 'presentation/thix_market/cart_page.dart';
import 'presentation/thix_market/checkout_page.dart';
import 'presentation/thix_market/order_history_page.dart';
import 'presentation/thix_reservation/thix_reservation_page.dart';
import 'presentation/thix_money/thix_money_page.dart';
import 'presentation/thix_media/thix_media_page.dart';

// Modèles
// import 'models/event_item.dart'; ← SUPPRIMÉ

class NoTransitionPage<T> extends Page<T> {
  final Widget child;
  const NoTransitionPage({required this.child, super.key});

  @override
  Route<T> createRoute(BuildContext context) {
    return MaterialPageRoute(builder: (context) => child, settings: this);
  }
}

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String personalReg = '/personal-reg';
  static const String enterpriseReg = '/enterprise-reg';
  static const String userDashboard = '/user-dashboard';
  static const String enterpriseDashboard = '/enterprise-dashboard';
  static const String chat = '/chat';
  static const String vault = '/vault';
  static const String settings = '/settings';
  
  // Réseau Pro
  static const String networkPro = '/network-pro';
  static const String networkProfile = '/network/profile/:userId';
  static const String networkPost = '/network/post/:postId';
  static const String networkSearch = '/network/search';
  static const String networkCommunity = '/network/community/:communityId';
  static const String networkSettings = '/network/settings';
  static const String networkBlocked = '/network/blocked';
  static const String networkGroups = '/network/groups';
  static const String networkMessages = '/network/messages';
  static const String networkChat = '/network/chat/:userId';
  static const String networkNotifications = '/network/notifications';
  
  // THIX SANTÉ
  static const String thixSante = '/sante';
  static const String santeConsultations = '/sante/consultations';
  static const String santeExamens = '/sante/examens';
  static const String santeOrdonnances = '/sante/ordonnances';
  static const String santeDossier = '/sante/dossier';
  static const String santeConsultationMedecin = '/sante/consultation';
  static const String santeTeleconsultation = '/sante/teleconsultation/:doctorId/:doctorName/:channelName';
  static const String santeResultats = '/sante/resultats';
  static const String santeVaccination = '/sante/vaccination';
  static const String santeGrossesse = '/sante/grossesse';
  static const String santeAssurance = '/sante/assurance';
  static const String santeHopitaux = '/sante/hopitaux';
  static const String santePharmacies = '/sante/pharmacies';
  static const String santeUrgences = '/sante/urgences';
  static const String santeArticle = '/sante/article/:articleId';
  static const String santeRechercheMedicament = '/sante/recherche-medicament';
  
  // Autres services
  static const String jobs = '/jobs';
  static const String opportunities = '/opportunities';
  static const String education = '/education';
  static const String trainingHome = '/training';
  static const String admin = '/admin';
  static const String market = '/market';
  static const String marketCart = '/market/cart';
  static const String marketCheckout = '/market/checkout';
  static const String marketOrders = '/market/orders';
}

class AppRouter {
  static GoRouter create(AuthController auth) {
    return GoRouter(
      initialLocation: AppRoutes.home,
      refreshListenable: auth,
      redirect: (context, state) {
        final isLoggedIn = auth.isAuthenticated;
        final location = state.matchedLocation;

        final isAuthPage = location == AppRoutes.login ||
            location == AppRoutes.personalReg ||
            location == AppRoutes.enterpriseReg;
            
        final isPublic = location == AppRoutes.home ||
            location.startsWith('/sante') ||
            location == AppRoutes.jobs ||
            location == AppRoutes.opportunities ||
            location == AppRoutes.education ||
            location == AppRoutes.trainingHome;

        if (!isLoggedIn && !isAuthPage && !isPublic) {
          return AppRoutes.login;
        }
        if (isLoggedIn && isAuthPage) {
          final user = auth.currentUser;
          if (user?.accountType == AccountType.enterprise) {
            return AppRoutes.enterpriseDashboard;
          }
          return AppRoutes.userDashboard;
        }
        return null;
      },
      routes: [
        // ==================== PAGE D'ACCUEIL ====================
        GoRoute(
          path: AppRoutes.home,
          pageBuilder: (context, state) => NoTransitionPage(child: HomePagePremium()),
        ),

        // ==================== AUTHENTIFICATION ====================
        GoRoute(
          path: AppRoutes.login,
          pageBuilder: (context, state) => NoTransitionPage(child: LoginPage()),
        ),
        GoRoute(
          path: AppRoutes.personalReg,
          pageBuilder: (context, state) => NoTransitionPage(child: PersonalRegistrationPage()),
        ),
        GoRoute(
          path: AppRoutes.enterpriseReg,
          pageBuilder: (context, state) => NoTransitionPage(child: EnterpriseRegistrationPage()),
        ),

        // ==================== TABLEAUX DE BORD ====================
        GoRoute(
          path: AppRoutes.userDashboard,
          pageBuilder: (context, state) => NoTransitionPage(child: UserDashboardPage()),
        ),
        GoRoute(
          path: AppRoutes.enterpriseDashboard,
          pageBuilder: (context, state) => NoTransitionPage(child: EnterpriseDashboardPage()),
        ),

        // ==================== SERVICES GÉNÉRAUX ====================
        GoRoute(
          path: AppRoutes.chat,
          pageBuilder: (context, state) => NoTransitionPage(child: ThixChatPage()),
        ),
        GoRoute(
          path: AppRoutes.vault,
          pageBuilder: (context, state) => NoTransitionPage(child: DocumentVaultPage()),
        ),
        GoRoute(
          path: AppRoutes.settings,
          pageBuilder: (context, state) => NoTransitionPage(child: SettingsPage()),
        ),

        // ==================== RÉSEAU PRO ====================
        GoRoute(
          path: AppRoutes.networkPro,
          name: 'network-pro',
          pageBuilder: (context, state) => NoTransitionPage(child: NetworkProHome()),
        ),
        GoRoute(
          path: AppRoutes.networkProfile,
          name: 'network-profile',
          pageBuilder: (context, state) {
            final userId = state.pathParameters['userId']!;
            return NoTransitionPage(child: MemberProfile(userId: userId));
          },
        ),
        GoRoute(
          path: AppRoutes.networkPost,
          name: 'network-post',
          pageBuilder: (context, state) {
            final postId = state.pathParameters['postId']!;
            return NoTransitionPage(child: PostDetailPage(postId: postId));
          },
        ),
        GoRoute(
          path: AppRoutes.networkSearch,
          name: 'network-search',
          pageBuilder: (context, state) => NoTransitionPage(child: SearchNetworkPage()),
        ),
        GoRoute(
          path: AppRoutes.networkCommunity,
          name: 'network-community',
          pageBuilder: (context, state) {
            final communityId = state.pathParameters['communityId']!;
            return NoTransitionPage(child: CommunityDetailPage(communityId: communityId));
          },
        ),
        GoRoute(
          path: AppRoutes.networkSettings,
          name: 'network-settings',
          pageBuilder: (context, state) => NoTransitionPage(child: SettingsNetworkPage()),
        ),
        GoRoute(
          path: AppRoutes.networkBlocked,
          name: 'network-blocked',
          pageBuilder: (context, state) => NoTransitionPage(child: BlockedUsersPage()),
        ),
        GoRoute(
          path: AppRoutes.networkGroups,
          name: 'network-groups',
          pageBuilder: (context, state) => NoTransitionPage(child: NetworkGroupsList()),
        ),
        GoRoute(
          path: AppRoutes.networkMessages,
          name: 'network-messages',
          pageBuilder: (context, state) => NoTransitionPage(child: ConversationsList()),
        ),
        GoRoute(
          path: AppRoutes.networkChat,
          name: 'network-chat',
          pageBuilder: (context, state) {
            final userId = state.pathParameters['userId']!;
            final userName = state.extra as String? ?? '';
            return NoTransitionPage(child: ChatScreen(userId: userId, userName: userName));
          },
        ),
        GoRoute(
          path: AppRoutes.networkNotifications,
          name: 'network-notifications',
          pageBuilder: (context, state) => NoTransitionPage(child: NotificationsPage()),
        ),

        // ==================== THIX SANTÉ ====================
        GoRoute(
          path: AppRoutes.thixSante,
          name: 'thixSante',
          pageBuilder: (context, state) => NoTransitionPage(child: ThixSanteHome()),
        ),
        GoRoute(
          path: AppRoutes.santeConsultations,
          name: 'santeConsultations',
          pageBuilder: (context, state) => NoTransitionPage(child: ConsultationsPage()),
        ),
        GoRoute(
          path: AppRoutes.santeExamens,
          name: 'santeExamens',
          pageBuilder: (context, state) => NoTransitionPage(child: ExamensPage()),
        ),
        GoRoute(
          path: AppRoutes.santeOrdonnances,
          name: 'santeOrdonnances',
          pageBuilder: (context, state) => NoTransitionPage(child: OrdonnancesPage()),
        ),
        GoRoute(
          path: AppRoutes.santeDossier,
          name: 'santeDossier',
          pageBuilder: (context, state) => NoTransitionPage(child: DossierMedicalPage()),
        ),
        GoRoute(
          path: AppRoutes.santeConsultationMedecin,
          name: 'santeConsultationMedecin',
          pageBuilder: (context, state) => NoTransitionPage(child: ConsultationMedecinPage()),
        ),
        GoRoute(
          path: AppRoutes.santeTeleconsultation,
          name: 'santeTeleconsultation',
          pageBuilder: (context, state) {
            final doctorId = state.pathParameters['doctorId'] ?? '';
            final doctorName = state.pathParameters['doctorName'] ?? '';
            final channelName = state.pathParameters['channelName'] ?? '';
            return NoTransitionPage(child: TeleconsultationPage(
              doctorId: doctorId,
              doctorName: doctorName,
              channelName: channelName,
            ));
          },
        ),
        GoRoute(
          path: AppRoutes.santeResultats,
          name: 'santeResultats',
          pageBuilder: (context, state) => NoTransitionPage(child: ResultatExamenPage()),
        ),
        GoRoute(
          path: AppRoutes.santeVaccination,
          name: 'santeVaccination',
          pageBuilder: (context, state) => NoTransitionPage(child: CarnetVaccinationPage()),
        ),
        GoRoute(
          path: AppRoutes.santeGrossesse,
          name: 'santeGrossesse',
          pageBuilder: (context, state) => NoTransitionPage(child: SuiviGrossessePage()),
        ),
        GoRoute(
          path: AppRoutes.santeAssurance,
          name: 'santeAssurance',
          pageBuilder: (context, state) => NoTransitionPage(child: AssuranceSantePage()),
        ),
        GoRoute(
          path: AppRoutes.santeHopitaux,
          name: 'santeHopitaux',
          pageBuilder: (context, state) => NoTransitionPage(child: HopitauxProchesPage()),
        ),
        GoRoute(
          path: AppRoutes.santePharmacies,
          name: 'santePharmacies',
          pageBuilder: (context, state) => NoTransitionPage(child: PharmaciesProchesPage()),
        ),
        GoRoute(
          path: AppRoutes.santeUrgences,
          name: 'santeUrgences',
          pageBuilder: (context, state) => NoTransitionPage(child: UrgencesPage()),
        ),
        GoRoute(
          path: AppRoutes.santeArticle,
          name: 'santeArticle',
          pageBuilder: (context, state) {
            final articleId = state.pathParameters['articleId'] ?? '';
            return NoTransitionPage(child: ArticleSantePage(articleId: articleId));
          },
        ),
        GoRoute(
          path: AppRoutes.santeRechercheMedicament,
          name: 'santeRechercheMedicament',
          pageBuilder: (context, state) => NoTransitionPage(child: RechercheMedicamentPage()),
        ),

        // ==================== JOB ROUTES ====================
        GoRoute(
          path: AppRoutes.jobs,
          pageBuilder: (context, state) => NoTransitionPage(child: JobsPage()),
        ),
        GoRoute(
          path: '/jobs/:jobId',
          pageBuilder: (context, state) {
            final jobId = state.pathParameters['jobId'] ?? '';
            final applied = (state.uri.queryParameters['applied'] ?? '').trim() == '1';
            return NoTransitionPage(child: JobDetailsPage(jobId: jobId, applied: applied));
          },
        ),
        GoRoute(
          path: '/jobs/:jobId/apply',
          pageBuilder: (context, state) {
            final jobId = state.pathParameters['jobId'] ?? '';
            return NoTransitionPage(child: JobApplyPage(jobId: jobId));
          },
        ),
        GoRoute(
          path: '/job-dashboard',
          pageBuilder: (context, state) => NoTransitionPage(child: JobDashboardPage()),
        ),
        GoRoute(
          path: '/recruiter',
          pageBuilder: (context, state) => NoTransitionPage(child: RecruiterPortalPage()),
        ),

        // ==================== OPPORTUNITIES ROUTES ====================
        GoRoute(
          path: AppRoutes.opportunities,
          pageBuilder: (context, state) => NoTransitionPage(child: OpportunitiesPage()),
        ),
        GoRoute(
          path: '/opportunities/:opportunityId',
          pageBuilder: (context, state) {
            final opportunityId = state.pathParameters['opportunityId'] ?? '';
            final applied = (state.uri.queryParameters['applied'] ?? '').trim() == '1';
            return NoTransitionPage(child: OpportunityDetailsPage(opportunityId: opportunityId, applied: applied));
          },
        ),
        GoRoute(
          path: '/opportunities/:opportunityId/apply',
          pageBuilder: (context, state) {
            final opportunityId = state.pathParameters['opportunityId'] ?? '';
            return NoTransitionPage(child: OpportunityApplyPage(opportunityId: opportunityId));
          },
        ),

        // ==================== TRAINING ROUTES ====================
        GoRoute(
          path: AppRoutes.trainingHome,
          pageBuilder: (context, state) => NoTransitionPage(child: TrainingHomePage()),
        ),
        GoRoute(
          path: '/training/:trainingId',
          pageBuilder: (context, state) {
            final trainingId = state.pathParameters['trainingId'] ?? '';
            return NoTransitionPage(child: TrainingDetailsPage(trainingId: trainingId));
          },
        ),
        GoRoute(
          path: '/learning-dashboard',
          pageBuilder: (context, state) => NoTransitionPage(child: LearningDashboardPage()),
        ),
        GoRoute(
          path: '/lesson/:enrollmentId',
          pageBuilder: (context, state) {
            final enrollmentId = state.pathParameters['enrollmentId'] ?? '';
            return NoTransitionPage(child: LessonPlayerPage(enrollmentId: enrollmentId));
          },
        ),

        // ==================== EDUCATION ROUTE ====================
        GoRoute(
          path: AppRoutes.education,
          pageBuilder: (context, state) => NoTransitionPage(child: EducationPage()),
        ),

        // ==================== THIX MARKET ROUTES ====================
        GoRoute(
          path: AppRoutes.market,
          name: 'market',
          pageBuilder: (context, state) => NoTransitionPage(child: ThixMarketPage()),
        ),
        GoRoute(
          path: AppRoutes.marketCart,
          name: 'marketCart',
          pageBuilder: (context, state) => NoTransitionPage(child: CartPage()),
        ),
        GoRoute(
          path: AppRoutes.marketCheckout,
          name: 'marketCheckout',
          pageBuilder: (context, state) => NoTransitionPage(child: CheckoutPage()),
        ),
        GoRoute(
          path: AppRoutes.marketOrders,
          name: 'marketOrders',
          pageBuilder: (context, state) => NoTransitionPage(child: OrderHistoryPage()),
        ),

        // ==================== THIX SERVICES ROUTES ====================
        GoRoute(
          path: '/reservation',
          pageBuilder: (context, state) => NoTransitionPage(child: ThixReservationPage()),
        ),
        GoRoute(
          path: '/thix-money',
          pageBuilder: (context, state) => NoTransitionPage(child: ThixMoneyPage()),
        ),
        GoRoute(
          path: '/thix-media',
          pageBuilder: (context, state) => NoTransitionPage(child: ThixMediaPage()),
        ),

        // ==================== ADMIN ROUTES ====================
        GoRoute(
          path: AppRoutes.admin,
          name: 'adminRoot',
          redirect: (_, __) => '/admin/overview',
        ),
        GoRoute(
          path: '/admin/:module',
          name: 'admin',
          pageBuilder: (context, state) {
            final moduleName = state.pathParameters['module'] ?? 'overview';
            final module = _stringToModule(moduleName);
            return NoTransitionPage(
              child: AdminPage(module: module),
            );
          },
        ),
      ],
    );
  }
  
  // Helper pour convertir string en AdminModule
  static AdminModule _stringToModule(String name) {
    final slug = name.toLowerCase().trim();

    switch (slug) {
      case 'overview':
        return AdminModule.overview;
      case 'account-access-requests':
      case 'access-requests':
      case 'accessrequests':
        return AdminModule.accessRequests;
      case 'user-management':
      case 'users':
        return AdminModule.users;
      case 'verification-center':
      case 'verification':
        return AdminModule.verification;
      case 'trainings':
        return AdminModule.trainings;
      case 'thix-uid':
      case 'uid':
        return AdminModule.uid;
      case 'jobs-opportunities':
      case 'jobs':
        return AdminModule.jobs;
      case 'info-news':
      case 'news':
        return AdminModule.news;
      case 'thix-chat-admin':
      case 'chat':
        return AdminModule.chat;
      case 'sos-emergency':
      case 'sos':
        return AdminModule.sos;
      case 'institutions':
        return AdminModule.institutions;
      case 'analytics':
        return AdminModule.analytics;
      case 'cybersecurity':
        return AdminModule.cybersecurity;
      case 'api-integrations':
      case 'api':
        return AdminModule.api;
      case 'audit-activity':
      case 'audit':
        return AdminModule.audit;
      case 'thix-media':
      case 'media':
        return AdminModule.media;
      case 'settings':
        return AdminModule.settings;
      default:
        debugPrint('⚠️ Module inconnu: $slug → fallback sur overview');
        return AdminModule.overview;
    }
  }
}
