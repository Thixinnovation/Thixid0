import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';  // ← AJOUTER CET IMPORT
import 'package:supabase_flutter/supabase_flutter.dart';

class BlockedUsersPage extends StatefulWidget {
  const BlockedUsersPage({super.key});

  @override
  State<BlockedUsersPage> createState() => _BlockedUsersPageState();
}

class _BlockedUsersPageState extends State<BlockedUsersPage> {
  List<Map<String, dynamic>> _blockedUsers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBlockedUsers();
  }

  Future<void> _loadBlockedUsers() async {
    setState(() => _loading = true);
    try {
      final supabase = Supabase.instance.client;
      final currentUserId = supabase.auth.currentUser?.id;

      final response = await supabase
          .from('blocked_users')
          .select('''
            blocked:profiles!blocked_user_id (
              id, display_name, avatar_url, title
            )
          ''')
          .eq('user_id', currentUserId);

      setState(() {
        _blockedUsers = (response as List).map((e) => e['blocked'] as Map<String, dynamic>).toList();
      });
    } catch (e) {
      debugPrint('Error loading blocked users: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _unblockUser(String userId) async {
    try {
      final supabase = Supabase.instance.client;
      final currentUserId = supabase.auth.currentUser?.id;

      await supabase
          .from('blocked_users')
          .delete()
          .eq('user_id', currentUserId)
          .eq('blocked_user_id', userId);

      setState(() {
        _blockedUsers.removeWhere((u) => u['id'] == userId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utilisateur débloqué'), backgroundColor: Colors.green),
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
        title: const Text('Utilisateurs bloqués', style: TextStyle(color: Color(0xFF0B1B3D), fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0B1B3D)),
          onPressed: () => context.pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _blockedUsers.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.block, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Aucun utilisateur bloqué'),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _blockedUsers.length,
                  itemBuilder: (context, index) => _buildBlockedUserTile(_blockedUsers[index]),
                ),
    );
  }

  Widget _buildBlockedUserTile(Map<String, dynamic> user) {
    // ✅ CORRECTION: Extraire les valeurs avec des valeurs par défaut
    final avatarUrl = user['avatar_url'] as String?;
    final displayName = user['display_name'] as String? ?? 'Utilisateur';
    final title = user['title'] as String?;
    final userId = user['id'] as String? ?? '';

    return Container(
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
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
            child: avatarUrl == null ? const Icon(Icons.person) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                if (title != null) 
                  Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () => _unblockUser(userId),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.green),
            ),
            child: const Text('Débloquer', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }
}
