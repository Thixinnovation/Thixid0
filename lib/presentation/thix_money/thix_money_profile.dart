// lib/presentation/thix_money/thix_money_profile.dart
import 'package:flutter/material.dart';
import 'package:thix_id/presentation/thix_money/widgets/bank_account_tile.dart';
import 'package:thix_id/presentation/thix_money/thix_money_cards.dart';
import 'package:thix_id/presentation/thix_money/thix_money_notifications.dart';
import 'package:thix_id/presentation/thix_money/thix_money_history.dart';
import 'package:thix_id/services/wallet_service.dart';

class ThixMoneyProfile extends StatefulWidget {
  const ThixMoneyProfile({super.key});

  @override
  State<ThixMoneyProfile> createState() => _ThixMoneyProfileState();
}

class _ThixMoneyProfileState extends State<ThixMoneyProfile> {
  final WalletService _walletService = WalletService();
  String _userName = 'Jean Dupont';
  String _userEmail = 'jean.dupont@email.com';
  String _userPhone = '+237 6XX XXX XXX';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Mon profil'),
        backgroundColor: const Color(0xFF0B1B3D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header avec photo
            Container(
              width: double.infinity,
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
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage('https://i.pravatar.cc/150'),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFD4AF37),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _userName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(_userEmail, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(_userPhone, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: const Color(0xFF0B1B3D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Modifier le profil'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Menu items
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.credit_card,
                    title: 'Mes cartes',
                    subtitle: 'Gérer mes cartes virtuelles',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ThixMoneyCards()),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 60),
                  _buildMenuItem(
                    icon: Icons.account_balance,
                    title: 'Comptes bancaires',
                    subtitle: 'Ajouter ou retirer un compte',
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 60),
                  _buildMenuItem(
                    icon: Icons.history,
                    title: 'Historique complet',
                    subtitle: 'Voir toutes vos transactions',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ThixMoneyHistory()),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 60),
                  _buildMenuItem(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    subtitle: 'Gérer vos alertes',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ThixMoneyNotifications()),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 60),
                  _buildMenuItem(
                    icon: Icons.security,
                    title: 'Sécurité',
                    subtitle: 'Mot de passe, biométrie',
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 60),
                  _buildMenuItem(
                    icon: Icons.help_outline,
                    title: 'Aide & Support',
                    subtitle: 'FAQ, contact, assistance',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Déconnexion
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
                onTap: () {
                  _showLogoutDialog();
                },
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFD4AF37).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFFD4AF37)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Déconnecter'),
          ),
        ],
      ),
    );
  }
}
