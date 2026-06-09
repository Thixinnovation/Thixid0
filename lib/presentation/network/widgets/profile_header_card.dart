import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thix_id/auth/auth_controller.dart';

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthController>(context);
    final user = auth.currentUser;
    final userName = user?.displayName ?? 'Utilisateur';
    final userTitle = user?.profession ?? 'Partagez votre expertise';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B1B3D), Color(0xFF1A2D56)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white24,
                backgroundImage: user?.photoUrl != null
                    ? NetworkImage(user!.photoUrl!)
                    : null,
                child: user?.photoUrl == null
                    ? const Icon(Icons.person, size: 32, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userTitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Que souhaitez-vous partager aujourd\'hui ?',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildShareButton(Icons.photo_camera, 'Photo'),
              const SizedBox(width: 8),
              _buildShareButton(Icons.videocam, 'Vidéo'),
              const SizedBox(width: 8),
              _buildShareButton(Icons.insert_drive_file, 'Document'),
              const SizedBox(width: 8),
              _buildShareButton(Icons.event, 'Événement'),
              const SizedBox(width: 8),
              _buildShareButton(Icons.work, 'Offre'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton(IconData icon, String label) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(icon, size: 16, color: const Color(0xFFD4AF37)),
        label: Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.white),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFD4AF37)),
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }
}
