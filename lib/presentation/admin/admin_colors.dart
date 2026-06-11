// lib/presentation/admin/admin_colors.dart
import 'package:flutter/material.dart';
import 'admin_colors.dart';
/// Couleurs unifiées pour l'espace Administrateur THIX
class AdminColors {
  // ============================================================
  // COULEURS PRINCIPALES - Thème Cyber/Glassmorphism
  // ============================================================
  
  // Fond principal
  static const Color black = Color(0xFF0A0E1A);      // Noir profond
  static const Color background = Color(0xFF0F1420);  // Fond légèrement plus clair
  
  // Panel et surfaces
  static const Color panel = Color(0xCC1A1F2E);       // Panel semi-transparent
  static const Color panelHi = Color(0xE6222A3E);     // Panel surbrillance
  static const Color stroke = Color(0x33FFFFFF);      // Bordure transparente
  
  // Texte
  static const Color text = Color(0xFFF0F3FA);        // Texte principal
  static const Color textDim = Color(0xFF8E98B0);     // Texte secondaire
  static const Color textLight = Colors.white;        // Texte sur fond sombre
  
  // ============================================================
  // COULEURS NÉON/ACCENT
  // ============================================================
  static const Color neonCyan = Color(0xFF00E5FF);     // Cyan néon
  static const Color electricBlue = Color(0xFF2962FF); // Bleu électrique
  static const Color neonViolet = Color(0xFFB388FF);   // Violet néon
  static const Color neonPink = Color(0xFFFF4081);     // Rose néon
  static const Color neonGreen = Color(0xFF00E676);    // Vert néon
  static const Color neonOrange = Color(0xFFFF9100);   // Orange néon
  
  // ============================================================
  // COULEURS THIX (Doré)
  // ============================================================
  static const Color thixGold = Color(0xFFD4AF37);     // Doré THIX
  static const Color thixGoldDark = Color(0xFFB8941E); // Doré foncé
  static const Color thixGoldLight = Color(0xFFE8C96C); // Doré clair
  
  // ============================================================
  // COULEURS DE STATUT
  // ============================================================
  static const Color success = Color(0xFF00E676);      // Vert succès
  static const Color warning = Color(0xFFFF9100);      // Orange warning
  static const Color error = Color(0xFFFF1744);        // Rouge erreur
  static const Color info = Color(0xFF00B0FF);         // Bleu info
  
  // ============================================================
  // DÉGRADÉS
  // ============================================================
  static LinearGradient primaryGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [electricBlue, neonCyan],
    );
  }
  
  static LinearGradient secondaryGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [neonViolet, neonPink],
    );
  }
  
  static LinearGradient thixGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [thixGold, thixGoldLight],
    );
  }
  
  static LinearGradient glowViolet() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [neonViolet, electricBlue],
    );
  }
  
  static LinearGradient successGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [success, neonGreen],
    );
  }
  
  static LinearGradient warningGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [warning, neonOrange],
    );
  }
  
  static LinearGradient errorGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [error, neonPink],
    );
  }
}

/// Gestionnaire de couleurs par module
class AdminModuleColors {
  static Color getColor(AdminModule module) {
    switch (module) {
      case AdminModule.overview:
        return AdminColors.electricBlue;
      case AdminModule.accessRequests:
        return AdminColors.warning;
      case AdminModule.users:
        return AdminColors.info;
      case AdminModule.verification:
        return AdminColors.success;
      case AdminModule.events:
        return AdminColors.neonCyan;
      case AdminModule.trainings:
        return AdminColors.thixGold;
      case AdminModule.uid:
        return AdminColors.electricBlue;
      case AdminModule.jobs:
        return AdminColors.success;
      case AdminModule.news:
        return AdminColors.thixGold;
      case AdminModule.chat:
        return AdminColors.neonCyan;
      case AdminModule.sos:
        return AdminColors.error;
      case AdminModule.institutions:
        return AdminColors.electricBlue;
      case AdminModule.analytics:
        return AdminColors.info;
      case AdminModule.cybersecurity:
        return AdminColors.error;
      case AdminModule.api:
        return AdminColors.electricBlue;
      case AdminModule.settings:
        return AdminColors.warning;
      case AdminModule.audit:
        return AdminColors.textDim;
      case AdminModule.media:
        return AdminColors.neonPink;
    }
  }
  
  static IconData getIcon(AdminModule module) {
    switch (module) {
      case AdminModule.overview:
        return Icons.dashboard_rounded;
      case AdminModule.accessRequests:
        return Icons.admin_panel_settings_rounded;
      case AdminModule.users:
        return Icons.people_alt_rounded;
      case AdminModule.verification:
        return Icons.verified_user_rounded;
      case AdminModule.events:
        return Icons.event_available_rounded;
      case AdminModule.trainings:
        return Icons.school_rounded;
      case AdminModule.uid:
        return Icons.badge_rounded;
      case AdminModule.jobs:
        return Icons.work_rounded;
      case AdminModule.news:
        return Icons.campaign_rounded;
      case AdminModule.chat:
        return Icons.forum_rounded;
      case AdminModule.sos:
        return Icons.sos_rounded;
      case AdminModule.institutions:
        return Icons.account_balance_rounded;
      case AdminModule.analytics:
        return Icons.query_stats_rounded;
      case AdminModule.cybersecurity:
        return Icons.shield_rounded;
      case AdminModule.api:
        return Icons.api_rounded;
      case AdminModule.settings:
        return Icons.tune_rounded;
      case AdminModule.audit:
        return Icons.manage_history_rounded;
      case AdminModule.media:
        return Icons.movie_rounded;
    }
  }
  
  static String getLabel(AdminModule module) {
    switch (module) {
      case AdminModule.overview:
        return 'Global Overview';
      case AdminModule.accessRequests:
        return 'Account Access Requests';
      case AdminModule.users:
        return 'User Management';
      case AdminModule.verification:
        return 'Verification Center';
      case AdminModule.events:
        return 'Events';
      case AdminModule.trainings:
        return 'Trainings';
      case AdminModule.uid:
        return 'THIX UID';
      case AdminModule.jobs:
        return 'Jobs & Opportunities';
      case AdminModule.news:
        return 'Info / News';
      case AdminModule.media:
        return 'THIX Media';
      case AdminModule.chat:
        return 'THIX Chat Admin';
      case AdminModule.sos:
        return 'SOS Emergency';
      case AdminModule.institutions:
        return 'Institutions';
      case AdminModule.analytics:
        return 'Analytics';
      case AdminModule.cybersecurity:
        return 'Cybersecurity';
      case AdminModule.api:
        return 'API & Integrations';
      case AdminModule.settings:
        return 'Settings';
      case AdminModule.audit:
        return 'Audit & Activity';
    }
  }
}

// Définition temporaire de AdminModule pour éviter les erreurs
// Ceci devrait déjà être défini dans admin_page.dart
enum AdminModule {
  overview,
  accessRequests,
  users,
  verification,
  events,
  trainings,
  uid,
  jobs,
  news,
  chat,
  sos,
  institutions,
  analytics,
  cybersecurity,
  api,
  settings,
  audit,
  media,
}
