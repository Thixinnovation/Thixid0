// lib/models/network_post.dart
import 'package:flutter/material.dart';

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

  // Constructeur vide pour les tests
  NetworkPost.empty()
      : id = '',
        userId = '',
        userName = '',
        userAvatar = null,
        userTitle = '',
        content = '',
        images = const [],
        likes = 0,
        comments = 0,
        shares = 0,
        isLikedByCurrentUser = false,
        createdAt = DateTime.now();

  // Getters de base
  bool get hasImages => images.isNotEmpty;
  bool get hasContent => content.isNotEmpty;
  bool get hasUserAvatar => userAvatar != null && userAvatar!.isNotEmpty;
  bool get isValid => id.isNotEmpty && userId.isNotEmpty;
  bool get isPopular => likes > 100;
  bool get isViral => shares > 1000;
  
  String get avatarUrl => hasUserAvatar ? userAvatar! : '';
  String get firstImage => hasImages ? images.first : '';
  int get imageCount => images.length;
  String get userInitial => userName.isNotEmpty ? userName[0].toUpperCase() : '?';
  
  String get shortContent => content.length > 150 
      ? '${content.substring(0, 147)}...' 
      : content;
  
  // Formatage des nombres
  String get formattedLikes {
    if (likes >= 1000000) return '${(likes / 1000000).toStringAsFixed(1)}M';
    if (likes >= 1000) return '${(likes / 1000).toStringAsFixed(1)}k';
    return likes.toString();
  }
  
  String get formattedComments {
    if (comments >= 1000000) return '${(comments / 1000000).toStringAsFixed(1)}M';
    if (comments >= 1000) return '${(comments / 1000).toStringAsFixed(1)}k';
    return comments.toString();
  }
  
  String get formattedShares {
    if (shares >= 1000000) return '${(shares / 1000000).toStringAsFixed(1)}M';
    if (shares >= 1000) return '${(shares / 1000).toStringAsFixed(1)}k';
    return shares.toString();
  }
  
  // Temps
  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'à l\'instant';
    if (diff.inHours < 1) return 'il y a ${diff.inMinutes} min';
    if (diff.inDays < 1) return 'il y a ${diff.inHours} h';
    if (diff.inDays < 7) return 'il y a ${diff.inDays} j';
    return 'le ${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }
  
  String get formattedDate => '${createdAt.day}/${createdAt.month}/${createdAt.year} à ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
  
  // Actions
  NetworkPost toggleLike() => copyWith(
    isLikedByCurrentUser: !isLikedByCurrentUser,
    likes: isLikedByCurrentUser ? likes - 1 : likes + 1,
  );
  
  NetworkPost incrementComment() => copyWith(comments: comments + 1);
  NetworkPost decrementComment() => copyWith(comments: comments - 1);
  NetworkPost incrementShare() => copyWith(shares: shares + 1);

  factory NetworkPost.fromJson(Map<String, dynamic> json) {
    final profiles = json['profiles'] as Map<String, dynamic>?;
    
    return NetworkPost(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      userName: profiles?['display_name']?.toString() ?? json['user_name']?.toString() ?? 'Utilisateur',
      userAvatar: profiles?['avatar_url']?.toString() ?? json['user_avatar']?.toString(),
      userTitle: profiles?['title']?.toString() ?? json['user_title']?.toString() ?? 'Membre THIX',
      content: json['content']?.toString() ?? '',
      images: json['images'] != null 
          ? List<String>.from(json['images']) 
          : const [],
      likes: (json['likes_count'] as int?) ?? (json['likes'] as int?) ?? 0,
      comments: (json['comments_count'] as int?) ?? (json['comments'] as int?) ?? 0,
      shares: (json['shares_count'] as int?) ?? (json['shares'] as int?) ?? 0,
      isLikedByCurrentUser: (json['is_liked_by_current_user'] as bool?) ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
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

  @override
  String toString() => 'NetworkPost(id: $id, user: $userName, likes: $likes, comments: $comments)';
}

// Extension pour les listes de posts
extension NetworkPostListExtension on List<NetworkPost> {
  List<NetworkPost> get popular => where((p) => p.isPopular).toList();
  List<NetworkPost> get viral => where((p) => p.isViral).toList();
  List<NetworkPost> get withImages => where((p) => p.hasImages).toList();
  
  int get totalLikes => fold(0, (sum, post) => sum + post.likes);
  int get totalComments => fold(0, (sum, post) => sum + post.comments);
  int get totalShares => fold(0, (sum, post) => sum + post.shares);
  
  Map<DateTime, List<NetworkPost>> groupByDate() {
    final map = <DateTime, List<NetworkPost>>{};
    for (final post in this) {
      final date = DateTime(post.createdAt.year, post.createdAt.month, post.createdAt.day);
      map.putIfAbsent(date, () => []).add(post);
    }
    return map;
  }
}
