import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thix_id/auth/auth_controller.dart';
import 'package:thix_id/services/network_service.dart';
import 'package:thix_id/models/network_post.dart';
import 'package:thix_id/models/network_story.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late NetworkService _networkService;
  
  List<NetworkPost> _posts = [];
  List<NetworkStory> _stories = [];
  
  bool _loadingPosts = true;
  bool _loadingStories = true;
  int _unreadNotifications = 0;
  int _selectedIndex = 0;

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
      _loadStories(),
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

  Future<void> _loadStories() async {
    setState(() => _loadingStories = true);
    try {
      final stories = await _networkService.getActiveStories();
      setState(() => _stories = stories);
    } catch (e) {
      debugPrint('Error loading stories: $e');
    } finally {
      setState(() => _loadingStories = false);
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

  void _onBottomNavTap(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0: // Accueil
        break;
      case 1: // Réseau
        context.push('/network-pro');
        break;
      case 2: // Créer
        _showCreatePostDialog();
        break;
      case 3: // Messages
        context.push('/network/messages');
        break;
      case 4: // Profil
        context.push('/user-dashboard');
        break;
    }
  }

  void _showCreatePostDialog() {
    context.push('/network-pro');
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

  void _likePost(NetworkPost post) async {
    if (post.isLikedByCurrentUser) {
      await _networkService.unlikePost(post.id);
    } else {
      await _networkService.likePost(post.id);
    }
    await _loadPosts();
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 7) {
      return 'le ${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return 'il y a ${difference.inDays} j';
    } else if (difference.inHours > 0) {
      return 'il y a ${difference.inHours} h';
    } else if (difference.inMinutes > 0) {
      return 'il y a ${difference.inMinutes} min';
    } else {
      return 'à l\'instant';
    }
  }

  void _showPostOptions(NetworkPost post) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.flag, color: Colors.red),
              title: const Text('Signaler'),
              onTap: () {
                Navigator.pop(context);
                _reportPost(post.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.visibility_off, color: Colors.orange),
              title: const Text('Masquer'),
              onTap: () {
                Navigator.pop(context);
                _hidePost(post.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.green),
              title: const Text('Partager'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _hidePost(String postId) async {
    await _networkService.hidePost(postId);
    await _loadPosts();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Publication masquée'), backgroundColor: Colors.orange),
      );
    }
  }

  Future<void> _reportPost(String postId) async {
    await _networkService.reportPost(postId, 'Signalé par utilisateur');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Publication signalée'), backgroundColor: Colors.orange),
      );
    }
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
              const Text('Connectez-vous pour accéder à THIX'),
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
      backgroundColor: const Color(0xffF5F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xff081A3A),
        elevation: 0,
        title: const Text(
          "THIX RÉSEAU PRO",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: _goToSearch,
          ),
          const SizedBox(width: 4),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.white),
                onPressed: _showNotifications,
              ),
              if (_unreadNotifications > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
                    child: Text(
                      '$_unreadNotifications',
                      style: const TextStyle(color: Colors.white, fontSize: 8),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            onPressed: _goToMessages,
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff081A3A),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: _showCreatePostDialog,
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xff081A3A),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Accueil"),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: "Réseau"),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), label: "Créer"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_outlined), label: "Messages"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profil"),
        ],
      ),
      body: Column(
        children: [
          /// SEARCH BAR
          GestureDetector(
            onTap: _goToSearch,
            child: Container(
              margin: const EdgeInsets.all(15),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.grey),
                  SizedBox(width: 10),
                  Text("Rechercher...", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),

          /// STORIES
          if (_loadingStories)
            const SizedBox(
              height: 95,
              child: Center(child: CircularProgressIndicator()),
            )
          else
            SizedBox(
              height: 95,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _stories.length > 5 ? 5 : _stories.length,
                itemBuilder: (context, index) {
                  final story = _stories[index];
                  return Container(
                    width: 75,
                    margin: const EdgeInsets.only(left: 12),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: const Color(0xff081A3A),
                          backgroundImage: story.userAvatar != null
                              ? NetworkImage(story.userAvatar!)
                              : null,
                          child: story.userAvatar == null
                              ? Text(
                                  story.userName.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                )
                              : null,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          story.userName.length > 8
                              ? '${story.userName.substring(0, 8)}...'
                              : story.userName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

          /// FEED
          if (_loadingPosts)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_posts.isEmpty)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.post_add, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Aucune publication'),
                    Text('Soyez le premier à partager'),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                  final post = _posts[index];
                  return _buildPostCard(post);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPostCard(NetworkPost post) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage: post.userAvatar != null
                      ? NetworkImage(post.userAvatar!)
                      : null,
                  child: post.userAvatar == null
                      ? Text(
                          post.userName.substring(0, 1).toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _getTimeAgo(post.createdAt),
                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showPostOptions(post),
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
          ),

          // Contenu
          if (post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(post.content),
            ),

          const SizedBox(height: 15),

          // Image
          if (post.images.isNotEmpty)
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: post.images.length,
                itemBuilder: (context, imgIndex) => Padding(
                  padding: const EdgeInsets.only(left: 15, right: imgIndex == post.images.length - 1 ? 15 : 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      post.images[imgIndex],
                      width: MediaQuery.of(context).size.width - 30,
                      height: 220,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: MediaQuery.of(context).size.width - 30,
                        height: 220,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 15),

          // Stats - CORRECTION : utilisation de likes, comments, shares
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("❤️ ${post.likes}"),
                Text("💬 ${post.comments}"),
                Text("↗ ${post.shares}"),
              ],
            ),
          ),

          const Divider(),

          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () => _likePost(post),
                  child: Icon(
                    post.isLikedByCurrentUser ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                    color: post.isLikedByCurrentUser ? Colors.blue : Colors.grey,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/network/post/${post.id}'),
                  child: const Icon(Icons.comment_outlined, color: Colors.grey),
                ),
                GestureDetector(
                  onTap: () {},
                  child: const Icon(Icons.share_outlined, color: Colors.grey),
                ),
                GestureDetector(
                  onTap: () {},
                  child: const Icon(Icons.send_outlined, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
