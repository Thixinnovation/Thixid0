import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thix_id/services/network_service.dart';
import 'package:thix_id/models/network_message.dart';
import 'chat_screen.dart';

class ConversationsList extends StatefulWidget {
  const ConversationsList({super.key});

  @override
  State<ConversationsList> createState() => _ConversationsListState();
}

class _ConversationsListState extends State<ConversationsList> {
  late NetworkService _networkService;
  List<Conversation> _conversations = [];
  bool _loading = true;
  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    _networkService = NetworkService(Supabase.instance.client);
    _loadConversations();
    _listenForNewMessages();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  void _listenForNewMessages() {
    final supabase = Supabase.instance.client;
    final currentUserId = supabase.auth.currentUser?.id;
    
    if (currentUserId == null) return;
    
    _channel = supabase
        .channel('messages_$currentUserId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'network_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'receiver_id',
            value: currentUserId,
          ),
          callback: (payload) {
            _loadConversations();
          },
        )
        .subscribe();
  }

  Future<void> _loadConversations() async {
    setState(() => _loading = true);
    try {
      final convs = await _networkService.getConversations();
      if (mounted) setState(() => _conversations = convs);
    } catch (e) {
      debugPrint('Error loading conversations: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteConversation(Conversation conv) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la conversation'),
        content: const Text('Voulez-vous vraiment supprimer cette conversation ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        final supabase = Supabase.instance.client;
        final currentUserId = supabase.auth.currentUser?.id;
        
        if (currentUserId == null) return;
        
        await supabase
            .from('network_messages')
            .delete()
            .or('sender_id.eq.${conv.otherUserId},receiver_id.eq.${conv.otherUserId}')
            .or('sender_id.eq.$currentUserId,receiver_id.eq.$currentUserId');
        
        await _loadConversations();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Conversation supprimée'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        debugPrint('Error deleting conversation: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _showConversationOptions(Conversation conv) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Supprimer la conversation', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteConversation(conv);
              },
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
    if (diff.inDays > 0) return 'il y a ${diff.inDays}j';
    if (diff.inHours > 0) return 'il y a ${diff.inHours}h';
    if (diff.inMinutes > 0) return 'il y a ${diff.inMinutes}min';
    return 'maintenant';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Messages', style: TextStyle(color: Color(0xFF0B1B3D), fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0B1B3D)),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF0B1B3D)),
            onPressed: _loadConversations,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _conversations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text('Aucune conversation', style: TextStyle(color: Colors.grey.shade600)),
                      const SizedBox(height: 8),
                      Text(
                        'Commencez à discuter avec vos connexions',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
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
    final otherUserAvatar = conv.otherUserAvatar;
    final otherUserName = conv.otherUserName;
    final lastMessage = conv.lastMessage ?? 'Démarrer une conversation';
    final unreadCount = conv.unreadCount;
    final lastMessageIsFromMe = conv.lastMessageIsFromMe;
    final lastMessageAt = conv.lastMessageAt;

    return GestureDetector(
      onTap: () => _openChat(conv),
      onLongPress: () => _showConversationOptions(conv),
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
              backgroundImage: otherUserAvatar != null && otherUserAvatar.isNotEmpty
                  ? NetworkImage(otherUserAvatar)
                  : null,
              child: otherUserAvatar == null || otherUserAvatar.isEmpty
                  ? const Icon(Icons.person, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    otherUserName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage,
                    style: TextStyle(
                      fontSize: 13,
                      color: unreadCount > 0 && !lastMessageIsFromMe
                          ? const Color(0xFF0B1B3D)
                          : Colors.grey.shade600,
                      fontWeight: unreadCount > 0 && !lastMessageIsFromMe ? FontWeight.w600 : FontWeight.normal,
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
                Text(_formatTime(lastMessageAt), style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                const SizedBox(height: 4),
                if (unreadCount > 0 && !lastMessageIsFromMe)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Color(0xFFD4AF37), shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      '$unreadCount',
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
}
