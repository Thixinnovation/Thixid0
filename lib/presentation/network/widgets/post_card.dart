// lib/presentation/network/widgets/post_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thix_id/models/network_post.dart';
import 'package:thix_id/services/network_service.dart';
import 'package:thix_id/auth/auth_controller.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PostCard extends StatefulWidget {
  final NetworkPost post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onTap;
  final VoidCallback onShare;
  final VoidCallback? onRefresh;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onTap,
    required this.onShare,
    this.onRefresh,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late NetworkService _networkService;
  late NetworkPost _post;

  @override
  void initState() {
    super.initState();
    _networkService = NetworkService(Supabase.instance.client);
    _post = widget.post;
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
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        await _networkService.deletePost(_post.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Publication supprimée'), backgroundColor: Colors.green),
          );
          widget.onRefresh?.call();
          widget.onLike();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _hidePost() async {
    try {
      await _networkService.hidePost(_post.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Publication masquée'), backgroundColor: Colors.orange),
        );
        widget.onRefresh?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
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
      try {
        await _networkService.reportPost(_post.id, reason);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Publication signalée'), backgroundColor: Colors.orange),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _editPost() async {
    final controller = TextEditingController(text: _post.content);
    final newContent = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier la publication'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Modifiez votre publication...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
    
    if (newContent != null && newContent != _post.content) {
      try {
        await _networkService.updatePost(_post.id, newContent);
        setState(() {
          _post = _post.copyWith(content: newContent);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Publication modifiée'), backgroundColor: Colors.green),
          );
          widget.onRefresh?.call();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthController>(context);
    final isOwner = auth.currentUser?.id == _post.userId;
    final hasUserTitle = _post.authorTitle != null && _post.authorTitle!.isNotEmpty;
    final hasImage = _post.mediaUrl != null && _post.mediaUrl!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: _post.authorAvatar != null && _post.authorAvatar!.isNotEmpty
                        ? CachedNetworkImageProvider(_post.authorAvatar!)
                        : null,
                    child: _post.authorAvatar == null || _post.authorAvatar!.isEmpty
                        ? const Icon(Icons.person, size: 20)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _post.authorName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (hasUserTitle)
                          Text(
                            _post.authorTitle!,
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Text(
                    _getTimeAgo(_post.createdAt),
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
                      if (isOwner) const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Supprimer', style: TextStyle(color: Colors.red))])),
                      const PopupMenuItem(value: 'hide', child: Row(children: [Icon(Icons.visibility_off, size: 18), SizedBox(width: 8), Text('Masquer')])),
                      const PopupMenuItem(value: 'report', child: Row(children: [Icon(Icons.flag, size: 18), SizedBox(width: 8), Text('Signaler')])),
                      const PopupMenuItem(value: 'share', child: Row(children: [Icon(Icons.share, size: 18), SizedBox(width: 8), Text('Partager')])),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Contenu
              if (_post.content != null && _post.content!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _post.content!,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                ),
              
              // Image unique
              if (hasImage)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: _post.mediaUrl!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 200,
                      color: Colors.grey.shade200,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 200,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                    ),
                  ),
                ),
              
              if (hasImage) const SizedBox(height: 12),

              // Actions
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      widget.onLike();
                      setState(() {
                        if (_post.isLikedByCurrentUser) {
                          _post = _post.copyWith(
                            likesCount: _post.likesCount - 1,
                            isLikedByCurrentUser: false,
                          );
                        } else {
                          _post = _post.copyWith(
                            likesCount: _post.likesCount + 1,
                            isLikedByCurrentUser: true,
                          );
                        }
                      });
                    },
                    child: Row(
                      children: [
                        Icon(
                          _post.isLikedByCurrentUser ? Icons.favorite : Icons.favorite_border,
                          color: _post.isLikedByCurrentUser ? Colors.red : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(_formatCount(_post.likesCount), style: const TextStyle(fontSize: 12)),
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
                        Text(_formatCount(_post.commentsCount), style: const TextStyle(fontSize: 12)),
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

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}
