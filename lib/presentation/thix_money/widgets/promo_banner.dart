// lib/presentation/thix_money/widgets/promo_banner.dart
import 'package:flutter/material.dart';

class PromoBanner extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final String? buttonText;
  final VoidCallback? onTap;
  final String? imageUrl;

  const PromoBanner({
    super.key,
    this.title,
    this.subtitle,
    this.buttonText,
    this.onTap,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0E3A8A), Color(0xFF1A4A9A)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title ?? 'Envoyez de l\'argent',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle ?? 'dans plus de 120 pays',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                if (buttonText != null) ...[
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: const Color(0xFF0B1B3D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(buttonText!),
                  ),
                ],
              ],
            ),
          ),
          if (imageUrl != null)
            Image.network(imageUrl!, height: 60, errorBuilder: (_, __, ___) => const Icon(Icons.public, color: Colors.white, size: 48)),
        ],
      ),
    );
  }
}
