import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thix_id/models/network_community.dart';
import 'package:thix_id/services/network_service.dart';

class SearchNetworkPage extends StatefulWidget {
  const SearchNetworkPage({super.key});

  @override
  State<SearchNetworkPage> createState() => _SearchNetworkPageState();
}

class _SearchNetworkPageState extends State<SearchNetworkPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  bool _loading = false;
  late NetworkService _networkService;

  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _posts = [];
  List<NetworkCommunity> _communities = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // ✅ CORRECTION: passer le client Supabase
    _networkService = NetworkService(Supabase.instance.client);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _query = query;
      _loading = true;
    });

    try {
      final users = await _networkService.searchUsers(query);
      final posts = await _networkService.searchPosts(query);
      final communities = await _networkService.searchCommunities(query);

      setState(() {
        _users = users;
        _posts = posts;
        _communities = communities;
      });
    } catch (e) {
      debugPrint('Search error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Recherche', style: TextStyle(color: Color(0xFF0B1B3D), fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFD4AF37),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFD4AF37),
          tabs: const [Tab(text: 'Personnes'), Tab(text: 'Publications'), Tab(text: 'Communautés')],
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _query.isEmpty
                    ? const Center(child: Text('Recherchez des personnes, publications ou communautés'))
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildUsersTab(),
                          _buildPostsTab(),
                          _buildCommunitiesTab(),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _search,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: const Color(0xFF0B1B3D),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text('Rechercher'),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    if (_users.isEmpty) return const Center(child: Text('Aucun utilisateur trouvé'));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _users.length,
      itemBuilder: (context, index) => _buildUserTile(_users[index]),
    );
  }

  Widget _buildUserTile(Map<String, dynamic> user) {
    final avatarUrl = user['avatar_url']?.toString();
    final displayName = user['display_name']?.toString() ?? 'Utilisateur';
    final title = user['title']?.toString();
    final userId = user['id']?.toString() ?? '';

    return GestureDetector(
      onTap: () => context.go('/network/profile/$userId'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
              child: avatarUrl == null ? const Icon(Icons.person) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (title != null) Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFD4AF37))),
              child: const Text('Se connecter', style: TextStyle(fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsTab() {
    if (_posts.isEmpty) return const Center(child: Text('Aucune publication trouvée'));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _posts.length,
      itemBuilder: (context, index) => _buildPostTile(_posts[index]),
    );
  }

  Widget _buildPostTile(Map<String, dynamic> post) {
    final user = post['profiles'] as Map<String, dynamic>?;
    final userName = user?['display_name']?.toString() ?? 'Utilisateur';
    final userAvatar = user?['avatar_url']?.toString();
    final postId = post['id']?.toString() ?? '';
    final content = post['content']?.toString() ?? '';

    return GestureDetector(
      onTap: () => context.go('/network/post/$postId'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: userAvatar != null ? NetworkImage(userAvatar) : null,
                ),
                const SizedBox(width: 8),
                Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),
            Text(content, maxLines: 3, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunitiesTab() {
    if (_communities.isEmpty) return const Center(child: Text('Aucune communauté trouvée'));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _communities.length,
      itemBuilder: (context, index) => _buildCommunityTile(_communities[index]),
    );
  }

  Widget _buildCommunityTile(NetworkCommunity community) {
    return GestureDetector(
      onTap: () => context.go('/network/community/${community.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.groups, color: Color(0xFFD4AF37)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(community.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('${community.membersCount} membres', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFD4AF37))),
              child: const Text('Rejoindre', style: TextStyle(fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }
}
