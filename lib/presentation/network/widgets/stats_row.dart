import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StatsRow extends StatelessWidget {
  final VoidCallback? onConnexionsTap;
  final VoidCallback? onPublicationsTap;
  final VoidCallback? onCommunitiesTap;
  final VoidCallback? onMessagesTap;

  const StatsRow({
    super.key,
    this.onConnexionsTap,
    this.onPublicationsTap,
    this.onCommunitiesTap,
    this.onMessagesTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildStatCard('1245', 'Connexions', onConnexionsTap),
        const SizedBox(width: 12),
        _buildStatCard('125', 'Publications', onPublicationsTap),
        const SizedBox(width: 12),
        _buildStatCard('12', 'Communautés', onCommunitiesTap),
        const SizedBox(width: 12),
        _buildStatCard('34', 'Messages', onMessagesTap),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, VoidCallback? onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B1B3D),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
