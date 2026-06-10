// lib/presentation/thix_reservation/widgets/reservation_header.dart
import 'package:flutter/material.dart';

class ReservationHeader extends StatelessWidget {
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onProfileTap;

  const ReservationHeader({
    super.key,
    this.onNotificationsTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "R",
                  style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Text(
                        "THIX ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF0B1B3D),
                        ),
                      ),
                      Text(
                        "RÉSERVATION",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFFD4AF37),
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    "Réservez tout, partout, en toute simplicité.",
                    style: TextStyle(fontSize: 9, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Stack(
                children: [
                  IconButton(
                    onPressed: onNotificationsTap,
                    icon: const Icon(Icons.notifications_none, size: 24),
                    color: Colors.black54,
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        "3",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onProfileTap,
                child: const CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFFF1F3F4),
                  child: Icon(
                    Icons.person_outline,
                    color: Colors.black54,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
