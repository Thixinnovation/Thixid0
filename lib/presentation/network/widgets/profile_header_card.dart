import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thix_id/auth/auth_controller.dart';

class ProfileHeaderCard extends StatelessWidget {
  final VoidCallback? onEditPressed;
  final VoidCallback? onPhotoPressed;
  final VoidCallback? onVideoPressed;
  final VoidCallback? onDocumentPressed;
  final VoidCallback? onEventPressed;
  final VoidCallback? onJobPressed;
  final VoidCallback? onStoryPressed;  // ← AJOUTÉ

  const ProfileHeaderCard({
    super.key,
    this.onEditPressed,
    this.onPhotoPressed,
    this.onVideoPressed,
    this.onDocumentPressed,
    this.onEventPressed,
    this.onJobPressed,
    this.onStoryPressed,  // ← AJOUTÉ
  });

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
              Stack(
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
                  if (onEditPressed != null)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: onEditPressed,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFD4AF37),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 14,
                            color: Color(0xFF0B1B3D),
                          ),
                        ),
                      ),
                    ),
                ],
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
              _buildShareButton(
                Icons.photo_camera,
                'Photo',
                onPressed: onPhotoPressed,
              ),
              const SizedBox(width: 8),
              _buildShareButton(
                Icons.videocam,
                'Vidéo',
                onPressed: onVideoPressed,
              ),
              const SizedBox(width: 8),
              _buildShareButton(
                Icons.insert_drive_file,
                'Document',
                onPressed: onDocumentPressed,
              ),
              const SizedBox(width: 8),
              _buildShareButton(
                Icons.event,
                'Événement',
                onPressed: onEventPressed,
              ),
              const SizedBox(width: 8),
              _buildShareButton(
                Icons.work,
                'Offre',
                onPressed: onJobPressed,
              ),
              const SizedBox(width: 8),
              _buildShareButton(
                Icons.auto_awesome,
                'Story',
                onPressed: onStoryPressed,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton(IconData icon, String label, {VoidCallback? onPressed}) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onPressed,
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
