// lib/presentation/thix_reservation/widgets/bottom_nav_bar.dart
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
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 5,
      elevation: 8,
      child: SizedBox(
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, "Accueil", currentIndex == 0, 0),
            _buildNavItem(Icons.explore_outlined, "Explorer", currentIndex == 1, 1),
            const SizedBox(width: 35),
            _buildNavItem(Icons.event_note, "Mes rés.", currentIndex == 2, 2),
            _buildNavItem(Icons.person_outline, "Profil", currentIndex == 3, 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, int index) {
    return InkWell(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFF1A73E8) : Colors.grey,
            size: 18,
          ),
          Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFF1A73E8) : Colors.grey,
              fontSize: 8.5,
            ),
          ),
        ],
      ),
    );
  }
}
