class NetworkStory {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String userTitle;
  final String imageUrl;
  final int duration; // en secondes
  final bool isActive;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isViewed;

  NetworkStory({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.userTitle,
    required this.imageUrl,
    required this.duration,
    required this.isActive,
    required this.createdAt,
    required this.expiresAt,
    this.isViewed = false,
  });

  factory NetworkStory.fromJson(Map<String, dynamic> json) {
    final profiles = json['profiles'] as Map<String, dynamic>?;
    
    return NetworkStory(
      id: json['id'],
      userId: json['user_id'],
      userName: profiles?['display_name'] ?? 'Utilisateur',
      userAvatar: profiles?['avatar_url'],
      userTitle: profiles?['title'] ?? 'Membre THIX',
      imageUrl: json['image_url'],
      duration: json['duration'] ?? 24,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      expiresAt: DateTime.parse(json['expires_at']),
      isViewed: json['is_viewed'] ?? false,
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isCurrentUser => userId == _currentUserId;
  
  static String? _currentUserId;
  static void setCurrentUserId(String id) => _currentUserId = id;
}
