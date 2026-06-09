class NetworkPost {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String userTitle;
  final String content;
  final List<String> images;
  final int likes;
  final int comments;
  final int shares;
  final bool isLikedByCurrentUser;
  final DateTime createdAt;

  NetworkPost({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.userTitle,
    required this.content,
    required this.images,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.isLikedByCurrentUser,
    required this.createdAt,
  });

  factory NetworkPost.fromJson(Map<String, dynamic> json) {
    // Gérer les données imbriquées de profiles
    final profiles = json['profiles'] as Map<String, dynamic>?;
    
    return NetworkPost(
      id: json['id'],
      userId: json['user_id'],
      userName: profiles?['display_name'] ?? json['user_name'] ?? 'Utilisateur',
      userAvatar: profiles?['avatar_url'] ?? json['user_avatar'],
      userTitle: profiles?['title'] ?? json['user_title'] ?? 'Membre THIX',
      content: json['content'] ?? '',
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      likes: json['likes_count'] ?? json['likes'] ?? 0,
      comments: json['comments_count'] ?? json['comments'] ?? 0,
      shares: json['shares_count'] ?? json['shares'] ?? 0,
      isLikedByCurrentUser: json['is_liked_by_current_user'] ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'user_name': userName,
    'user_avatar': userAvatar,
    'user_title': userTitle,
    'content': content,
    'images': images,
    'likes_count': likes,
    'comments_count': comments,
    'shares_count': shares,
    'created_at': createdAt.toIso8601String(),
  };

  NetworkPost copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    String? userTitle,
    String? content,
    List<String>? images,
    int? likes,
    int? comments,
    int? shares,
    bool? isLikedByCurrentUser,
    DateTime? createdAt,
  }) {
    return NetworkPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      userTitle: userTitle ?? this.userTitle,
      content: content ?? this.content,
      images: images ?? this.images,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
