import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thix_id/auth/auth_controller.dart';
import 'package:thix_id/models/app_user.dart';

// Imports des écrans (tous vos écrans existants)
import 'presentation/home/home_page.dart';
import 'presentation/auth/login_page.dart';
import 'presentation/auth/personal_registration_page.dart';
import 'presentation/auth/enterprise_registration_page.dart';
import 'presentation/payment/payment_gateway_page.dart';
import 'presentation/payment/activation_receipt_page.dart';
import 'presentation/profile/public_profile_page.dart';
import 'presentation/dashboard/user_dashboard_page.dart';
import 'presentation/enterprise/enterprise_dashboard_page.dart';
import 'package:thix_id/presentation/enterprise/enterprise_portal_page.dart';
import 'package:thix_id/presentation/enterprise/enterprise_dashboard_shell_page.dart';
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
import 'presentation/network/connections_list_page.dart';
import 'presentation/network/my_posts_page.dart';

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
import 'package:thix_id/presentation/jobs/job_apply_page.dart';
import 'package:thix_id/presentation/jobs/job_details_page.dart';
import 'package:thix_id/presentation/jobs/job_dashboard_page.dart';
import 'package:thix_id/presentation/recruiter/recruiter_portal_page.dart';
import 'package:thix_id/presentation/opportunities/opportunities_page.dart';
import 'package:thix_id/presentation/opportunities/opportunity_apply_page.dart';
import 'package:thix_id/presentation/opportunities/opportunity_details_page.dart';
import 'presentation/events/events_page.dart';
import 'package:thix_id/presentation/events/event_details_page.dart';
import 'package:thix_id/presentation/events/event_register_page.dart';
import 'package:thix_id/presentation/events/event_ticket_page.dart';
import 'package:thix_id/presentation/events/user_event_dashboard_page.dart';
import 'presentation/education/education_page.dart';
import 'package:thix_id/presentation/training/training_home_page.dart';
import 'package:thix_id/presentation/training/training_details_page.dart';
import 'package:thix_id/presentation/training/learning_dashboard_page.dart';
import 'package:thix_id/presentation/training/lesson_player_page.dart';
import 'package:thix_id/presentation/admin/admin_page.dart';
import 'package:thix_id/presentation/admin/admin_routes.dart';
import 'package:thix_id/presentation/thix_market/thix_market_page.dart';
import 'package:thix_id/presentation/thix_market/cart_page.dart';
import 'package:thix_id/presentation/thix_market/checkout_page.dart';
import 'package:thix_id/presentation/thix_market/order_history_page.dart';
import 'package:thix_id/presentation/thix_reservation/thix_reservation_page.dart';
import 'package:thix_id/presentation/thix_money/thix_money_page.dart';
import 'package:thix_id/presentation/thix_media/thix_media_page.dart';
import 'package:thix_id/presentation/admin/pages/admin_media_page.dart';

/// Page sans transition (indispensable pour GoRouter)
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
  static const String enterprise = '/enterprise';
  static const String payment = '/payment';
  static const String activationReceipt = '/activation-receipt';
  static const String publicProfile = '/public-profile';
  static const String userDashboard = '/user-dashboard';
  static const String enterpriseDashboard = '/enterprise-dashboard';
  static const String enterprisePortalBasePath = '/company';
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
  static const String networkConnections = '/network/connections';
  static const String networkMyPosts = '/network/my-posts';
  
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
  static const String jobDashboard = '/jobs/dashboard';
  static const String recruiter = '/recruiter';
  static const String opportunities = '/opportunities';
  static const String events = '/events';
  static const String education = '/education';
  static const String trainingHome = '/training';
  static const String trainingDetails = '/training/:trainingId';
  static const String learningDashboard = '/learn';
  static const String lessonPlayer = '/learn/player';
  static const String admin = '/admin';
  static const String thixMarket = '/market';
  static const String thixMarketCart = '/market/cart';
  static const String thixMarketCheckout = '/market/checkout';
  static const String thixMarketOrders = '/market/orders';
  static const String reservation = '/reservation';
  static const String thixMoney = '/thix-money';
  static const String thixMedia = '/thix-media';
  static const String adminMedia = '/admin/media';

  static String enterprisePortalBase(String slug) => '$enterprisePortalBasePath/$slug';
  static String enterprisePortalDashboard(String slug, String section) => '/company/$slug/dashboard/$section';
}

