// lib/presentation/network/network_pro_home.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _NetworkProHomeState extends State<NetworkProHome> with TickerProviderStateMixin {
  late NetworkService _networkService;
  late final SupabaseClient _supabase;
  late AnimationController _likeAnimationController;
  late AnimationController _fabAnimationController;
  
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
  
  String _feedType = 'smart';
  int _selectedNavIndex = 0;

  @override
  void initState() {
    super.initState();
    
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fabAnimationController.repeat(reverse: true);
    
    _supabase = Supabase.instance.client;
    _networkService = NetworkService(_supabase);
    _loadAllData();
    _setupRealtimeSubscriptions();
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _setupRealtimeSubscriptions() {
    _supabase.channel('public:posts')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'posts',
          callback: (payload) {
            if (mounted) _loadPosts();
          },
        )
        .subscribe();

    _supabase.channel('public:stories')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'stories',
          callback: (payload) {
            if (mounted) _loadStories();
          },
        )
        .subscribe();

    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      _supabase.channel('public:notifications:$userId')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'notifications',
            callback: (payload) {
              if (mounted) _loadUnreadCount();
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
      late List<NetworkPost> posts;
      
      switch (_feedType) {
        case 'smart':
          posts = await _networkService.getSmartFeed();
          break;
        case 'popular':
          posts = await _getPopularFeed();
          break;
        default:
          posts = await _networkService.getFeedPosts();
      }
      
      setState(() {
        _posts = posts;
        _loadingPosts = false;
      });
    } catch (e) {
      debugPrint('Error loading posts: $e');
      setState(() => _loadingPosts = false);
    }
  }

  Future<List<NetworkPost>> _getPopularFeed() async {
    try {
      final posts = await _networkService.getFeedPosts(limit: 50);
      posts.sort((a, b) => b.likesCount.compareTo(a.likesCount));
      return posts.take(20).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _loadSuggestions() async {
    setState(() => _loadingSuggestions = true);
    try {
      final suggestions = await _networkService.getSuggestedConnections(limit: 6);
      setState(() {
        _suggestions = suggestions;
        _loadingSuggestions = false;
      });
    } catch (e) {
      setState(() => _loadingSuggestions = false);
    }
  }

  Future<void> _loadCommunities() async {
    setState(() => _loadingCommunities = true);
    try {
      final communities = await _networkService.getSuggestedCommunities(limit: 6);
      setState(() {
        _communities = communities;
        _loadingCommunities = false;
      });
    } catch (e) {
      setState(() => _loadingCommunities = false);
    }
  }

  Future<void> _loadStories() async {
    setState(() => _loadingStories = true);
    try {
      final networkStories = await _networkService.getActiveStories();
      setState(() {
        _stories = networkStories.map((networkStory) => Story(
          id: networkStory.id,
          userId: networkStory.userId,
          userName: networkStory.userName,
          userAvatar: networkStory.userAvatar,
          userProfession: networkStory.userTitle,
          mediaUrl: networkStory.imageUrl,
          mediaType: 'image',
          content: null,
          createdAt: networkStory.createdAt,
          expiresAt: networkStory.expiresAt,
          isActive: networkStory.isActive,
          isViewed: networkStory.isViewed,
          viewsCount: 0,
        )).toList();
        _loadingStories = false;
      });
    } catch (e) {
      setState(() => _loadingStories = false);
    }
  }

  Future<void> _loadUnreadCount() async {
    try {
      final unreadNotifications = await _networkService.getUnreadNotificationsCount();
      final unreadMessages = await _networkService.getUnreadMessagesCount();
      
      if (mounted) {
        setState(() {
          _unreadNotifications = unreadNotifications;
          _unreadMessages = unreadMessages;
        });
      }
    } catch (e) {
      debugPrint('Error loading unread count: $e');
    }
  }

  Future<void> _onRefresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    HapticFeedback.lightImpact();
    await _loadAllData();
    await _loadUnreadCount();
    setState(() => _isRefreshing = false);
  }

  void _showCreatePostDialog() {
    HapticFeedback.mediumImpact();
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
      builder: (_) => const EditProfileDialog(
        userId: '',
        currentName: '',
        currentTitle: '',
        currentBio: '',
        currentAvatarUrl: '',
        currentSkills: [],
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
    
    _likeAnimationController.forward(from: 0.0);
    HapticFeedback.lightImpact();
    
    final updatedPost = post.copyWith(
      likesCount: post.isLikedByCurrentUser ? post.likesCount - 1 : post.likesCount + 1,
      isLikedByCurrentUser: !post.isLikedByCurrentUser,
    );
    
    setState(() {
      _posts[index] = updatedPost;
    });
    
    try {
      if (post.isLikedByCurrentUser) {
        await _networkService.unlikePost(post.id);
      } else {
        await _networkService.likePost(post.id);
      }
    } catch (e) {
      final revertedPost = post.copyWith(
        likesCount: post.likesCount,
        isLikedByCurrentUser: post.isLikedByCurrentUser,
      );
      setState(() {
        _posts[index] = revertedPost;
      });
    }
  }

  void _showCommentDialog(NetworkPost post, int postIndex) {
    final commentController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 16,
          left: 16,
          right: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Ajouter un commentaire', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              decoration: InputDecoration(
                hintText: 'Écrivez votre commentaire...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                        
                        final updatedPost = post.copyWith(
                          commentsCount: post.commentsCount + 1,
                        );
                        setState(() {
                          _posts[postIndex] = updatedPost;
                        });
                        
                        if (mounted) {
                          Navigator.pop(context);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: const Color(0xFF0B1B3D),
                    ),
                    child: const Text('Publier'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
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
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          CustomScrollView(
            controller: ScrollController(),
            slivers: [
              SliverToBoxAdapter(child: _buildModernHeader()),
              SliverToBoxAdapter(child: _buildStoriesSection()),
              SliverToBoxAdapter(child: _buildFilterChips()),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              
              if (_loadingPosts)
                const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
              else if (_posts.isEmpty)
                SliverToBoxAdapter(child: _buildEmptyState())
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildModernPostCard(_posts[index], index),
                    childCount: _posts.length,
                  ),
                ),
              
              if (!_loadingSuggestions && _suggestions.isNotEmpty)
                SliverToBoxAdapter(child: _buildSuggestionsSection()),
              
              if (!_loadingCommunities && _communities.isNotEmpty)
                SliverToBoxAdapter(child: _buildCommunitiesSection()),
              
              SliverToBoxAdapter(child: _buildIARecommendations()),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          
          Positioned(bottom: 0, left: 0, right: 0, child: _buildModernBottomNav()),
          Positioned(bottom: 80, right: 16, child: _buildFloatingActionButton()),
        ],
      ),
    );
  }

  Widget _buildModernHeader() {
    final auth = Provider.of<AuthController>(context);
    final user = auth.currentUser;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF0B1B3D), const Color(0xFF1A2B4D)],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFD4AF37), Color(0xFFE5C55E)]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('THIX', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                  const Spacer(),
                  _buildIconButton(Icons.search, () => _goToSearch()),
                  const SizedBox(width: 8),
                  _buildIconButton(Icons.notifications_outlined, _showNotifications, count: _unreadNotifications),
                  const SizedBox(width: 8),
                  _buildIconButton(Icons.message_outlined, _goToMessages, count: _unreadMessages),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _showEditProfileDialog,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundImage: user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
                      child: user?.photoUrl == null ? const Icon(Icons.person, size: 16) : null,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundImage: user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
                    child: user?.photoUrl == null ? const Icon(Icons.person, size: 32) : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? 'Utilisateur',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          user?.profession ?? 'Membre THIX',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        if (user?.bio != null && user!.bio!.isNotEmpty)
                          Text(
                            user.bio!,
                            style: TextStyle(color: Colors.white60, fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Connexions', '0'),
                  _buildStatItem('Publications', _posts.length.toString()),
                  _buildStatItem('Communautés', '0'),
                  _buildStatItem('Messages', _unreadMessages.toString()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed, {int count = 0}) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: 20),
            onPressed: onPressed,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ),
        if (count > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
              child: Text(
                count > 9 ? '9+' : '$count',
                style: const TextStyle(color: Colors.white, fontSize: 8),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }

  Widget _buildStoriesSection() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Stories', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                TextButton(
                  onPressed: () {},
                  child: const Text('Tout voir', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _stories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) return _buildAddStoryButton();
                return _buildStoryItem(_stories[index - 1]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddStoryButton() {
    return GestureDetector(
      onTap: _showCreateStoryDialog,
      child: Container(
        width: 70,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [Color(0xFFD4AF37), Color(0xFFE5C55E)]),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const CircleAvatar(radius: 30, backgroundColor: Colors.white, child: Icon(Icons.add, size: 30, color: Color(0xFFD4AF37))),
            ),
            const SizedBox(height: 4),
            const Text('Ajouter', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryItem(Story story) {
    return GestureDetector(
      onTap: () => _viewStory(story.id),
      child: Container(
        width: 70,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: !story.isViewed ? const LinearGradient(colors: [Color(0xFFD4AF37), Color(0xFFE5C55E)]) : null,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: story.userAvatar != null ? NetworkImage(story.userAvatar!) : null,
                    child: story.userAvatar == null ? const Icon(Icons.person, size: 30) : null,
                  ),
                ),
                if (!story.isViewed)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(story.userName, style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'icon': Icons.auto_awesome, 'label': 'Pour vous', 'value': 'smart'},
      {'icon': Icons.access_time, 'label': 'Récent', 'value': 'recent'},
      {'icon': Icons.trending_up, 'label': 'Populaires', 'value': 'popular'},
    ];
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _feedType == filter['value'];
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(filter['icon'] as IconData, size: 16, color: isSelected ? const Color(0xFFD4AF37) : Colors.grey),
                  const SizedBox(width: 6),
                  Text(filter['label'] as String, style: TextStyle(fontSize: 13)),
                ],
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() => _feedType = filter['value'] as String);
                  _loadPosts();
                }
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFFD4AF37).withOpacity(0.1),
              checkmarkColor: const Color(0xFFD4AF37),
              side: BorderSide(color: isSelected ? const Color(0xFFD4AF37) : Colors.grey[300]!),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernPostCard(NetworkPost post, int index) {
    final hasImage = post.mediaUrl != null && post.mediaUrl!.isNotEmpty;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: post.authorAvatar != null ? NetworkImage(post.authorAvatar!) : null,
                  child: post.authorAvatar == null ? const Icon(Icons.person, size: 20) : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Row(
                        children: [
                          Text(_formatTimeAgo(post.createdAt), style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                          const SizedBox(width: 4),
                          Icon(Icons.public, size: 10, color: Colors.grey[400]),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_horiz, size: 18, color: Colors.grey),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'save', child: Text('Sauvegarder')),
                    const PopupMenuItem(value: 'report', child: Text('Signaler')),
                  ],
                ),
              ],
            ),
          ),
          if (post.content != null && post.content!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(post.content!, style: const TextStyle(fontSize: 13, height: 1.4)),
            ),
          if (hasImage)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(post.mediaUrl!, width: double.infinity, fit: BoxFit.cover),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildPostAction(
                  icon: post.isLikedByCurrentUser ? Icons.favorite : Icons.favorite_border,
                  label: _formatCount(post.likesCount),
                  color: post.isLikedByCurrentUser ? Colors.red : Colors.grey,
                  onTap: () => _likePost(post, index),
                ),
                const SizedBox(width: 24),
                _buildPostAction(
                  icon: Icons.comment_outlined,
                  label: _formatCount(post.commentsCount),
                  onTap: () => _showCommentDialog(post, index),
                ),
                const Spacer(),
                _buildPostAction(
                  icon: Icons.bookmark_border,
                  label: '',
                  onTap: () => _networkService.savePost(post.id),
                ),
                const SizedBox(width: 16),
                _buildPostAction(
                  icon: Icons.share_outlined,
                  label: '',
                  onTap: () async => _networkService.sharePost(post.id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostAction({required IconData icon, required String label, Color? color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? Colors.grey[600]),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 12, color: color ?? Colors.grey[600])),
          ],
        ],
      ),
    );
  }

  Widget _buildSuggestionsSection() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Suggestions pour vous', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                TextButton(onPressed: () {}, child: const Text('Tout voir', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 12))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundImage: suggestion.avatar != null ? NetworkImage(suggestion.avatar!) : null,
                        child: suggestion.avatar == null ? const Icon(Icons.person, size: 28) : null,
                      ),
                      const SizedBox(height: 4),
                      Text(suggestion.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      GestureDetector(
                        onTap: () => _networkService.sendConnectionRequest(suggestion.id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFD4AF37).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [Icon(Icons.person_add, size: 10, color: Color(0xFFD4AF37)), SizedBox(width: 2), Text('+', style: TextStyle(fontSize: 10, color: Color(0xFFD4AF37)))],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunitiesSection() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Communautés populaires', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                TextButton(onPressed: () {}, child: const Text('Tout voir', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 12))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _communities.length,
              itemBuilder: (context, index) {
                final community = _communities[index];
                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: const Color(0xFFD4AF37).withOpacity(0.1),
                        child: Text(community.name.isNotEmpty ? community.name[0].toUpperCase() : '?', style: const TextStyle(fontSize: 24, color: Color(0xFFD4AF37))),
                      ),
                      const SizedBox(height: 4),
                      Text(community.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('${community.membersCount} membres', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIARecommendations() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0B1B3D), Color(0xFF1A2B4D)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildIAItem(Icons.people, '9', 'Personnes'),
          _buildIAItem(Icons.work, '3', 'Opportunités'),
          _buildIAItem(Icons.groups, '5', 'Communautés'),
        ],
      ),
    );
  }

  Widget _buildIAItem(IconData icon, String count, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: const Color(0xFFD4AF37), size: 24),
        ),
        const SizedBox(height: 8),
        Text(count, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
              child: const Icon(Icons.post_add, size: 48, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Text('Aucune publication', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF4B5563))),
            const SizedBox(height: 8),
            const Text('Soyez le premier à partager quelque chose', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showCreatePostDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: const Color(0xFF0B1B3D),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Créer ma première publication'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFD4AF37),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        currentIndex: _selectedNavIndex,
        onTap: (index) {
          setState(() => _selectedNavIndex = index);
          HapticFeedback.lightImpact();
          switch (index) {
            case 0: break;
            case 1: _goToConnexions(); break;
            case 2: _showCreatePostDialog(); break;
            case 3: _goToMessages(); break;
            case 4: break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Réseau'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Créer'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return ScaleTransition(
      scale: _fabAnimationController.drive(Tween<double>(begin: 1.0, end: 1.1)),
      child: FloatingActionButton(
        onPressed: _showCreatePostDialog,
        backgroundColor: const Color(0xFFD4AF37),
        child: const Icon(Icons.edit, color: Color(0xFF0B1B3D)),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 7) return '${dateTime.day}/${dateTime.month}';
    if (diff.inDays >= 1) return 'il y a ${diff.inDays}j';
    if (diff.inHours >= 1) return 'il y a ${diff.inHours}h';
    if (diff.inMinutes >= 1) return 'il y a ${diff.inMinutes}min';
    return 'maintenant';
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return count.toString();
  }
}
