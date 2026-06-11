// lib/models/network_post.dart

class NetworkPost {
  final String id;
  final String userId;
  final String authorName;
  final String? authorAvatar;
  final String? authorTitle;
  final String? content;
  final String? mediaUrl;
  final String mediaType;
  final bool isPublic;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final DateTime createdAt;
  bool isLikedByCurrentUser;
  bool isSavedByCurrentUser;
  
  final int? viralScore;
  final int? viewCount;

  NetworkPost({
    required this.id,
    required this.userId,
    required this.authorName,
    this.authorAvatar,
    this.authorTitle,
    this.content,
    this.mediaUrl,
    this.mediaType = 'none',
    this.isPublic = true,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    required this.createdAt,
    this.isLikedByCurrentUser = false,
    this.isSavedByCurrentUser = false,
    this.viralScore,
    this.viewCount,
  });

  bool get isViral {
    if (viralScore != null) return viralScore! > 100;
    
    final ageInHours = DateTime.now().difference(createdAt).inHours;
    if (ageInHours < 1) return false;
    
    final engagementScore = (likesCount * 1) + (commentsCount * 3) + (sharesCount * 5);
    final engagementPerHour = engagementScore / ageInHours;
    
    return engagementPerHour > 10;
  }

  bool get hasImages => mediaType == 'image' && mediaUrl != null;
  bool get hasVideo => mediaType == 'video';
  bool get hasDocument => mediaType == 'document';
  
  double get engagementRate {
    final total = likesCount + commentsCount + sharesCount;
    final views = viewCount ?? (likesCount * 10); 
    return views > 0 ? total / views : 0;
  }

  factory NetworkPost.fromJson(Map<String, dynamic> json) {
    return NetworkPost(
      id: json['id'],
      userId: json['user_id'],
      authorName: json['author_name'] ?? json['users']?['display_name'] ?? 'Utilisateur',
      authorAvatar: json['author_avatar'] ?? json['users']?['photo_url'],
      authorTitle: json['author_title'] ?? json['users']?['profession'],
      content: json['content'],
      mediaUrl: json['media_url'],
      mediaType: json['media_type'] ?? 'none',
      isPublic: json['is_public'] ?? true,
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      sharesCount: json['shares_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      isLikedByCurrentUser: json['is_liked'] ?? false,
      isSavedByCurrentUser: json['is_saved_by_current_user'] ?? false, // ← CORRIGÉ
      viralScore: json['viral_score'],
      viewCount: json['view_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'media_url': mediaUrl,
      'media_type': mediaType,
      'is_public': isPublic,
      'shares_count': sharesCount,  // ← AJOUTÉ
      'created_at': createdAt.toIso8601String(),
    };
  }
  
  NetworkPost copyWith({
    String? id,
    String? userId,
    String? authorName,
    String? authorAvatar,
    String? authorTitle,
    String? content,
    String? mediaUrl,
    String? mediaType,
    bool? isPublic,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    DateTime? createdAt,
    bool? isLikedByCurrentUser,
    bool? isSavedByCurrentUser,
    int? viralScore,
    int? viewCount,
  }) {
    return NetworkPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      authorTitle: authorTitle ?? this.authorTitle,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      isPublic: isPublic ?? this.isPublic,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      createdAt: createdAt ?? this.createdAt,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
      isSavedByCurrentUser: isSavedByCurrentUser ?? this.isSavedByCurrentUser,
      viralScore: viralScore ?? this.viralScore,
      viewCount: viewCount ?? this.viewCount,
    );
  }
}

// Extension pour les fonctionnalités supplémentaires
extension NetworkPostListExtension on List<NetworkPost> {
  
  List<NetworkPost> get viral => where((p) => p.isViral).toList();
  List<NetworkPost> get withImages => where((p) => p.hasImages).toList();
  List<NetworkPost> get withVideos => where((p) => p.hasVideo).toList();
  List<NetworkPost> get popular => where((p) => p.likesCount > 100).toList();
  
  List<NetworkPost> get recent {
    final twentyFourHoursAgo = DateTime.now().subtract(const Duration(hours: 24));
    return where((p) => p.createdAt.isAfter(twentyFourHoursAgo)).toList();
  }
  
  List<NetworkPost> sortedByEngagement() {
    final list = [...this];
    list.sort((a, b) => b.engagementRate.compareTo(a.engagementRate));
    return list;
  }
  
  List<NetworkPost> sortedByViral() {
    final list = [...this];
    list.sort((a, b) {
      final aScore = (a.likesCount * 1) + (a.commentsCount * 3) + (a.sharesCount * 5);
      final bScore = (b.likesCount * 1) + (b.commentsCount * 3) + (b.sharesCount * 5);
      return bScore.compareTo(aScore);
    });
    return list;
  }
  
  int get totalLikes => fold(0, (sum, post) => sum + post.likesCount);
  int get totalComments => fold(0, (sum, post) => sum + post.commentsCount);
  int get totalShares => fold(0, (sum, post) => sum + post.sharesCount);
  int get totalEngagement => totalLikes + totalComments + totalShares;
  
  double get averageEngagementRate {
    if (isEmpty) return 0;
    return fold(0.0, (sum, post) => sum + post.engagementRate) / length;
  }
  
  Map<DateTime, List<NetworkPost>> groupByDate() {
    final map = <DateTime, List<NetworkPost>>{};
    for (final post in this) {
      final date = DateTime(post.createdAt.year, post.createdAt.month, post.createdAt.day);
      map.putIfAbsent(date, () => []).add(post);
    }
    return map;
  }
  
  Map<String, List<NetworkPost>> groupByUser() {
    final map = <String, List<NetworkPost>>{};
    for (final post in this) {
      map.putIfAbsent(post.userId, () => []).add(post);
    }
    return map;
  }
  
  List<NetworkPost> fromUser(String userId) {
    return where((p) => p.userId == userId).toList();
  }
  
  List<NetworkPost> topLiked({int limit = 10}) {
    final sorted = [...this]..sort((a, b) => b.likesCount.compareTo(a.likesCount));
    return sorted.take(limit).toList();
  }
  
  List<NetworkPost> topCommented({int limit = 10}) {
    final sorted = [...this]..sort((a, b) => b.commentsCount.compareTo(a.commentsCount));
    return sorted.take(limit).toList();
  }
  
  List<NetworkPost> topShared({int limit = 10}) {
    final sorted = [...this]..sort((a, b) => b.sharesCount.compareTo(a.sharesCount));
    return sorted.take(limit).toList();
  }
}
