// lib/presentation/network/network_pro_home.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thix_id/auth/auth_controller.dart';
import 'package:thix_id/services/network_service.dart';
import 'package:thix_id/models/network_post.dart';
import 'package:thix_id/models/network_connection.dart';
import 'package:thix_id/models/network_community.dart';
import 'package:thix_id/models/story.dart';
import 'widgets/profile_header_card.dart';
import 'widgets/stats_row.dart';
import 'widgets/stories_list.dart';
import 'widgets/post_card.dart';
import 'widgets/suggestions_list.dart';
import 'widgets/communities_list.dart';
import 'widgets/recommendations_ia.dart';
import 'widgets/create_post_dialog.dart';
import 'widgets/edit_profile_dialog.dart';
import 'widgets/create_story_dialog.dart';

class NetworkProHome extends StatefulWidget {
  const NetworkProHome({super.key});

  @override
  State<NetworkProHome> createState() => _NetworkProHomeState();
}

class _NetworkProHomeState extends State<NetworkProHome> {
  late NetworkService _networkService;
  late final SupabaseClient _supabase;
  
  List<NetworkPost> _posts = [];
  List<NetworkConnection> _suggestions = [];
  List<NetworkCommunity> _communities = [];
  List<Story> _stories = [];
  
  bool _loadingPosts = true;
  bool _loadingSuggestions = true;
  bool _loadingCommunities = true;
  bool _loadingStories = true;
  
  int _unreadNotifications = 0;
  int _unreadMessages = 0;
  bool _isRefreshing = false;
  
  String _selectedSort = 'recent'; // recent, popular, following

  @override
  void initState() {
    super.initState();
    _supabase = Supabase.instance.client;
    _networkService = NetworkService(_supabase);
    _loadAllData();
    _setupRealtimeSubscriptions();
  }

  void _setupRealtimeSubscriptions() {
    // Écouter les nouveaux posts en temps réel
    _supabase.channel('public:posts')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'posts',
          callback: (payload) {
            if (mounted) {
              _loadPosts(); // Recharger pour le nouveau post
            }
          },
        )
        .subscribe();