class AppRouter {
  static GoRouter create(AuthController auth, {Listenable? extraRefreshListenable}) {
    final refresh = extraRefreshListenable ?? auth;
    return GoRouter(
      initialLocation: AppRoutes.home,
      refreshListenable: refresh,
      redirect: (context, state) {
        final location = state.matchedLocation;
        final isLoggedIn = auth.isAuthenticated;
        final isAuthPage = location == AppRoutes.login ||
            location == AppRoutes.personalReg ||
            location == AppRoutes.enterpriseReg;
        final isAdmin = location == AppRoutes.admin || location.startsWith('${AppRoutes.admin}/');
        final isEnterprisePortal = location.startsWith('${AppRoutes.enterprisePortalBasePath}/') ||
            location == AppRoutes.enterprisePortalBasePath;
        final isPublic = location == AppRoutes.home ||
            location == AppRoutes.publicProfile ||
            location == AppRoutes.jobs ||
            location == AppRoutes.opportunities ||
            location == AppRoutes.events ||
            location == AppRoutes.education ||
            location == AppRoutes.trainingHome ||
            location.startsWith('/training/') ||
            location.startsWith('/sante/');

        final isProtected = !isPublic && !isAuthPage;
        if (!isLoggedIn && isProtected) return AppRoutes.login;

        if (isAdmin && !isLoggedIn) return AppRoutes.login;

        if (isLoggedIn) {
          final u = auth.currentUser;
          final isActivated = (u?.hasRealThixId ?? false);
          final hasActiveTrial = (u?.hasActiveTrial ?? false);
          final isPaymentOrReceipt = location == AppRoutes.payment || location == AppRoutes.activationReceipt;
          final isDashboard = location == AppRoutes.userDashboard || location == AppRoutes.enterpriseDashboard;
          if (!isActivated && !hasActiveTrial && !isAuthPage && !isPublic && !isPaymentOrReceipt && !isDashboard) {
            final receiptReturn = Uri.encodeComponent(AppRoutes.activationReceipt);
            return '${AppRoutes.payment}?returnTo=$receiptReturn';
          }
        }

        if (isLoggedIn) {
          final t = auth.currentUser?.accountType;
          if (location == AppRoutes.userDashboard && t == AccountType.enterprise) return AppRoutes.enterpriseDashboard;
          if (location == AppRoutes.enterpriseDashboard && t == AccountType.personal) return AppRoutes.userDashboard;
        }

        if (isLoggedIn && isAuthPage) {
          final t = auth.currentUser?.accountType;
          return t == AccountType.enterprise ? AppRoutes.enterpriseDashboard : AppRoutes.userDashboard;
        }

        if (isEnterprisePortal) return null;
        return null;
      },
      routes: [
        // ==================== PAGE D'ACCUEIL ====================
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          pageBuilder: (context, state) => NoTransitionPage(child: HomePagePremium()),
        ),

        // ==================== AUTHENTIFICATION ====================
        GoRoute(
          path: AppRoutes.login,
          name: 'login',
          pageBuilder: (context, state) => NoTransitionPage(child: LoginPage()),
        ),
        GoRoute(
          path: AppRoutes.personalReg,
          name: 'personalReg',
          pageBuilder: (context, state) {
            final stepStr = state.uri.queryParameters['step'];
            final step = int.tryParse(stepStr ?? '') ?? 1;
            return NoTransitionPage(child: PersonalRegistrationPage(initialStep: step));
          },
        ),
        GoRoute(
          path: AppRoutes.enterpriseReg,
          name: 'enterpriseReg',
          pageBuilder: (context, state) => NoTransitionPage(child: EnterpriseRegistrationPage()),
        ),
        GoRoute(
          path: AppRoutes.payment,
          name: 'payment',
          pageBuilder: (context, state) {
            final returnTo = state.uri.queryParameters['returnTo'];
            return NoTransitionPage(child: PaymentGatewayPage(returnTo: returnTo));
          },
        ),
        GoRoute(
          path: AppRoutes.activationReceipt,
          name: 'activationReceipt',
          pageBuilder: (context, state) {
            final qp = state.uri.queryParameters;
            final paidAt = DateTime.tryParse((qp['paidAt'] ?? '').trim());
            return NoTransitionPage(
              child: ActivationReceiptPage(
                txRef: qp['txRef'],
                method: qp['method'],
                amount: qp['amount'],
                currency: qp['currency'],
                paidAt: paidAt,
              ),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.publicProfile,
          name: 'publicProfile',
          pageBuilder: (context, state) => NoTransitionPage(
            child: PublicProfilePage(initialThixId: state.uri.queryParameters['thixId']),
          ),
        ),
        GoRoute(
          path: AppRoutes.userDashboard,
          name: 'userDashboard',
          pageBuilder: (context, state) => NoTransitionPage(child: UserDashboardPage()),
        ),
        GoRoute(
          path: AppRoutes.enterpriseDashboard,
          name: 'enterpriseDashboard',
          pageBuilder: (context, state) => NoTransitionPage(child: EnterpriseDashboardPage()),
        ),
        GoRoute(
          path: AppRoutes.enterprise,
          name: 'enterpriseEntry',
          redirect: (context, state) {
            final isLoggedIn = auth.isAuthenticated;
            if (!isLoggedIn) return AppRoutes.login;
            final t = auth.currentUser?.accountType;
            if (t == AccountType.enterprise) return AppRoutes.enterpriseDashboard;
            return AppRoutes.enterpriseReg;
          },
        ),
        GoRoute(
          path: '/entreprise/:slug',
          name: 'enterprisePortalAliasFr',
          redirect: (context, state) {
            final slug = (state.pathParameters['slug'] ?? '').trim();
            return '${AppRoutes.enterprisePortalBase(slug)}/dashboard/overview';
          },
        ),
        GoRoute(
          path: '${AppRoutes.enterprisePortalBasePath}/:slug',
          name: 'enterprisePortal',
          pageBuilder: (context, state) {
            final slug = (state.pathParameters['slug'] ?? '').trim();
            return NoTransitionPage(child: EnterprisePortalPage(companySlug: slug));
          },
          routes: [
            GoRoute(
              path: 'dashboard/:section',
              name: 'enterprisePortalDashboard',
              pageBuilder: (context, state) {
                final slug = (state.pathParameters['slug'] ?? '').trim();
                final section = (state.pathParameters['section'] ?? 'overview').trim();
                return NoTransitionPage(child: EnterpriseDashboardShellPage(companySlug: slug, section: section));
              },
            ),
            GoRoute(
              path: 'dashboard',
              name: 'enterprisePortalDashboardRoot',
              redirect: (context, state) {
                final slug = (state.pathParameters['slug'] ?? '').trim();
                return '${AppRoutes.enterprisePortalBase(slug)}/dashboard/overview';
              },
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.chat,
          name: 'chat',
          pageBuilder: (context, state) => NoTransitionPage(child: ThixChatPage()),
        ),
        GoRoute(
          path: AppRoutes.vault,
          name: 'vault',
          pageBuilder: (context, state) => NoTransitionPage(child: DocumentVaultPage()),
        ),
        GoRoute(
          path: AppRoutes.settings,
          name: 'settings',
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
        GoRoute(
          path: AppRoutes.networkConnections,
          name: 'network-connections',
          pageBuilder: (context, state) => NoTransitionPage(child: ConnectionsListPage()),
        ),
        GoRoute(
          path: AppRoutes.networkMyPosts,
          name: 'network-my-posts',
          pageBuilder: (context, state) => NoTransitionPage(child: MyPostsPage()),
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
            return NoTransitionPage(
              child: TeleconsultationPage(
                doctorId: doctorId,
                doctorName: doctorName,
                channelName: channelName,
              ),
            );
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

        // ==================== THIX MARKET ROUTES ====================
        GoRoute(
          path: AppRoutes.thixMarket,
          name: 'thixMarket',
          pageBuilder: (context, state) => NoTransitionPage(child: ThixMarketPage()),
        ),
        GoRoute(
          path: AppRoutes.thixMarketCart,
          name: 'marketCart',
          pageBuilder: (context, state) => NoTransitionPage(child: CartPage()),
        ),
        GoRoute(
          path: AppRoutes.thixMarketCheckout,
          name: 'marketCheckout',
          pageBuilder: (context, state) => NoTransitionPage(child: CheckoutPage()),
        ),
        GoRoute(
          path: AppRoutes.thixMarketOrders,
          name: 'marketOrders',
          pageBuilder: (context, state) => NoTransitionPage(child: OrderHistoryPage()),
        ),

        // ==================== THIX SERVICES ROUTES ====================
        GoRoute(
          path: AppRoutes.reservation,
          name: 'reservation',
          pageBuilder: (context, state) => NoTransitionPage(child: ThixReservationPage()),
        ),
        GoRoute(
          path: AppRoutes.thixMoney,
          name: 'thixMoney',
          pageBuilder: (context, state) => NoTransitionPage(child: ThixMoneyPage()),
        ),
        GoRoute(
          path: AppRoutes.thixMedia,
          name: 'thixMedia',
          pageBuilder: (context, state) => NoTransitionPage(child: ThixMediaPage()),
        ),

        // ==================== JOB ROUTES ====================
        GoRoute(
          path: AppRoutes.jobs,
          name: 'jobs',
          pageBuilder: (context, state) => NoTransitionPage(child: JobsPage()),
        ),
        GoRoute(
          path: '/jobs/:jobId',
          name: 'jobDetails',
          pageBuilder: (context, state) {
            final jobId = state.pathParameters['jobId'] ?? '';
            final applied = (state.uri.queryParameters['applied'] ?? '').trim() == '1';
            return NoTransitionPage(child: JobDetailsPage(jobId: jobId, applied: applied));
          },
        ),
        GoRoute(
          path: '/jobs/:jobId/apply',
          name: 'jobApply',
          pageBuilder: (context, state) {
            final jobId = state.pathParameters['jobId'] ?? '';
            return NoTransitionPage(child: JobApplyPage(jobId: jobId));
          },
        ),
        GoRoute(
          path: AppRoutes.jobDashboard,
          name: 'jobDashboard',
          pageBuilder: (context, state) => NoTransitionPage(child: JobDashboardPage()),
        ),
        GoRoute(
          path: AppRoutes.recruiter,
          name: 'recruiter',
          pageBuilder: (context, state) => NoTransitionPage(child: RecruiterPortalPage()),
        ),

        // ==================== OPPORTUNITIES ROUTES ====================
        GoRoute(
          path: AppRoutes.opportunities,
          name: 'opportunities',
          pageBuilder: (context, state) => NoTransitionPage(child: OpportunitiesPage()),
        ),
        GoRoute(
          path: '/opportunities/:opportunityId',
          name: 'opportunityDetails',
          pageBuilder: (context, state) {
            final opportunityId = state.pathParameters['opportunityId'] ?? '';
            final applied = (state.uri.queryParameters['applied'] ?? '').trim() == '1';
            return NoTransitionPage(child: OpportunityDetailsPage(opportunityId: opportunityId, applied: applied));
          },
        ),
        GoRoute(
          path: '/opportunities/:opportunityId/apply',
          name: 'opportunityApply',
          pageBuilder: (context, state) {
            final opportunityId = state.pathParameters['opportunityId'] ?? '';
            return NoTransitionPage(child: OpportunityApplyPage(opportunityId: opportunityId));
          },
        ),

        // ==================== EVENTS ROUTES ====================
        GoRoute(
          path: AppRoutes.events,
          name: 'events',
          pageBuilder: (context, state) => NoTransitionPage(child: EventsPage()),
        ),
        GoRoute(
          path: '/events/:eventId',
          name: 'eventDetails',
          pageBuilder: (context, state) {
            final eventId = state.pathParameters['eventId'] ?? '';
            return NoTransitionPage(child: EventDetailsPage(eventId: eventId));
          },
        ),
        GoRoute(
          path: '/events/:eventId/register',
          name: 'eventRegister',
          pageBuilder: (context, state) {
            final eventId = state.pathParameters['eventId'] ?? '';
            return NoTransitionPage(child: EventRegisterPage(eventId: eventId));
          },
        ),
        GoRoute(
          path: '/events/:eventId/ticket/:registrationId',
          name: 'eventTicket',
          pageBuilder: (context, state) {
            final eventId = state.pathParameters['eventId'] ?? '';
            final registrationId = state.pathParameters['registrationId'] ?? '';
            return NoTransitionPage(child: EventTicketPage(eventId: eventId, registrationId: registrationId));
          },
        ),
        GoRoute(
          path: '/events/me',
          name: 'userEventsDashboard',
          pageBuilder: (context, state) => NoTransitionPage(child: UserEventDashboardPage()),
        ),

        // ==================== TRAINING ROUTES ====================
        GoRoute(
          path: AppRoutes.trainingHome,
          name: 'trainingHome',
          pageBuilder: (context, state) => NoTransitionPage(child: TrainingHomePage()),
        ),
        GoRoute(
          path: '/training/:trainingId',
          name: 'trainingDetails',
          pageBuilder: (context, state) {
            final trainingId = state.pathParameters['trainingId'] ?? '';
            return NoTransitionPage(child: TrainingDetailsPage(trainingId: trainingId));
          },
        ),
        GoRoute(
          path: AppRoutes.learningDashboard,
          name: 'learningDashboard',
          pageBuilder: (context, state) => NoTransitionPage(child: LearningDashboardPage()),
        ),
        GoRoute(
          path: '/lesson/:enrollmentId',
          name: 'lessonPlayer',
          pageBuilder: (context, state) {
            final enrollmentId = state.pathParameters['enrollmentId'] ?? '';
            return NoTransitionPage(child: LessonPlayerPage(enrollmentId: enrollmentId));
          },
        ),

        // ==================== EDUCATION ROUTE ====================
        GoRoute(
          path: AppRoutes.education,
          name: 'education',
          pageBuilder: (context, state) => NoTransitionPage(child: EducationPage()),
        ),

        // ==================== ADMIN ROUTES ====================
        GoRoute(
          path: '${AppRoutes.admin}/:module',
          name: 'admin',
          pageBuilder: (context, state) {
            final module = AdminModuleX.fromSlug(state.pathParameters['module']);
            return NoTransitionPage(child: AdminPage(module: module));
          },
        ),
        GoRoute(
          path: AppRoutes.admin,
          name: 'adminRoot',
          redirect: (_, __) => '${AppRoutes.admin}/${AdminModule.overview.slug}',
        ),
        GoRoute(
          path: AppRoutes.adminMedia,
          name: 'adminMedia',
          pageBuilder: (context, state) => NoTransitionPage(child: AdminMediaPage()),
        ),
      ],
    );
  }
}

extension GoRouterBackHelpers on BuildContext {
  void popOrGo(String fallbackLocation) {
    final router = GoRouter.of(this);
    if (router.canPop()) {
      pop();
      return;
    }
    go(fallbackLocation);
  }
}
