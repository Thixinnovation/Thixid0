import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thix_id/auth/auth_controller.dart';
import 'package:thix_id/services/network_service.dart';
import 'package:thix_id/models/network_post.dart';
import 'package:thix_id/models/network_connection.dart';
import 'widgets/profile_header_card.dart';
import 'widgets/stats_row.dart';
import 'widgets/stories_list.dart';
import 'widgets/post_card.dart';
import 'widgets/suggestions_list.dart';
import 'widgets/communities_list.dart';
import 'widgets/opportunities_list.dart';
import 'widgets/events_list.dart';
import 'widgets/recommendations_ia.dart';

class NetworkProHome extends StatefulWidget {
  const NetworkProHome({super.key});

  @override
  State<NetworkProHome> createState() => _NetworkProHomeState();
}

class _NetworkProHomeState extends State<NetworkProHome> {
  late NetworkService _networkService;
  List<NetworkPost> _posts = [];
  List<NetworkConnection> _suggestions = [];
  bool _loading = true;
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _networkService = NetworkService(Supabase.instance.client);
    _loadData();
    _loadUnreadCount();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final posts = await _networkService.getFeedPosts();
      final suggestions = await _networkService.getSuggestedConnections();
      setState(() {
        _posts = posts;
        _suggestions = suggestions;
      });
    } catch (e) {
      print('Error loading network data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadUnreadCount() async {
    final count = await _networkService.getUnreadNotificationsCount();
    setState(() => _unreadNotifications = count);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthController>(context);
    if (auth.currentUser == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Connectez-vous pour accéder au Réseau Pro'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.push('/login'),
                child: const Text('Se connecter'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'THIX RÉSEAU PRO',
          style: TextStyle(
            color: Color(0xFF0B1B3D),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Color(0xFF0B1B3D)),
                onPressed: () => _showNotifications(),
              ),
              if (_unreadNotifications > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                    child: Text(
                      '$_unreadNotifications',
                      style: const TextStyle(color: Colors.white, fontSize: 8),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.message_outlined, color: Color(0xFF0B1B3D)),
            onPressed: () => _goToMessages(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ProfileHeaderCard(),
              const SizedBox(height: 16),
              const StatsRow(),
              const SizedBox(height: 20),
              const StoriesList(),
              const SizedBox(height: 20),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else ...[
                ..._posts.map((post) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: PostCard(
                    post: post,
                    onLike: () async {
                      if (post.isLikedByCurrentUser) {
                        await _networkService.unlikePost(post.id);
                      } else {
                        await _networkService.likePost(post.id);
                      }
                      await _loadData();
                    },
                    onComment: () => _showCommentDialog(post),
                  ),
                )),
              ],
              const SizedBox(height: 16),
              if (_suggestions.isNotEmpty) ...[
                const Text(
                  'Suggestions de connexions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SuggestionsList(
                  suggestions: _suggestions,
                  onConnect: (userId) async {
                    await _networkService.sendConnectionRequest(userId);
                    await _loadData();
                  },
                ),
              ],
              const SizedBox(height: 20),
              const CommunitiesList(),
              const SizedBox(height: 20),
              const OpportunitiesList(),
              const SizedBox(height: 20),
              const EventsList(),
              const SizedBox(height: 20),
              const RecommendationsIA(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotifications() {
    // TODO: Implémenter l'écran des notifications
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifications - à venir')),
    );
  }

  void _goToMessages() {
    // TODO: Naviguer vers les messages
    context.push('/network/messages');
  }

  void _showCommentDialog(NetworkPost post) {
    final commentController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ajouter un commentaire',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  hintText: 'Écrivez votre commentaire...',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (commentController.text.trim().isNotEmpty) {
                          await _networkService.addComment(
                            post.id,
                            commentController.text.trim(),
                          );
                          Navigator.pop(context);
                          await _loadData();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                      ),
                      child: const Text('Publier'),
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
