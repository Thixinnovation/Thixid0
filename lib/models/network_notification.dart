class NetworkNotification {
  final String id;
  final String type; // like, comment, connection_request, connection_accepted, generic
  final String title;
  final String body;
  final String? actorId;
  final String? actorName;
  final String? actorAvatar;
  final String? postId;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;

  NetworkNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.actorId,
    this.actorName,
    this.actorAvatar,
    this.postId,
    this.data = const {},
    required this.isRead,
    required this.createdAt,
  });

  factory NetworkNotification.fromJson(Map<String, dynamic> json) {
    final actor = json['actor'] as Map<String, dynamic>?;
    
    return NetworkNotification(
      id: json['id'],
      type: json['type'] ?? 'generic',
      title: json['title'] ?? _getDefaultTitle(json['type']),
      body: json['body'] ?? _getDefaultBody(json['type']),
      actorId: actor?['id'] ?? json['actor_id'],
      actorName: actor?['display_name'] ?? json['actor_name'],
      actorAvatar: actor?['avatar_url'] ?? json['actor_avatar'],
      postId: json['post_id'],
      data: json['data'] ?? {},
      isRead: json['read'] ?? json['is_read'] ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  static String _getDefaultTitle(String type) {
    switch (type) {
      case 'like': return 'Nouveau like';
      case 'comment': return 'Nouveau commentaire';
      case 'connection_request': return 'Demande de connexion';
      case 'connection_accepted': return 'Connexion acceptée';
      default: return 'Notification';
    }
  }

  static String _getDefaultBody(String type) {
    switch (type) {
      case 'like': return 'Quelqu\'un a aimé votre publication';
      case 'comment': return 'Quelqu\'un a commenté votre publication';
      case 'connection_request': return 'Quelqu\'un souhaite se connecter avec vous';
      case 'connection_accepted': return 'Votre demande a été acceptée';
      default: return 'Nouvelle notification';
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'title': title,
    'body': body,
    'actor_id': actorId,
    'actor_name': actorName,
    'actor_avatar': actorAvatar,
    'post_id': postId,
    'data': data,
    'read': isRead,
    'created_at': createdAt.toIso8601String(),
  };

  NetworkNotification copyWith({
    String? id,
    String? type,
    String? title,
    String? body,
    String? actorId,
    String? actorName,
    String? actorAvatar,
    String? postId,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NetworkNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      actorId: actorId ?? this.actorId,
      actorName: actorName ?? this.actorName,
      actorAvatar: actorAvatar ?? this.actorAvatar,
      postId: postId ?? this.postId,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get actorDisplayName => actorName ?? 'Quelqu\'un';
  
  bool get isLike => type == 'like';
  bool get isComment => type == 'comment';
  bool get isConnectionRequest => type == 'connection_request';
  bool get isConnectionAccepted => type == 'connection_accepted';
}
