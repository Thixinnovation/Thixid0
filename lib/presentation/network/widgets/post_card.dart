import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:thix_id/models/network_post.dart';
import 'report_dialog.dart';

class PostCard extends StatelessWidget {
  final NetworkPost post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback? onTap;
  final VoidCallback? onShare;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    this.onTap,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => context.push('/network/profile/${post.userId}'),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: post.userAvatar != null
                        ? NetworkImage(post.userAvatar!)
                        : null,
                    child: post.userAvatar == null
                        ? const Icon(Icons.person, color: Colors.grey)
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.push('/network/profile/${post.userId}'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          post.userTitle,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'report') {
                      showDialog(
                        context: context,
                        builder: (_) => ReportDialog(
                          contentType: 'post',
                          contentId: post.id,
                          reportedUserId: post.userId,
                          postId: post.id,
                        ),
                      );
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          Icon(Icons.flag, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Signaler'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              post.content,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            if (post.images.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: post.images.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        post.images[index],
                        width: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 150,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image_not_supported),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                _buildActionButton(
                  icon: post.isLikedByCurrentUser
                      ? Icons.favorite
                      : Icons.favorite_border,
                  label: '${post.likes}',
                  color: post.isLikedByCurrentUser ? Colors.red : null,
                  onTap: onLike,
                ),
                const SizedBox(width: 16),
                _buildActionButton(
                  icon: Icons.comment_outlined,
                  label: '${post.comments}',
                  onTap: onComment,
                ),
                const SizedBox(width: 16),
                _buildActionButton(
                  icon: Icons.share_outlined,
                  label: '${post.shares}',
                  onTap: onShare ?? () {},
                ),
                const Spacer(),
                _buildActionButton(
                  icon: Icons.bookmark_border_outlined,
                  label: '',
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color? color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color ?? Colors.grey.shade600),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }
}
