// lib/presentation/thix_money/widgets/bottom_nav_bar.dart
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      elevation: 0,
      backgroundColor: Colors.white,
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      indicatorColor: const Color(0xFFD4AF37).withOpacity(0.2),
      height: 55,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined, size: 20), label: 'Accueil'),
        NavigationDestination(icon: Icon(Icons.receipt_long_outlined, size: 20), label: 'Transactions'),
        NavigationDestination(icon: Icon(Icons.qr_code_scanner, size: 20), label: 'Scanner'),
        NavigationDestination(icon: Icon(Icons.grid_view_outlined, size: 20), label: 'Services'),
        NavigationDestination(icon: Icon(Icons.person_outline, size: 20), label: 'Profil'),
      ],
    );
  }
}