    // Écouter les nouvelles stories
    _supabase.channel('public:stories')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'stories',
          callback: (payload) {
            if (mounted) {
              _loadStories();
            }
          },
        )
        .subscribe();

    // Écouter les nouvelles notifications
    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      _supabase.channel('public:notifications:$userId')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'notifications',
            callback: (payload) {
              if (mounted) {
                _loadUnreadCount();
              }
            },
          )
          .subscribe();
    }
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadPosts(),
      _loadSuggestions(),
      _loadCommunities(),
      _loadStories(),
    ]);
  }

  Future<void> _loadPosts() async {
    setState(() => _loadingPosts = true);
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      String query = '''
        SELECT 
          p.*,
          u.display_name as author_name,
          u.photo_url as author_avatar,
          u.profession as author_title,
          COUNT(DISTINCT pl.id) as likes_count,
          COUNT(DISTINCT c.id) as comments_count,
          EXISTS(SELECT 1 FROM post_likes WHERE post_id = p.id AND user_id = '$userId') as is_liked,
          EXISTS(SELECT 1 FROM saved_posts WHERE post_id = p.id AND user_id = '$userId') as is_saved
        FROM posts p
        LEFT JOIN users u ON p.user_id = u.id
        LEFT JOIN post_likes pl ON p.id = pl.post_id
        LEFT JOIN comments c ON p.id = c.post_id
        WHERE p.is_public = true 
           OR p.user_id IN (SELECT connection_id FROM connections WHERE user_id = '$userId' AND status = 'accepted')
           OR p.user_id = '$userId'
        GROUP BY p.id, u.display_name, u.photo_url, u.profession
      ''';
      
      // Ajouter le tri
      if (_selectedSort == 'popular') {
        query += ' ORDER BY likes_count DESC, p.created_at DESC';
      } else {
        query += ' ORDER BY p.created_at DESC';
      }
      
      final response = await _supabase.from('posts').select(query);
      
      setState(() {
        _posts = response.map((json) => NetworkPost.fromJsonWithRelations(json)).toList();
        _loadingPosts = false;
      });
    } catch (e) {
      debugPrint('Error loading posts: $e');
      setState(() => _loadingPosts = false);
    }
  }

  Future<void> _loadSuggestions() async {
    setState(() => _loadingSuggestions = true);
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Suggestions basées sur les compétences, secteur, connexions communes
      final response = await _supabase.rpc('get_suggested_connections', params: {
        'user_id': userId,
        'limit': 5,
      });
      
      setState(() {
        _suggestions = response.map((json) => NetworkConnection.fromJson(json)).toList();
        _loadingSuggestions = false;
      });
    } catch (e) {
      debugPrint('Error loading suggestions: $e');
      setState(() => _loadingSuggestions = false);
    }
  }

  Future<void> _loadCommunities() async {
    setState(() => _loadingCommunities = true);
    try {
      final userId = _supabase.auth.currentUser?.id;
      
      final response = await _supabase
          .from('communities')
          .select('''
            *,
            COUNT(DISTINCT cm.user_id) as members_count,
            EXISTS(SELECT 1 FROM community_members WHERE community_id = id AND user_id = '$userId') as is_member
          ''')
          .order('members_count', ascending: false)
          .limit(5);
      
      setState(() {
        _communities = response.map((json) => NetworkCommunity.fromJson(json)).toList();
        _loadingCommunities = false;
      });
    } catch (e) {
      debugPrint('Error loading communities: $e');
      setState(() => _loadingCommunities = false);
    }
  }

  Future<void> _loadStories() async {
    setState(() => _loadingStories = true);
    try {
      final userId = _supabase.auth.currentUser?.id;
      
      // Stories des dernières 24h des connexions
      final response = await _supabase
          .from('stories')
          .select('''
            *,
            users!inner (
              display_name,
              photo_url,
              profession
            )
          ''')
          .eq('is_active', true)
          .gte('created_at', DateTime.now().subtract(const Duration(hours: 24)).toIso8601String())
          .inFilter('user_id', await _getConnectedUserIds())
          .order('created_at', ascending: false);
      
      setState(() {
        _stories = response.map((json) => Story.fromJson(json)).toList();
        _loadingStories = false;
      });
    } catch (e) {
      debugPrint('Error loading stories: $e');
      setState(() => _loadingStories = false);
    }
  }

  Future<List<String>> _getConnectedUserIds() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];
    
    final response = await _supabase
        .from('connections')
        .select('user_id, connection_id')
        .or('user_id.eq.$userId,connection_id.eq.$userId')
        .eq('status', 'accepted');
    
    final Set<String> ids = {};
    for (var conn in response) {
      if (conn['user_id'] != userId) ids.add(conn['user_id']);
      if (conn['connection_id'] != userId) ids.add(conn['connection_id']);
    }
    return ids.toList();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;
      
      final notificationsCount = await _supabase
          .from('notifications')
          .select('id', count: CountOption.exact)
          .eq('user_id', userId)
          .eq('is_read', false);
          
      final messagesCount = await _supabase
          .from('messages')
          .select('id', count: CountOption.exact)
          .eq('receiver_id', userId)
          .eq('is_read', false);
      
      if (mounted) {
        setState(() {
          _unreadNotifications = notificationsCount.count ?? 0;
          _unreadMessages = messagesCount.count ?? 0;
        });
      }
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

  void _showCreateStoryDialog() async {
    final result = await showDialog(
      context: context,
      builder: (_) => const CreateStoryDialog(),
    );
    if (result == true && mounted) {
      await _loadStories();
    }
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

  void _goToMessages() {
    context.push('/network/messages');
  }

  void _goToSearch() {
    context.push('/network/search');
  }

  void _goToGroups() {
    context.push('/network/groups');
  }

  void _goToJobs() {
    context.push('/jobs');
  }

  void _goToEvents() {
    context.push('/events');
  }

  void _goToOpportunities() {
    context.push('/opportunities');
  }

  void _goToConnexions() {
    context.push('/network/connections');
  }

  void _goToPublications() {
    context.push('/network/my-posts');
  }

  void _viewStory(String storyId) {
    context.push('/network/story/$storyId');
  }

  void _likePost(NetworkPost post, int index) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    
    // Optimistic update
    setState(() {
      if (_posts[index].isLikedByCurrentUser) {
        _posts[index].likesCount--;
        _posts[index].isLikedByCurrentUser = false;
      } else {
        _posts[index].likesCount++;
        _posts[index].isLikedByCurrentUser = true;
      }
    });
    
    try {
      if (post.isLikedByCurrentUser) {
        await _supabase
            .from('post_likes')
            .delete()
            .match({'post_id': post.id, 'user_id': userId});
      } else {
        await _supabase.from('post_likes').insert({
          'post_id': post.id,
          'user_id': userId,
          'created_at': DateTime.now().toIso8601String(),
        });
        
        // Créer notification si ce n'est pas mon post
        if (post.userId != userId) {
          await _supabase.from('notifications').insert({
            'user_id': post.userId,
            'type': 'like',
            'content': 'a aimé votre publication',
            'post_id': post.id,
            'created_at': DateTime.now().toIso8601String(),
          });
        }
      }
    } catch (e) {
      // Revert en cas d'erreur
      setState(() {
        if (_posts[index].isLikedByCurrentUser) {
          _posts[index].likesCount--;
          _posts[index].isLikedByCurrentUser = false;
        } else {
          _posts[index].likesCount++;
          _posts[index].isLikedByCurrentUser = true;
        }
      });
      debugPrint('Error toggling like: $e');
    }
  }

  void _showCommentDialog(NetworkPost post, int postIndex) {
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
                          final userId = _supabase.auth.currentUser?.id;
                          if (userId == null) return;
                          
                          // Ajouter le commentaire
                          await _supabase.from('comments').insert({
                            'post_id': post.id,
                            'user_id': userId,
                            'content': commentController.text.trim(),
                            'created_at': DateTime.now().toIso8601String(),
                          });
                          
                          // Incrémenter le compteur
                          setState(() {
                            _posts[postIndex].commentsCount++;
                          });
                          
                          // Notification
                          if (post.userId != userId) {
                            await _supabase.from('notifications').insert({
                              'user_id': post.userId,
                              'type': 'comment',
                              'content': 'a commenté votre publication',
                              'post_id': post.id,
                              'created_at': DateTime.now().toIso8601String(),
                            });
                          }
                          
                          if (mounted) {
                            Navigator.pop(context);
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
        title: const Text(
          'THIX RÉSEAU PRO',
          style: TextStyle(color: Color(0xFF0B1B3D), fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF0B1B3D)), 
            onPressed: _goToSearch,
          ),
          IconButton(
            icon: const Icon(Icons.groups, color: Color(0xFF0B1B3D)), 
            onPressed: _goToGroups,
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Color(0xFF0B1B3D)), 
                onPressed: _showNotifications,
              ),
              if (_unreadNotifications > 0)
                Positioned(
                  right: 4, top: 4,
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
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.message_outlined, color: Color(0xFF0B1B3D)), 
                onPressed: _goToMessages,
              ),
              if (_unreadMessages > 0)
                Positioned(
                  right: 4, top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                    child: Text(
                      '$_unreadMessages', 
                      style: const TextStyle(color: Colors.white, fontSize: 8), 
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          slivers: [
            // En-tête avec profil
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
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
                  StatsRow(
                    onConnexionsTap: _goToConnexions,
                    onPublicationsTap: _goToPublications,
                    onCommunitiesTap: _goToGroups,
                    onMessagesTap: _goToMessages,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            
            // Section Stories (comme dans ta capture)
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Stories',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0B1B3D)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_loadingStories)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_stories.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Aucune story récente'),
                    )
                  else
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _stories.length,
                        itemBuilder: (context, index) {
                          final story = _stories[index];
                          return GestureDetector(
                            onTap: () => _viewStory(story.id),
                            child: Container(
                              width: 80,
                              margin: const EdgeInsets.only(right: 12),
                              child: Column(
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: const Color(0xFFD4AF37),
                                            width: 2,
                                          ),
                                        ),
                                        child: CircleAvatar(
                                          radius: 32,
                                          backgroundImage: story.userAvatar != null 
                                              ? NetworkImage(story.userAvatar!)
                                              : null,
                                          child: story.userAvatar == null
                                              ? const Icon(Icons.person, size: 32)
                                              : null,
                                        ),
                                      ),
                                      if (!story.isViewed)
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: Container(
                                            width: 16,
                                            height: 16,
                                            decoration: const BoxDecoration(
                                              color: Colors.green,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    story.userName,
                                    style: const TextStyle(fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            
            // Fil d'actualité
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Fil d\'actualité',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0B1B3D)),
                    ),
                    DropdownButton<String>(
                      value: _selectedSort,
                      items: const [
                        DropdownMenuItem(value: 'recent', child: Text('Trier par : Récent')),
                        DropdownMenuItem(value: 'popular', child: Text('Trier par : Populaire')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedSort = value);
                          _loadPosts();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            
            // Liste des posts
            if (_loadingPosts)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_posts.isEmpty)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        const Icon(Icons.post_add, size: 48, color: Colors.grey),
                        const SizedBox(height: 8),
                        const Text('Aucune publication'),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _showCreatePostDialog,
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
                          child: const Text('Créer ma première publication'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final post = _posts[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: PostCard(
                        post: post,
                        onLike: () => _likePost(post, index),
                        onComment: () => _showCommentDialog(post, index),
                        onTap: () => context.push('/network/post/${post.id}'),
                        onShare: () async {
                          // Partager le post
                          final userId = _supabase.auth.currentUser?.id;
                          if (userId != null && post.userId != userId) {
                            await _supabase.from('notifications').insert({
                              'user_id': post.userId,
                              'type': 'share',
                              'content': 'a partagé votre publication',
                              'post_id': post.id,
                              'created_at': DateTime.now().toIso8601String(),
                            });
                          }
                        },
                      ),
                    );
                  },
                  childCount: _posts.length,
                ),
              ),
            
            // Suggestions
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_loadingSuggestions)
                    const Center(child: CircularProgressIndicator())
                  else if (_suggestions.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Suggestions pour vous', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),
                    SuggestionsList(
                      suggestions: _suggestions,
                      onConnect: (userId) async {
                        await _networkService.sendConnectionRequest(userId);
                        await _loadSuggestions();
                      },
                    ),
                  ],
                ],
              ),
            ),
            
            // Communautés
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_loadingCommunities)
                    const Center(child: CircularProgressIndicator())
                  else if (_communities.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Communautés populaires', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),
                    CommunitiesList(
                      communities: _communities,
                      onCommunityTap: (communityId) => context.push('/network/community/$communityId'),
                      onJoinTap: (communityId) async {
                        await _networkService.joinCommunity(communityId);
                        await _loadCommunities();
                      },
                    ),
                  ],
                ],
              ),
            ),
            
            // IA Recommandations
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: RecommendationsIA(
                  onPeopleTap: null,
                  onOpportunitiesTap: null,
                  onCommunitiesTap: null,
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
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
