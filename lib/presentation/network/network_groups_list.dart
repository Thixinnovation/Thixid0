import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thix_id/models/network_community.dart';

class NetworkGroupsList extends StatefulWidget {
  const NetworkGroupsList({super.key});

  @override
  State<NetworkGroupsList> createState() => _NetworkGroupsListState();
}

class _NetworkGroupsListState extends State<NetworkGroupsList> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<NetworkCommunity> _myGroups = [];
  List<NetworkCommunity> _suggestedGroups = [];
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

      final myGroupsData = await supabase
          .from('community_members')
          .select('communities!community_id(*)')
          .eq('user_id', currentUserId);

      final suggestedData = await supabase
          .from('network_communities')
          .select('*')
          .order('members_count', ascending: false)
          .limit(10);

      setState(() {
        _myGroups = (myGroupsData as List).map((e) => NetworkCommunity.fromJson(e['communities'] as Map<String, dynamic>)).toList();
        _suggestedGroups = (suggestedData as List).map((e) => NetworkCommunity.fromJson(e as Map<String, dynamic>)).toList();
      });
    } catch (e) {
      debugPrint('Error loading groups: $e');
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
        title: const Text('Groupes', style: TextStyle(color: Color(0xFF0B1B3D), fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0B1B3D)),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFD4AF37),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFD4AF37),
          tabs: const [Tab(text: 'Mes groupes'), Tab(text: 'Suggestions')],
        ),
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

  Widget _buildGroupsList(List<NetworkCommunity> groups, {required bool isMyGroups}) {
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

  Widget _buildGroupCard(NetworkCommunity group, {required bool isMyGroups}) {
    // ✅ Extraction sécurisée avec 'as'
    final bannerUrl = group.bannerUrl as String?;
    final hasBanner = bannerUrl != null && bannerUrl.isNotEmpty;

    return GestureDetector(
      onTap: () => context.go('/network/community/${group.id}'),
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
                image: hasBanner
                    ? DecorationImage(image: NetworkImage(bannerUrl), fit: BoxFit.cover)
                    : null,
              ),
              child: !hasBanner
                  ? const Icon(Icons.groups, size: 30, color: Color(0xFFD4AF37))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('${group.membersCount} membres', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () {},
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
}
