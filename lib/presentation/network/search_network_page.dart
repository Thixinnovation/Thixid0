import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _posts = [];
  List<Map<String, dynamic>> _communities = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      final supabase = Supabase.instance.client;
      final currentUserId = supabase.auth.currentUser?.id;

      // Recherche d'utilisateurs
      final users = await supabase
          .from('profiles')
          .select('id, display_name, avatar_url, title')
          .ilike('display_name', '%$query%')
          .neq('id', currentUserId)
          .limit(20);

      // Recherche de publications
      final posts = await supabase
          .from('network_posts')
          .select('''
            *,
            profiles!user_id (display_name, avatar_url, title)
          ''')
          .ilike('content', '%$query%')
          .order('created_at', ascending: false)
          .limit(20);

      // Recherche de communautés
      final communities = await supabase
          .from('network_communities')
          .select('*')
          .ilike('name', '%$query%')
          .limit(10);

      setState(() {
        _users = (users as List).cast<Map<String, dynamic>>();
        _posts = (posts as List).cast<Map<String, dynamic>>();
        _communities = (communities as List).cast<Map<String, dynamic>>();
      });
    } catch (e) {
      print('Search error: $e');
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
          tabs: const [
            Tab(text: 'Personnes'),
            Tab(text: 'Publications'),
            Tab(text: 'Communautés'),
          ],
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
    if (_users.isEmpty) {
      return const Center(child: Text('Aucun utilisateur trouvé'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _users.length,
      itemBuilder: (context, index) => _buildUserTile(_users[index]),
    );
  }

  Widget _buildUserTile(Map<String, dynamic> user) {
    return GestureDetector(
      onTap: () => context.push('/network/profile/${user['id']}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: user['avatar_url'] != null ? NetworkImage(user['avatar_url']) : null,
              child: user['avatar_url'] == null ? const Icon(Icons.person) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user['display_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (user['title'] != null) Text(user['title'], style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
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
    if (_posts.isEmpty) {
      return const Center(child: Text('Aucune publication trouvée'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _posts.length,
      itemBuilder: (context, index) => _buildPostTile(_posts[index]),
    );
  }

  Widget _buildPostTile(Map<String, dynamic> post) {
    final user = post['profiles'];
    return GestureDetector(
      onTap: () => context.push('/network/post/${post['id']}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 16, backgroundImage: user['avatar_url'] != null ? NetworkImage(user['avatar_url']) : null),
                const SizedBox(width: 8),
                Text(user['display_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),
            Text(post['content'], maxLines: 3, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunitiesTab() {
    if (_communities.isEmpty) {
      return const Center(child: Text('Aucune communauté trouvée'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _communities.length,
      itemBuilder: (context, index) => _buildCommunityTile(_communities[index]),
    );
  }

  Widget _buildCommunityTile(Map<String, dynamic> community) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
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
                Text(community['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('${community['members_count'] ?? 0} membres', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
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
    );
  }
}
