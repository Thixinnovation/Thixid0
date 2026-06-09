import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';  // ← AJOUTER
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thix_id/services/network_service.dart';
import 'chat_screen.dart';

class ConversationsList extends StatefulWidget {
  const ConversationsList({super.key});

  @override
  State<ConversationsList> createState() => _ConversationsListState();
}

class _ConversationsListState extends State<ConversationsList> {
  late NetworkService _networkService;
  List<Conversation> _conversations = [];  // ✅ CORRECTION: utiliser List<Conversation>
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _networkService = NetworkService(Supabase.instance.client);
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() => _loading = true);
    try {
      final convs = await _networkService.getConversations();
      setState(() => _conversations = convs);
    } catch (e) {
      debugPrint('Error loading conversations: $e');
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
        title: const Text('Messages', style: TextStyle(color: Color(0xFF0B1B3D), fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _conversations.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Aucune conversation'),
                      Text('Commencez à discuter avec vos connexions'),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadConversations,
                  child: ListView.builder(
                    itemCount: _conversations.length,
                    itemBuilder: (context, index) => _buildConversationTile(_conversations[index]),
                  ),
                ),
    );
  }

  Widget _buildConversationTile(Conversation conv) {
    return GestureDetector(
      onTap: () => _openChat(conv),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: conv.otherUserAvatar != null ? NetworkImage(conv.otherUserAvatar!) : null,
              child: conv.otherUserAvatar == null ? const Icon(Icons.person, color: Colors.grey) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(conv.otherUserName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(
                    conv.lastMessage ?? 'Démarrer une conversation',
                    style: TextStyle(
                      fontSize: 13,
                      color: conv.unreadCount > 0 && !conv.lastMessageIsFromMe
                          ? const Color(0xFF0B1B3D)
                          : Colors.grey.shade600,
                      fontWeight: conv.unreadCount > 0 && !conv.lastMessageIsFromMe ? FontWeight.w600 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_formatTime(conv.lastMessageAt), style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                const SizedBox(height: 4),
                if (conv.unreadCount > 0 && !conv.lastMessageIsFromMe)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Color(0xFFD4AF37), shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      '${conv.unreadCount}',
                      style: const TextStyle(color: Color(0xFF0B1B3D), fontSize: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openChat(Conversation conv) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          userId: conv.otherUserId,
          userName: conv.otherUserName,
          userAvatar: conv.otherUserAvatar,
        ),
      ),
    ).then((_) => _loadConversations());
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays > 7) return '${date.day}/${date.month}';
    if (diff.inDays > 0) return '${diff.inDays}j';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}min';
    return 'maintenant';
  }
}
