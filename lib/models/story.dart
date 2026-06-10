class Story {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String? userProfession;
  final String mediaUrl;
  final String mediaType;
  final String? content;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isActive;
  final bool isViewed;
  final int viewsCount;

  Story({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    this.userProfession,
    required this.mediaUrl,
    required this.mediaType,
    this.content,
    required this.createdAt,
    required this.expiresAt,
    required this.isActive,
    required this.isViewed,
    required this.viewsCount,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    // Récupérer les données utilisateur depuis la relation
    final userData = json['users'] as Map<String, dynamic>?;
    
    return Story(
      id: json['id'],
      userId: json['user_id'],
      userName: userData?['display_name'] ?? 'Utilisateur',
      userAvatar: userData?['photo_url'],
      userProfession: userData?['profession'],
      mediaUrl: json['media_url'],
      mediaType: json['media_type'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      expiresAt: DateTime.parse(json['expires_at']),
      isActive: json['is_active'] ?? true,
      isViewed: json['is_viewed'] ?? false,
      viewsCount: json['views_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'media_url': mediaUrl,
      'media_type': mediaType,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'is_active': isActive,
      'views_count': viewsCount,
    };
  }
}
