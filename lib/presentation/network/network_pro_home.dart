import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thix_id/auth/auth_controller.dart';
import 'package:thix_id/services/network_service.dart';
import 'package:thix_id/models/network_post.dart';
import 'package:thix_id/models/network_connection.dart';
import 'package:thix_id/models/network_community.dart';
import 'widgets/profile_header_card.dart';
import 'widgets/stats_row.dart';
import 'widgets/stories_list.dart';
import 'widgets/post_card.dart';
import 'widgets/suggestions_list.dart';
import 'widgets/communities_list.dart';
import 'widgets/opportunities_list.dart';
import 'widgets/events_list.dart';
import 'widgets/recommendations_ia.dart';
import 'widgets/create_post_dialog.dart';
import 'widgets/edit_profile_dialog.dart';
import 'widgets/create_story_dialog.dart';

// Imports pour les redirections
import 'package:thix_id/presentation/jobs/jobs_page.dart';
import 'package:thix_id/presentation/events/events_page.dart';
import 'package:thix_id/presentation/opportunities/opportunities_page.dart';

class NetworkProHome extends StatefulWidget {
  const NetworkProHome({super.key});

  @override
  State<NetworkProHome> createState() => _NetworkProHomeState();
}

class _NetworkProHomeState extends State<NetworkProHome> {
  late NetworkService _networkService;
  
  // Données réelles
  List<NetworkPost> _posts = [];
  List<NetworkConnection> _suggestions = [];
  List<NetworkCommunity> _communities = [];
  
  bool _loadingPosts = true;
  bool _loadingSuggestions = true;
  bool _loadingCommunities = true;
  
