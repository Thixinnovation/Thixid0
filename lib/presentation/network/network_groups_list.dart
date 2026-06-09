import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NetworkGroupsList extends StatefulWidget {
  const NetworkGroupsList({super.key});

  @override
  State<NetworkGroupsList> createState() => _NetworkGroupsListState();
}

class _NetworkGroupsListState extends State<NetworkGroupsList> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _myGroups = [];
  List<Map<String, dynamic>> _suggestedGroups = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadGroups();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadGroups() async {
    setState(() => _loading = true);
    try {
      final supabase = Supabase.instance.client;
      final currentUserId = supabase.auth.currentUser?.id;

      // Mes groupes
      final myGroups = await supabase
          .from('community_members')
          .select('''
            communities!community_id (
              id, name, description, members_count, banner_url, created_at
            )
          ''')
          .eq('user_id', currentUserId);

      // Groupes suggérés (populaires)
      final suggested = await supabase
          .from('network_communities')
          .select('*')
          .order('members_count', ascending: false)
          .limit(10);

      setState(() {
        _myGroups = (myGroups as List).map((e) => e['communities'] as Map<String, dynamic>).toList();
        _suggestedGroups = (suggested as List).cast<Map<String, dynamic>>();
      });
    } catch (e) {
      print('Error loading groups: $e');
      _loadMockGroups();
    } finally {
      setState(() => _loading = false);
    }
  }

  void _loadMockGroups() {
    setState(() {
      _myGroups = [
        {'id': '1', 'name': 'Développeurs Flutter RDC', 'members_count': 1250, 'banner_url': null},
        {'id': '2', 'name': 'Fintech Africa', 'members_count': 3400, 'banner_url': null},
      ];
      _suggestedGroups = [
        {'id': '3', 'name': 'IA & Innovation', 'members_count': 9200, 'description': 'Communauté sur l\'intelligence artificielle'},
        {'id': '4', 'name': 'Entrepreneurs Afrique', 'members_count': 24500, 'description': 'Pour les entrepreneurs africains'},
        {'id': '5', 'name': 'Marketing Digital', 'members_count': 5600, 'description': 'Stratégies marketing digitales'},
        {'id': '6', 'name': 'UX/UI Design', 'members_count': 3800, 'description': 'Design d\'interfaces utilisateur'},
      ];
    });
  }

  Future<void> _joinGroup(String groupId) async {
    try {
      final supabase = Supabase.instance.client;
      final currentUserId = supabase.auth.currentUser?.id;

      await supabase.from('community_members').insert({
        'community_id': groupId,
        'user_id': currentUserId,
        'joined_at': DateTime.now().toIso8601String(),
      });

      // Mettre à jour le compteur
      await supabase.rpc('increment_group_members', params: {'group_id': groupId});

      await _loadGroups();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Groupe rejoint !'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _leaveGroup(String groupId) async {
    try {
      final supabase = Supabase.instance.client;
      final currentUserId = supabase.auth.currentUser?.id;

      await supabase
          .from('community_members')
          .delete()
          .eq('community_id', groupId)
          .eq('user_id', currentUserId);

      await supabase.rpc('decrement_group_members', params: {'group_id': groupId});

      await _loadGroups();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Groupe quitté'), backgroundColor: Colors.orange),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Groupes', style: TextStyle(color: Color(0xFF0B1B3D), fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFD4AF37),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFD4AF37),
          tabs: const [
            Tab(text: 'Mes groupes'),
            Tab(text: 'Suggestions'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF0B1B3D)),
            onPressed: () => _showCreateGroupDialog(),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildGroupsList(_myGroups, isMyGroups: true),
                _buildGroupsList(_suggestedGroups, isMyGroups: false),
              ],
            ),
    );
  }

  Widget _buildGroupsList(List<Map<String, dynamic>> groups, {required bool isMyGroups}) {
    if (groups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isMyGroups ? Icons.groups : Icons.explore, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(isMyGroups ? 'Aucun groupe rejoint' : 'Aucune suggestion'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groups.length,
      itemBuilder: (context, index) => _buildGroupCard(groups[index], isMyGroups: isMyGroups),
    );
  }

  Widget _buildGroupCard(Map<String, dynamic> group, {required bool isMyGroups}) {
    return GestureDetector(
      onTap: () => context.push('/network/community/${group['id']}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                image: group['banner_url'] != null
                    ? DecorationImage(image: NetworkImage(group['banner_url']), fit: BoxFit.cover)
                    : null,
              ),
              child: group['banner_url'] == null
                  ? const Icon(Icons.groups, size: 30, color: Color(0xFFD4AF37))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('${group['members_count'] ?? 0} membres', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  if (group['description'] != null && !isMyGroups) ...[
                    const SizedBox(height: 4),
                    Text(group['description'], maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                  ],
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () => isMyGroups ? _leaveGroup(group['id']) : _joinGroup(group['id']),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: isMyGroups ? Colors.red : const Color(0xFFD4AF37)),
              ),
              child: Text(
                isMyGroups ? 'Quitter' : 'Rejoindre',
                style: TextStyle(color: isMyGroups ? Colors.red : const Color(0xFFD4AF37)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateGroupDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Créer un groupe'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nom du groupe', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              // Logique de création
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fonctionnalité à venir'), backgroundColor: Colors.orange),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }
}
