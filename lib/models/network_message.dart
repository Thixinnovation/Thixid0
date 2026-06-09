class NetworkMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String receiverId;
  final String content;
  final bool isRead;
  final DateTime createdAt;

  NetworkMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  factory NetworkMessage.fromJson(Map<String, dynamic> json) {
    return NetworkMessage(
      id: json['id'],
      conversationId: json['conversation_id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      content: json['content'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'conversation_id': conversationId,
    'sender_id': senderId,
    'receiver_id': receiverId,
    'content': content,
    'is_read': isRead,
    'created_at': createdAt.toIso8601String(),
  };

  bool get isSentByMe => senderId == _currentUserId;
  
  static String? _currentUserId;
  static void setCurrentUserId(String userId) => _currentUserId = userId;
}

class Conversation {
  final String id;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserAvatar;
  final String? lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;
  final bool lastMessageIsFromMe;

  Conversation({
    required this.id,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatar,
    this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCount,
    required this.lastMessageIsFromMe,
  });

  factory Conversation.fromJson(Map<String, dynamic> json, String currentUserId) {
    final isUser1 = json['user1_id'] == currentUserId;
    final otherUser = isUser1 ? json['user2'] : json['user1'];
    
    return Conversation(
      id: json['id'],
      otherUserId: otherUser['id'],
      otherUserName: otherUser['display_name'],
      otherUserAvatar: otherUser['avatar_url'],
      lastMessage: json['last_message'],
      lastMessageAt: DateTime.parse(json['last_message_at']),
      unreadCount: json['unread_count'] ?? 0,
      lastMessageIsFromMe: json['last_sender_id'] == currentUserId,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'other_user_id': otherUserId,
    'other_user_name': otherUserName,
    'other_user_avatar': otherUserAvatar,
    'last_message': lastMessage,
    'last_message_at': lastMessageAt.toIso8601String(),
    'unread_count': unreadCount,
  };
}
