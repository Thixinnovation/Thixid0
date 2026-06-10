import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'pages/reservation_vols.dart';
import 'pages/reservation_hotels.dart';
import 'pages/reservation_bus.dart';
import 'pages/reservation_taxi.dart';
import 'pages/reservation_colis.dart';
import 'pages/reservation_restaurant.dart';
import 'pages/reservation_event.dart';
import 'pages/mes_reservations.dart';
import 'pages/favoris.dart';
import 'pages/profil.dart';

class ThixReservationPage extends StatelessWidget {
  const ThixReservationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildPromoBanner(isSmallScreen, context),
                    const SizedBox(height: 12),
                    _buildServicesGrid(context),
                    const SizedBox(height: 14),
                    _buildSectionHeader("Mes réservations", context),
                    const SizedBox(height: 6),
                    _buildReservationsStatus(context),
                    const SizedBox(height: 14),
                    _buildSectionHeader("Offres spéciales pour vous", context),
                    const SizedBox(height: 6),
                    _buildSpecialOffers(isSmallScreen, context),
                    const SizedBox(height: 14),
                    _buildReferralBanner(context),
                    const SizedBox(height: 14),
                    _buildSectionHeader("Restaurants à proximité", context),
                    const SizedBox(height: 6),
                    _buildRestaurantsList(isSmallScreen, context),
                    const SizedBox(height: 14),
                    _buildSectionHeader("Annonces", context),
                    const SizedBox(height: 6),
                    _buildAnnoncesList(isSmallScreen, context),
                    const SizedBox(height: 20),
                    _buildReassuranceBadges(),
                    const SizedBox(height: 75),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
      floatingActionButton: _buildMiddleButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // ==================== HEADER AVEC NAVIGATION ====================
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text("R", style: TextStyle(color: Color(0xFF1A73E8), fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Text("THIX ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text("RÉSERVATION", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1A73E8))),
                    ],
                  ),
                  const Text("Réservez tout, partout, en toute simplicité.", style: TextStyle(fontSize: 9, color: Colors.grey)),
                ],
              )
            ],
          ),
          Row(
            children: [
              Stack(
                children: [
                  IconButton(
                    onPressed: () => context.push('/reservation/notifications'),
                    icon: const Icon(Icons.notifications_none, color: Colors.black54, size: 24),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: const Text("3", style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
              GestureDetector(
                onTap: () => context.push('/reservation/profil'),
                child: const CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFFF1F3F4),
                  child: Icon(Icons.person_outline, color: Colors.black54, size: 20),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  // ==================== PROMO BANNER AVEC NAVIGATION ====================
  Widget _buildPromoBanner(bool isSmallScreen, BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => context.push('/reservation/vols'),
          child: Container(
            height: isSmallScreen ? 110 : 125,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, const Color(0xFFE8F0FE)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.flash_on, color: Colors.orange, size: 12),
                          Text(" PROMO FLASH", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 9)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text("Jusqu'à -40%", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                      Text("sur vos réservations de bus & vols", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.black.withOpacity(0.8))),
                      const Text("Valable jusqu'au 30 Juin 2025", style: TextStyle(fontSize: 8, color: Colors.grey)),
                      const SizedBox(height: 6),
                      ElevatedButton(
                        onPressed: () => context.push('/reservation/vols'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A73E8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                          minimumSize: const Size(75, 24),
                        ),
                        child: const Text("Profiter maintenant", style: TextStyle(fontSize: 9, color: Colors.white)),
                      )
                    ],
                  ),
                ),
                Positioned(
                  right: -10,
                  bottom: 10,
                  child: Icon(Icons.directions_bus_filled, size: isSmallScreen ? 80 : 100, color: const Color(0xFF1A73E8).withOpacity(0.9)),
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 12, height: 5, decoration: BoxDecoration(color: const Color(0xFF1A73E8), borderRadius: BorderRadius.circular(4))),
            const SizedBox(width: 4),
            ...List.generate(3, (index) => Container(margin: const EdgeInsets.symmetric(horizontal: 2), width: 5, height: 5, decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle))),
          ],
        )
      ],
    );
  }

  // ==================== SERVICES GRID AVEC NAVIGATION ====================
  Widget _buildServicesGrid(BuildContext context) {
    final services = [
      {'icon': Icons.directions_bus, 'label': 'Bus', 'color': const Color(0xFF1A73E8), 'route': '/reservation/bus'},
      {'icon': Icons.flight, 'label': 'Vol', 'color': Colors.indigo, 'route': '/reservation/vols'},
      {'icon': Icons.hotel, 'label': 'Hôtel', 'color': Colors.orange, 'route': '/reservation/hotels'},
      {'icon': Icons.local_taxi, 'label': 'Taxi', 'color': Colors.amber, 'route': '/reservation/taxi'},
      {'icon': Icons.delivery_dining, 'label': 'Livraison', 'color': Colors.green, 'route': '/reservation/colis'},
      {'icon': Icons.restaurant, 'label': 'Restaurant', 'color': Colors.red, 'route': '/reservation/restaurant'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: services.map((service) {
        return GestureDetector(
          onTap: () => context.push(service['route'] as String),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: Icon(service['icon'] as IconData, color: service['color'] as Color, size: 22),
              ),
              const SizedBox(height: 4),
              Text(service['label'] as String, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ==================== SECTION HEADER AVEC NAVIGATION ====================
  Widget _buildSectionHeader(String title, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black.withOpacity(0.8))),
        GestureDetector(
          onTap: () {
            if (title == "Mes réservations") {
              context.push('/reservation/mes-reservations');
            } else if (title == "Offres spéciales pour vous") {
              context.push('/reservation/vols');
            } else if (title == "Restaurants à proximité") {
              context.push('/reservation/restaurant');
            } else if (title == "Annonces") {
              // Naviguer vers les annonces
            }
          },
          child: Row(
            children: const [
              Text("Voir tout", style: TextStyle(fontSize: 10, color: Colors.grey)),
              Icon(Icons.chevron_right, size: 12, color: Colors.grey),
            ],
          ),
        )
      ],
    );
  }

  // ==================== RÉSERVATIONS STATUS AVEC NAVIGATION ====================
  Widget _buildReservationsStatus(BuildContext context) {
    final status = [
      {'label': 'À venir', 'count': '3', 'color': Colors.blue, 'icon': Icons.business_center},
      {'label': 'En cours', 'count': '1', 'color': Colors.green, 'icon': Icons.timelapse},
      {'label': 'Terminées', 'count': '8', 'color': Colors.purple, 'icon': Icons.check_circle_outline},
      {'label': 'Annulées', 'count': '0', 'color': Colors.red, 'icon': Icons.cancel_outlined},
    ];

    return Row(
      children: status.map((item) {
        return Expanded(
          child: GestureDetector(
            onTap: () => context.push('/reservation/mes-reservations'),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(item['icon'] as IconData, color: item['color'] as Color, size: 14),
                      Text(item['count'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(item['label'] as String, style: const TextStyle(fontSize: 9, color: Colors.grey), maxLines: 1),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ==================== SPECIAL OFFERS AVEC NAVIGATION ====================
  Widget _buildSpecialOffers(bool isSmallScreen, BuildContext context) {
    final offers = [
      {'title': 'Hôtels', 'promo': '-30%', 'desc': 'Séjournez plus,\npayez moins', 'color': Colors.red.shade50, 'route': '/reservation/hotels'},
      {'title': 'Vols', 'promo': '-20%', 'desc': 'Sur tous les vols', 'color': Colors.blue.shade50, 'route': '/reservation/vols'},
      {'title': 'Bus', 'promo': '-15%', 'desc': 'Voyagez en toute\nconfiance', 'color': Colors.indigo.shade50, 'route': '/reservation/bus'},
      {'title': 'Livraison', 'promo': '-10%', 'desc': 'Envoi express', 'color': Colors.green.shade50, 'route': '/reservation/colis'},
    ];

    return SizedBox(
      height: isSmallScreen ? 70 : 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: offers.length,
        itemBuilder: (context, index) {
          final offer = offers[index];
          return GestureDetector(
            onTap: () => context.push(offer['route'] as String),
            child: Container(
              width: 105,
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: offer['color'] as Color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(offer['title'] as String, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black54)),
                  Text(offer['promo'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A73E8))),
                  const SizedBox(height: 1),
                  Text(offer['desc'] as String, style: const TextStyle(fontSize: 8, color: Colors.black54, height: 1.1)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ==================== REFERRAL BANNER AVEC NAVIGATION ====================
  Widget _buildReferralBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/reservation/parrainage'),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F3FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.card_giftcard, color: Colors.purple, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Parrainez & Gagnez !", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.purple)),
                  Text("Invitez vos proches et gagnez jusqu'à 10.000 FC par parrainage.", style: TextStyle(fontSize: 8.5, color: Colors.black54)),
                ],
              ),
            ),
            Row(
              children: List.generate(3, (index) => const Align(
                widthFactor: 0.6,
                child: CircleAvatar(radius: 9, backgroundColor: Colors.grey, child: Icon(Icons.person, size: 10, color: Colors.white)),
              )),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 14)
          ],
        ),
      ),
    );
  }

  // ==================== RESTAURANTS LIST AVEC NAVIGATION ====================
  Widget _buildRestaurantsList(bool isSmallScreen, BuildContext context) {
    final restaurants = [
      {'name': "Le Goût d'Ici", 'type': 'Africaine', 'time': '20-30 min', 'price': '\$\$', 'rating': '4.6'},
      {'name': 'Fast & Good', 'type': 'Fast Food', 'time': '15-25 min', 'price': '\$\$', 'rating': '4.8'},
      {'name': 'Pizza Time', 'type': 'Italienne', 'time': '20-30 min', 'price': '\$\$', 'rating': '4.5'},
      {'name': 'Sushi House', 'type': 'Japonaise', 'time': '25-35 min', 'price': '\$\$', 'rating': '4.7'},
    ];

    return SizedBox(
      height: isSmallScreen ? 115 : 125,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: restaurants.length,
        itemBuilder: (context, index) {
          final restau = restaurants[index];
          return GestureDetector(
            onTap: () => context.push('/reservation/restaurant'),
            child: Container(
              width: 115,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 4, right: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(4)),
                              child: Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 8),
                                  Text(" ${restau['rating']}", style: const TextStyle(color: Colors.white, fontSize: 8)),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(restau['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 9), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(restau['type']!, style: const TextStyle(fontSize: 7.5, color: Colors.grey)),
                        const SizedBox(height: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(restau['time']!, style: const TextStyle(fontSize: 7.5, color: Colors.black54)),
                            const Icon(Icons.favorite_border, size: 10, color: Colors.black54),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ==================== ANNONCES LIST AVEC NAVIGATION ====================
  Widget _buildAnnoncesList(bool isSmallScreen, BuildContext context) {
    final annonces = [
      {'tag': 'À VENDRE', 'tagColor': Colors.green, 'title': 'Toyota RAV4 2021', 'price': '25.000.000 FC'},
      {'tag': 'À LOUER', 'tagColor': Colors.red, 'title': 'Appartement 3 pièces', 'price': '600.000 FC / mois'},
      {'tag': 'SERVICE', 'tagColor': Colors.teal, 'title': 'Ménage à domicile', 'price': 'À partir de 10.000 FC'},
    ];

    return SizedBox(
      height: isSmallScreen ? 110 : 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: annonces.length,
        itemBuilder: (context, index) {
          final item = annonces[index];
          return GestureDetector(
            onTap: () => context.push('/reservation/annonce/${item['title']}'),
            child: Container(
              width: 140,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 4, left: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(color: item['tagColor'] as Color, borderRadius: BorderRadius.circular(4)),
                              child: Text(item['tag'] as String, style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold)),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 9), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 1),
                        Text(item['price'] as String, style: const TextStyle(fontSize: 8.5, color: Color(0xFF1A73E8), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ==================== REASSURANCE BADGES ====================
  Widget _buildReassuranceBadges() {
    final badges = [
      {'icon': Icons.verified_user_outlined, 'text': 'Paiement sécurisé'},
      {'icon': Icons.support_agent, 'text': 'Support 24/7'},
      {'icon': Icons.workspace_premium_outlined, 'text': 'Meilleurs prix'},
      {'icon': Icons.cancel_schedule_send_outlined, 'text': 'Annulation facile'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: badges.map((badge) {
        return Column(
          children: [
            Icon(badge['icon'] as IconData, size: 14, color: const Color(0xFF1A73E8)),
            const SizedBox(height: 2),
            Text(badge['text'] as String, style: const TextStyle(fontSize: 7.5, color: Colors.black54)),
          ],
        );
      }).toList(),
    );
  }

  // ==================== BOTTOM NAVIGATION BAR ====================
  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 5.0,
      elevation: 8,
      child: SizedBox(
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(Icons.home, "Accueil", true, context, '/reservation'),
            _buildBottomNavItem(Icons.explore_outlined, "Explorer", false, context, '/reservation/explorer'),
            const SizedBox(width: 35),
            _buildBottomNavItem(Icons.event_note, "Mes rés.", false, context, '/reservation/mes-reservations'),
            _buildBottomNavItem(Icons.person_outline, "Profil", false, context, '/reservation/profil'),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, bool isActive, BuildContext context, String route) {
    return InkWell(
      onTap: () => context.go(route),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? const Color(0xFF1A73E8) : Colors.grey, size: 18),
          Text(label, style: TextStyle(color: isActive ? const Color(0xFF1A73E8) : Colors.grey, fontSize: 8.5)),
        ],
      ),
    );
  }

  // ==================== FLOATING BUTTON ====================
  Widget _buildMiddleButton(BuildContext context) {
    return Container(
      height: 54,
      width: 54,
      margin: const EdgeInsets.only(top: 10),
      child: FloatingActionButton(
        backgroundColor: const Color(0xFF1A73E8),
        elevation: 3,
        shape: const CircleBorder(),
        onPressed: () => context.push('/reservation/vols'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.calendar_month, color: Colors.white, size: 18),
            SizedBox(height: 1),
            Text("Réserver", style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
