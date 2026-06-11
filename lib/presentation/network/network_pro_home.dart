// lib/presentation/network/network_pro_home.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thix_id/auth/auth_controller.dart';
import 'package:thix_id/models/network_post.dart';
import 'package:thix_id/providers/feed_provider.dart';
import 'widgets/create_post_dialog.dart';

class NetworkProHome extends StatefulWidget {
  const NetworkProHome({super.key});

  @override
  State<NetworkProHome> createState() => _NetworkProHomeState();
}

class _NetworkProHomeState extends State<NetworkProHome> with TickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  bool _loadingPosts = true;
  bool _isRefreshing = false;
  String _feedType = 'smart';
  int _selectedNavIndex = 0;
  final Map<String, AnimationController> _likeAnimations = {};

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllData();
    });

    _setupRealtimeSubscriptions();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    for (var controller in _likeAnimations.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _setupRealtimeSubscriptions() {
    final supabase = Supabase.instance.client;
    final feedProvider = Provider.of<FeedProvider>(context, listen: false);

    supabase.channel('public:posts')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'posts',
          callback: (payload) async {
            if (mounted) {
              await feedProvider.loadFeed(feedType: _feedType);
              setState(() {});
            }
          },
        )
        .subscribe();
  }

  Future<void> _loadAllData() async {
    final feedProvider = Provider.of<FeedProvider>(context, listen: false);
    await feedProvider.loadFeed(feedType: _feedType);
    setState(() => _loadingPosts = false);
  }

  Future<void> _loadPosts() async {
    if (!mounted) return;
    final feedProvider = Provider.of<FeedProvider>(context, listen: false);
    setState(() => _loadingPosts = true);

    try {
      await feedProvider.loadFeed(feedType: _feedType);
      if (mounted) setState(() => _loadingPosts = false);
    } catch (e) {
      debugPrint('❌ Erreur _loadPosts: $e');
      if (mounted) setState(() => _loadingPosts = false);
    }
  }

  Future<void> _onRefresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);

    final feedProvider = Provider.of<FeedProvider>(context, listen: false);
    await feedProvider.loadFeed(feedType: _feedType);

    if (mounted) setState(() => _isRefreshing = false);
  }

  void _changeFeedType(String type) {
    if (_feedType == type) return;
    setState(() => _feedType = type);
    _loadPosts();
  }

  void _showCreatePostDialog() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => const CreatePostDialog(),
    ).then((_) async {
      final feedProvider = Provider.of<FeedProvider>(context, listen: false);
      await feedProvider.loadFeed(feedType: _feedType);
      setState(() {});
    });
  }

  Future<void> _toggleLike(NetworkPost post) async {
    final feedProvider = Provider.of<FeedProvider>(context, listen: false);
    
    if (!_likeAnimations.containsKey(post.id)) {
      _likeAnimations[post.id] = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
    }
    _likeAnimations[post.id]?.forward(from: 0);
    HapticFeedback.lightImpact();
    
    await feedProvider.toggleLike(post.id);
    setState(() {});
  }

  void _showCommentDialog(NetworkPost post) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
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
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Écrivez votre commentaire...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              autofocus: true,
              maxLines: 3,
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
                      if (controller.text.trim().isNotEmpty) {
                        final feedProvider = Provider.of<FeedProvider>(context, listen: false);
                        await feedProvider.addComment(post.id, controller.text.trim());
                        setState(() {});
                        if (mounted) Navigator.pop(context);
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

  void _goToSearch() => context.push('/network/search');
  void _goToNotifications() => context.push('/network/notifications');
  void _goToMessages() => context.push('/network/messages');
  void _goToConnexions() => context.push('/network/connections');
  void _goToProfile() => context.push('/profile');

  @override
  Widget build(BuildContext context) {
    final feedProvider = Provider.of<FeedProvider>(context);
    final posts = feedProvider.posts;
    final isLoading = feedProvider.isLoading;
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
      body: Column(
        children: [
          // Header fixe incurvé
          _buildFixedHeader(auth),
          
          // Contenu scrollable
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: CustomScrollView(
                slivers: [
                  // Espace réduit entre header et posts
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  
                  if ((isLoading || _loadingPosts) && posts.isEmpty)
                    const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
                  else if (posts.isEmpty)
                    SliverFillRemaining(child: _buildEmptyState())
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildPostCard(posts[index]),
                        childCount: posts.length,
                      ),
                    ),
                  
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            ),
          ),
          
          // Bottom Navigation Bar
          _buildBottomNavBar(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // ============================================================
  // HEADER FIXE INCURVÉ
  // ============================================================
  Widget _buildFixedHeader(AuthController auth) {
    final user = auth.currentUser;
    
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B1B3D), Color(0xFF1A2B4D)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                // Ligne 1: Recherche + Logo + Actions
                Row(
                  children: [
                    // Barre de recherche
                    Expanded(
                      child: GestureDetector(
                        onTap: _goToSearch,
                        child: Container(
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              SizedBox(width: 10),
                              Icon(Icons.search, color: Colors.white54, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'Rechercher...',
                                style: TextStyle(color: Colors.white54, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Logo THIX
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFD4AF37), Color(0xFFE5C55E)]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'THIX',
                        style: TextStyle(
                          color: Color(0xFF0B1B3D),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Notifications
                    IconButton(
                      icon: const Icon(Icons.notifications_none, color: Colors.white, size: 20),
                      onPressed: _goToNotifications,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    // Avatar profil
                    GestureDetector(
                      onTap: _goToProfile,
                      child: CircleAvatar(
                        radius: 15,
                        backgroundImage: user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
                        child: user?.photoUrl == null
                            ? const Icon(Icons.person, size: 14, color: Colors.white)
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Ligne 2: Filtres chips
                _buildFilterChips(),
              ],
            ),
          ),
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
    
    return SizedBox(
      height: 32,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _feedType == filter['value'];
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(filter['icon'] as IconData, size: 14, color: isSelected ? const Color(0xFFD4AF37) : Colors.white70),
                  const SizedBox(width: 4),
                  Text(
                    filter['label'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected ? const Color(0xFFD4AF37) : Colors.white70,
                    ),
                  ),
                ],
              ),
              onSelected: (selected) {
                if (selected) _changeFeedType(filter['value'] as String);
              },
              backgroundColor: Colors.white.withOpacity(0.1),
              selectedColor: const Color(0xFFD4AF37).withOpacity(0.2),
              checkmarkColor: const Color(0xFFD4AF37),
              side: BorderSide(color: isSelected ? const Color(0xFFD4AF37) : Colors.white.withOpacity(0.2)),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostCard(NetworkPost post) {
    final hasImage = post.mediaUrl != null && post.mediaUrl!.isNotEmpty;
    final likeAnimation = _likeAnimations[post.id];
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête du post
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: post.authorAvatar != null ? NetworkImage(post.authorAvatar!) : null,
                  child: post.authorAvatar == null ? const Icon(Icons.person, size: 14) : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName ?? 'Utilisateur',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                      Row(
                        children: [
                          Text(
                            post.authorTitle ?? 'Membre',
                            style: TextStyle(fontSize: 9, color: Colors.grey[500]),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '•',
                            style: TextStyle(fontSize: 9, color: Colors.grey[400]),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTimeAgo(post.createdAt),
                            style: TextStyle(fontSize: 9, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz, size: 16, color: Colors.grey),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          
          // Contenu
          if (post.content != null && post.content!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                post.content!,
                style: const TextStyle(fontSize: 12, height: 1.4),
              ),
            ),
          
          // Image
          if (hasImage)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  post.mediaUrl!,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      color: Colors.grey[200],
                      child: const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey)),
                    );
                  },
                ),
              ),
            ),
          
          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                // Like button
                GestureDetector(
                  onTap: () => _toggleLike(post),
                  child: ScaleTransition(
                    scale: likeAnimation != null
                        ? Tween<double>(begin: 0.8, end: 1.2).animate(
                            CurvedAnimation(parent: likeAnimation, curve: Curves.elasticOut),
                          )
                        : const AlwaysStoppedAnimation(1.0),
                    child: Row(
                      children: [
                        Icon(
                          post.isLikedByCurrentUser ? Icons.favorite : Icons.favorite_border,
                          color: post.isLikedByCurrentUser ? Colors.red : Colors.grey[600],
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatCount(post.likesCount),
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Comment button
                GestureDetector(
                  onTap: () => _showCommentDialog(post),
                  child: Row(
                    children: [
                      Icon(Icons.comment_outlined, size: 18, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        _formatCount(post.commentsCount),
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Save button
                GestureDetector(
                  onTap: () {},
                  child: Icon(Icons.bookmark_border, size: 18, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                // Share button
                GestureDetector(
                  onTap: () {},
                  child: Icon(Icons.share_outlined, size: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
              child: const Icon(Icons.post_add, size: 48, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucune publication',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF4B5563)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Soyez le premier à partager quelque chose',
              style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showCreatePostDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: const Color(0xFF0B1B3D),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text('Créer ma première publication', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return ScaleTransition(
      scale: _fabAnimationController.drive(Tween<double>(begin: 1.0, end: 1.08)),
      child: FloatingActionButton(
        onPressed: _showCreatePostDialog,
        backgroundColor: const Color(0xFFD4AF37),
        mini: true,
        child: const Icon(Icons.edit, color: Color(0xFF0B1B3D), size: 20),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFD4AF37),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 9),
        unselectedLabelStyle: const TextStyle(fontSize: 9),
        currentIndex: _selectedNavIndex,
        onTap: (index) {
          setState(() => _selectedNavIndex = index);
          HapticFeedback.lightImpact();
          switch (index) {
            case 0: break;
            case 1: _goToConnexions(); break;
            case 2: _showCreatePostDialog(); break;
            case 3: _goToMessages(); break;
            case 4: _goToProfile(); break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home, size: 20), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.people, size: 20), label: 'Réseau'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle, size: 20), label: 'Créer'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline, size: 20), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline, size: 20), label: 'Profil'),
        ],
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
