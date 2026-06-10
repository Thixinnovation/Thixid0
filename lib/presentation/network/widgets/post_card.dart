// lib/presentation/network/widgets/post_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thix_id/models/network_post.dart';
import 'package:thix_id/services/network_service.dart';
import 'package:thix_id/auth/auth_controller.dart';
import 'package:provider/provider.dart';

class PostCard extends StatefulWidget {
  final NetworkPost post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onTap;
  final VoidCallback onShare;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onTap,
    required this.onShare,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late NetworkService _networkService;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _networkService = NetworkService();
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 7) {
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } else if (difference.inDays > 0) {
      return 'il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'à l\'instant';
    }
  }

  Future<void> _deletePost() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la publication'),
        content: const Text('Voulez-vous vraiment supprimer cette publication ? Cette action est irréversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Supprimer')),
        ],
      ),
    );
    
    if (confirm == true) {
      await _networkService.deletePost(widget.post.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Publication supprimée'), backgroundColor: Colors.green),
        );
        widget.onLike(); // Refresh
      }
    }
  }

  Future<void> _hidePost() async {
    await _networkService.hidePost(widget.post.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Publication masquée'), backgroundColor: Colors.orange),
      );
      widget.onLike(); // Refresh
    }
  }

  Future<void> _reportPost() async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Signaler la publication'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(onTap: () => Navigator.pop(context, 'Spam'), title: const Text('Spam'), leading: const Icon(Icons.warning)),
            ListTile(onTap: () => Navigator.pop(context, 'Contenu inapproprié'), title: const Text('Contenu inapproprié'), leading: const Icon(Icons.block)),
            ListTile(onTap: () => Navigator.pop(context, 'Harcèlement'), title: const Text('Harcèlement'), leading: const Icon(Icons.person_off)),
            ListTile(onTap: () => Navigator.pop(context, 'Fausse information'), title: const Text('Fausse information'), leading: const Icon(Icons.info_outline)),
          ],
        ),
      ),
    );
    
    if (reason != null) {
      await _networkService.reportPost(widget.post.id, reason);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Publication signalée'), backgroundColor: Colors.orange),
        );
      }
    }
  }

  Future<void> _editPost() async {
    final controller = TextEditingController(text: widget.post.content);
    final newContent = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier la publication'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(hintText: 'Modifiez votre publication...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.pop(context, controller.text), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)), child: const Text('Enregistrer')),
        ],
      ),
    );
    
    if (newContent != null && newContent != widget.post.content) {
      await _networkService.updatePost(widget.post.id, newContent);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Publication modifiée'), backgroundColor: Colors.green),
        );
        widget.onLike(); // Refresh
      }
    }
  }

  void _showMenu(BuildContext context) {
    final auth = Provider.of<AuthController>(context, listen: false);
    final isOwner = auth.currentUser?.id == widget.post.userId;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isOwner) ...[
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Modifier'),
                onTap: () {
                  Navigator.pop(context);
                  _editPost();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Supprimer'),
                onTap: () {
                  Navigator.pop(context);
                  _deletePost();
                },
              ),
              const Divider(),
            ],
            ListTile(
              leading: const Icon(Icons.visibility_off, color: Colors.orange),
              title: const Text('Masquer'),
              onTap: () {
                Navigator.pop(context);
                _hidePost();
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag, color: Colors.red),
              title: const Text('Signaler'),
              onTap: () {
                Navigator.pop(context);
                _reportPost();
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.green),
              title: const Text('Partager'),
              onTap: () {
                Navigator.pop(context);
                widget.onShare();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.close, color: Colors.grey),
              title: const Text('Annuler'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthController>(context);
    final isOwner = auth.currentUser?.id == widget.post.userId;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Avatar, Nom, Heure, Menu
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: widget.post.userAvatar != null ? NetworkImage(widget.post.userAvatar!) : null,
                    child: widget.post.userAvatar == null ? const Icon(Icons.person) : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.userName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (widget.post.userTitle != null)
                          Text(
                            widget.post.userTitle!,
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    _getTimeAgo(widget.post.createdAt),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert, size: 18),
                    onSelected: (value) {
                      switch (value) {
                        case 'edit': _editPost(); break;
                        case 'delete': _deletePost(); break;
                        case 'hide': _hidePost(); break;
                        case 'report': _reportPost(); break;
                        case 'share': widget.onShare(); break;
                      }
                    },
                    itemBuilder: (context) => [
                      if (isOwner) const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Modifier')])),
                      if (isOwner) const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Supprimer')])),
                      const PopupMenuItem(value: 'hide', child: Row(children: [Icon(Icons.visibility_off, size: 18), SizedBox(width: 8), Text('Masquer')])),
                      const PopupMenuItem(value: 'report', child: Row(children: [Icon(Icons.flag, size: 18), SizedBox(width: 8), Text('Signaler')])),
                      const PopupMenuItem(value: 'share', child: Row(children: [Icon(Icons.share, size: 18), SizedBox(width: 8), Text('Partager')])),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Contenu
              if (widget.post.content.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(widget.post.content, style: const TextStyle(fontSize: 14)),
                ),
              
              // Images
              if (widget.post.images.isNotEmpty)
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.post.images.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(widget.post.images[index], width: 150, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 12),

              // Actions: Like, Comment, Share
              Row(
                children: [
                  InkWell(
                    onTap: widget.onLike,
                    child: Row(
                      children: [
                        Icon(
                          widget.post.isLikedByCurrentUser ? Icons.favorite : Icons.favorite_border,
                          color: widget.post.isLikedByCurrentUser ? Colors.red : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text('${widget.post.likesCount}', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  InkWell(
                    onTap: widget.onComment,
                    child: Row(
                      children: [
                        const Icon(Icons.chat_bubble_outline, size: 20, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('${widget.post.commentsCount}', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  InkWell(
                    onTap: widget.onShare,
                    child: const Row(
                      children: [
                        Icon(Icons.share, size: 20, color: Colors.grey),
                        SizedBox(width: 4),
                        Text('Partager', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
