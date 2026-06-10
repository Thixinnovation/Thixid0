// lib/presentation/thix_money/widgets/contact_tile.dart
import 'package:flutter/material.dart';

class ContactTile extends StatelessWidget {
  final String name;
  final String phone;
  final String? avatar;
  final VoidCallback? onTap;

  const ContactTile({
    super.key,
    required this.name,
    required this.phone,
    this.avatar,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFD4AF37).withOpacity(0.1),
              child: avatar != null
                  ? Text(avatar!, style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold))
                  : const Icon(Icons.person, color: Color(0xFFD4AF37)),
            ),
            const SizedBox(height: 4),
            Text(
              name,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
