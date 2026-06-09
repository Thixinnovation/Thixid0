// lib/presentation/thix_money/widgets/money_header.dart
import 'package:flutter/material.dart';

class MoneyHeader extends StatelessWidget {
  final VoidCallback? onMenuTap;
  final VoidCallback? onNotificationsTap;
  final String userName;
  final String userAvatar;

  const MoneyHeader({
    super.key,
    this.onMenuTap,
    this.onNotificationsTap,
    this.userName = 'Jean Dupont',
    this.userAvatar = 'https://i.pravatar.cc/150',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Menu button
        GestureDetector(
          onTap: onMenuTap,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.menu, color: Color(0xFF0B1B3D)),
          ),
        ),
        const SizedBox(width: 12),
        
        // Title
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'THIX MONEY',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B1B3D),
                ),
              ),
              Text(
                'Votre argent, votre liberté',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
        
        // Notifications button
        GestureDetector(
          onTap: onNotificationsTap,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Stack(
              children: [
                const Icon(Icons.notifications_none, color: Color(0xFF0B1B3D)),
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        
        // Avatar
        CircleAvatar(
          radius: 22,
          backgroundImage: NetworkImage(userAvatar),
        ),
      ],
    );
  }
}