  int _unreadNotifications = 0;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _networkService = NetworkService(Supabase.instance.client);
    _loadAllData();
    _loadUnreadCount();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadPosts(),
      _loadSuggestions(),
      _loadCommunities(),
    ]);
  }

  Future<void> _loadPosts() async {
    setState(() => _loadingPosts = true);
    try {
      final posts = await _networkService.getFeedPosts();
      setState(() => _posts = posts);
    } catch (e) {
      debugPrint('Error loading posts: $e');
    } finally {
      setState(() => _loadingPosts = false);
    }
  }

  Future<void> _loadSuggestions() async {
    setState(() => _loadingSuggestions = true);
    try {
      final suggestions = await _networkService.getSuggestedConnections();
      setState(() => _suggestions = suggestions);
    } catch (e) {
      debugPrint('Error loading suggestions: $e');
    } finally {
      setState(() => _loadingSuggestions = false);
    }
  }

  Future<void> _loadCommunities() async {
    setState(() => _loadingCommunities = true);
    try {
      final communities = await _networkService.getSuggestedCommunities();
      setState(() => _communities = communities);
    } catch (e) {
      debugPrint('Error loading communities: $e');
    } finally {
      setState(() => _loadingCommunities = false);
    }
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await _networkService.getUnreadNotificationsCount();
      if (mounted) setState(() => _unreadNotifications = count);
    } catch (e) {
      debugPrint('Error loading unread count: $e');
    }
  }

  Future<void> _onRefresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    await _loadAllData();
    await _loadUnreadCount();
    setState(() => _isRefreshing = false);
  }

  void _showCreatePostDialog() {
    showDialog(
      context: context,
      builder: (_) => const CreatePostDialog(),
    ).then((refresh) {
      if (refresh == true) _loadPosts();
    });
  }

  void _showCreateStoryDialog() {
    showDialog(
      context: context,
      builder: (_) => const CreateStoryDialog(),
    ).then((refresh) {
      if (refresh == true) _loadAllData();
    });
  }

  void _showEditProfileDialog() async {
    final auth = Provider.of<AuthController>(context, listen: false);
    final user = auth.currentUser;
    if (user == null) return;

    final result = await showDialog(
      context: context,
      builder: (_) => EditProfileDialog(
        userId: user.id,
        currentName: user.displayName,
        currentTitle: user.profession,
        currentBio: user.bio,
        currentAvatarUrl: user.photoUrl,
        currentSkills: user.skills.map((s) => s['name']?.toString() ?? '').toList(),
      ),
    );
    
    if (result != null && mounted) {
      await auth.updateCurrentUser(user.copyWith(
        displayName: result['name'],
        profession: result['title'],
        bio: result['bio'],
        photoUrl: result['avatar_url'],
      ));
      await _loadAllData();
    }
  }

  void _showNotifications() {
    context.push('/network/notifications').then((_) => _loadUnreadCount());
  }

  void _goToMessages() => context.push('/network/messages');
  void _goToSearch() => context.push('/network/search');
  void _goToGroups() => context.push('/network/groups');
  void _goToJobs() => context.push('/jobs');
  void _goToEvents() => context.push('/events');
  void _goToOpportunities() => context.push('/opportunities');
  void _goToConnexions() => context.push('/network/connections');
  void _goToPublications() => context.push('/network/my-posts');
  void _goToStory(String storyId) => context.push('/network/story/$storyId');

  void _showCommentDialog(NetworkPost post) {
    final commentController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Ajouter un commentaire', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                          await _networkService.addComment(post.id, commentController.text.trim());
                          if (mounted) {
                            Navigator.pop(context);
                            await _loadPosts();
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
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
        title: const Text('THIX RÉSEAU PRO', style: TextStyle(color: Color(0xFF0B1B3D), fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Color(0xFF0B1B3D)), onPressed: _goToSearch),
          IconButton(icon: const Icon(Icons.groups, color: Color(0xFF0B1B3D)), onPressed: _goToGroups),
          Stack(
            children: [
              IconButton(icon: const Icon(Icons.notifications_outlined, color: Color(0xFF0B1B3D)), onPressed: _showNotifications),
              if (_unreadNotifications > 0)
                Positioned(
                  right: 4, top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                    child: Text('$_unreadNotifications', style: const TextStyle(color: Colors.white, fontSize: 8), textAlign: TextAlign.center),
                  ),
                ),
            ],
          ),
          IconButton(icon: const Icon(Icons.message_outlined, color: Color(0xFF0B1B3D)), onPressed: _goToMessages),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              ProfileHeaderCard(
                onEditPressed: _showEditProfileDialog,
                onPhotoPressed: _showCreatePostDialog,
                onVideoPressed: _showCreatePostDialog,
                onDocumentPressed: _showCreatePostDialog,
                onEventPressed: _goToEvents,
                onJobPressed: _goToJobs,
                onStoryPressed: _showCreateStoryDialog,
              ),
              const SizedBox(height: 16),

              // Stats
              StatsRow(
                onConnexionsTap: _goToConnexions,
                onPublicationsTap: _goToPublications,
                onCommunitiesTap: _goToGroups,
                onMessagesTap: _goToMessages,
              ),
              const SizedBox(height: 20),

              // Stories
              StoriesList(onStoryTap: _goToStory),
              const SizedBox(height: 20),

              // Posts
              if (_loadingPosts)
                const Center(child: CircularProgressIndicator())
              else if (_posts.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.post_add, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Aucune publication'),
                        Text('Soyez le premier à partager quelque chose'),
                      ],
                    ),
                  ),
                )
              else
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
                      await _loadPosts();
                    },
                    onComment: () => _showCommentDialog(post),
                    onTap: () => context.push('/network/post/${post.id}'),
                    onShare: () {},
                  ),
                )),
              const SizedBox(height: 16),

              // Suggestions de connexions
              if (_loadingSuggestions)
                const Center(child: CircularProgressIndicator())
              else if (_suggestions.isNotEmpty) ...[
                const Text('Suggestions de connexions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                SuggestionsList(
                  suggestions: _suggestions,
                  onConnect: (userId) async {
                    await _networkService.sendConnectionRequest(userId);
                    await _loadSuggestions();
                  },
                ),
                const SizedBox(height: 20),
              ],

              // Communautés populaires (lecture seule)
              if (_loadingCommunities)
                const Center(child: CircularProgressIndicator())
              else if (_communities.isNotEmpty) ...[
                const Text('Communautés populaires', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                CommunitiesList(
                  communities: _communities,
                  onCommunityTap: (communityId) => context.push('/network/community/$communityId'),
                  onJoinTap: (communityId) async {
                    await _networkService.joinCommunity(communityId);
                    await _loadCommunities();
                  },
                ),
                const SizedBox(height: 20),
              ],

              // Opportunités (redirection seulement)
              OpportunitiesList(
                onOpportunityTap: (id) => _goToOpportunities(),
                onApplyTap: (id) => _goToOpportunities(),
              ),
              const SizedBox(height: 20),

              // Événements (redirection seulement)
              EventsList(
                onEventTap: (id) => _goToEvents(),
                onInterestedTap: (id) => _goToEvents(),
              ),
              const SizedBox(height: 20),

              // IA Recommendations
              RecommendationsIA(
                onPeopleTap: _goToSearch,
                onOpportunitiesTap: _goToOpportunities,
                onCommunitiesTap: _goToGroups,
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePostDialog,
        backgroundColor: const Color(0xFFD4AF37),
        child: const Icon(Icons.add, color: Color(0xFF0B1B3D)),
      ),
    );
  }
}
