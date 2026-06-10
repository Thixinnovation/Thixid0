// lib/presentation/thix_reservation/pages/profil.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Mon profil'),
        backgroundColor: const Color(0xFF0B1B3D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildMenuItems(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150'),
          ),
          const SizedBox(height: 12),
          const Text('Michel K.', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Text('michel.k@email.com', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStat('12', 'Réservations'),
              _buildStat('8', 'Trajets'),
              _buildStat('245', 'Points'),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: const Color(0xFF0B1B3D),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text('Modifier le profil'),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    final menuItems = [
      {'icon': Icons.history, 'title': 'Mes réservations', 'subtitle': 'Voir l\'historique de vos réservations'},
      {'icon': Icons.favorite, 'title': 'Mes favoris', 'subtitle': 'Destinations, chauffeurs, adresses'},
      {'icon': Icons.credit_card, 'title': 'Moyens de paiement', 'subtitle': 'Cartes, Mobile Money'},
      {'icon': Icons.notifications, 'title': 'Notifications', 'subtitle': 'Gérer vos alertes'},
      {'icon': Icons.security, 'title': 'Sécurité', 'subtitle': 'Mot de passe, biométrie'},
      {'icon': Icons.help_outline, 'title': 'Aide & Support', 'subtitle': 'FAQ, contact, assistance'},
    ];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          ...menuItems.map((item) => Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item['icon'] as IconData, color: const Color(0xFFD4AF37)),
                ),
                title: Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(item['subtitle'] as String, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {
                  if (item['title'] == 'Mes réservations') {
                    context.push('/reservation/mes-reservations');
                  } else if (item['title'] == 'Mes favoris') {
                    context.push('/reservation/favoris');
                  }
                },
              ),
              if (item != menuItems.last) const Divider(height: 1, indent: 60),
            ],
          )),
        ],
      ),
    );
  }
}
