// lib/presentation/thix_reservation/pages/reservation_home.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/reservation_header.dart';
import '../widgets/promo_banner.dart';
import '../widgets/services_grid.dart';
import '../widgets/section_header.dart';
import '../widgets/reservation_status_card.dart';
import '../widgets/special_offer_card.dart';
import '../widgets/referral_banner.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/annonce_card.dart';
import '../widgets/reassurance_badges.dart';

class ReservationHomePage extends StatelessWidget {
  const ReservationHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ReservationHeader(),
              const SizedBox(height: 8),
              PromoBanner(isSmallScreen: isSmallScreen),
              const SizedBox(height: 12),
              const ServicesGrid(),
              const SizedBox(height: 14),
              const SectionHeader(title: 'Mes réservations', showSeeAll: true),
              const SizedBox(height: 6),
              const ReservationStatusCard(),
              const SizedBox(height: 14),
              const SectionHeader(title: 'Offres spéciales pour vous', showSeeAll: true),
              const SizedBox(height: 6),
              SpecialOfferCard(isSmallScreen: isSmallScreen),
              const SizedBox(height: 14),
              const ReferralBanner(),
              const SizedBox(height: 14),
              const SectionHeader(title: 'Restaurants à proximité', showSeeAll: true),
              const SizedBox(height: 6),
              RestaurantCard(isSmallScreen: isSmallScreen),
              const SizedBox(height: 14),
              const SectionHeader(title: 'Annonces', showSeeAll: true),
              const SizedBox(height: 6),
              AnnonceCard(isSmallScreen: isSmallScreen),
              const SizedBox(height: 20),
              const ReassuranceBadges(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
