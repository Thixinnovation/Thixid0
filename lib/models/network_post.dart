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
  
  // Propriétés supplémentaires pour les filtres
  final int? viralScore;  // Score de viralité (basé sur likes/comments/shares)
  final int? viewCount;   // Nombre de vues

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

  // Vérifier si le post est viral (score > 100 ou ratio engagement élevé)
  bool get isViral {
    if (viralScore != null) return viralScore! > 100;
    
    // Calcul simple de viralité: (likes * 1 + comments * 3 + shares * 5) / age_en_heures
    final ageInHours = DateTime.now().difference(createdAt).inHours;
    if (ageInHours < 1) return false;
    
    final engagementScore = (likesCount * 1) + (commentsCount * 3) + (sharesCount * 5);
    final engagementPerHour = engagementScore / ageInHours;
    
    return engagementPerHour > 10; // Plus de 10 interactions par heure = viral
  }

  // Vérifier si le post contient des images
  bool get hasImages => mediaType == 'image' && mediaUrl != null;
  
  // Vérifier si le post contient une vidéo
  bool get hasVideo => mediaType == 'video';
  
  // Vérifier si le post contient un document
  bool get hasDocument => mediaType == 'document';
  
  // Taux d'engagement
  double get engagementRate {
    final total = likesCount + commentsCount + sharesCount;
    // Simuler un nombre de vues si non disponible
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
      isSavedByCurrentUser: json['is_saved'] ?? false,
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
      'created_at': createdAt.toIso8601String(),
    };
  }
  
  NetworkPost copyWith({
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    bool? isLikedByCurrentUser,
    bool? isSavedByCurrentUser,
  }) {
    return NetworkPost(
      id: id,
      userId: userId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      authorTitle: authorTitle,
      content: content,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      isPublic: isPublic,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      createdAt: createdAt,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
      isSavedByCurrentUser: isSavedByCurrentUser ?? this.isSavedByCurrentUser,
      viralScore: viralScore,
      viewCount: viewCount,
    );
  }
}

// Extension pour les fonctionnalités supplémentaires sur List<NetworkPost>
extension NetworkPostListExtension on List<NetworkPost> {
  
  // Filtrer les posts viraux
  List<NetworkPost> get viral => where((p) => p.isViral).toList();
  
  // Filtrer les posts avec images
  List<NetworkPost> get withImages => where((p) => p.hasImages).toList();
  
  // Filtrer les posts avec vidéos
  List<NetworkPost> get withVideos => where((p) => p.hasVideo).toList();
  
  // Filtrer les posts populaires (plus de 100 likes)
  List<NetworkPost> get popular => where((p) => p.likesCount > 100).toList();
  
  // Filtrer les posts récents (moins de 24h)
  List<NetworkPost> get recent {
    final twentyFourHoursAgo = DateTime.now().subtract(const Duration(hours: 24));
    return where((p) => p.createdAt.isAfter(twentyFourHoursAgo)).toList();
  }
  
  // Trier par engagement (du plus engagé au moins engagé)
  List<NetworkPost> sortedByEngagement() {
    final list = [...this];
    list.sort((a, b) => b.engagementRate.compareTo(a.engagementRate));
    return list;
  }
  
  // Trier par viralité
  List<NetworkPost> sortedByViral() {
    final list = [...this];
    list.sort((a, b) {
      final aScore = (a.likesCount * 1) + (a.commentsCount * 3) + (a.sharesCount * 5);
      final bScore = (b.likesCount * 1) + (b.commentsCount * 3) + (b.sharesCount * 5);
      return bScore.compareTo(aScore);
    });
    return list;
  }
  
  // Calculer le total des likes
  int get totalLikes => fold(0, (sum, post) => sum + post.likesCount);
  
  // Calculer le total des commentaires
  int get totalComments => fold(0, (sum, post) => sum + post.commentsCount);
  
  // Calculer le total des partages
  int get totalShares => fold(0, (sum, post) => sum + post.sharesCount);
  
  // Calculer l'engagement total
  int get totalEngagement => totalLikes + totalComments + totalShares;
  
  // Taux d'engagement moyen
  double get averageEngagementRate {
    if (isEmpty) return 0;
    return fold(0.0, (sum, post) => sum + post.engagementRate) / length;
  }
  
  // Grouper par date
  Map<DateTime, List<NetworkPost>> groupByDate() {
    final map = <DateTime, List<NetworkPost>>{};
    for (final post in this) {
      final date = DateTime(post.createdAt.year, post.createdAt.month, post.createdAt.day);
      map.putIfAbsent(date, () => []).add(post);
    }
    return map;
  }
  
  // Grouper par utilisateur
  Map<String, List<NetworkPost>> groupByUser() {
    final map = <String, List<NetworkPost>>{};
    for (final post in this) {
      map.putIfAbsent(post.userId, () => []).add(post);
    }
    return map;
  }
  
  // Obtenir les posts d'un utilisateur spécifique
  List<NetworkPost> fromUser(String userId) {
    return where((p) => p.userId == userId).toList();
  }
  
  // Obtenir les posts les plus likés
  List<NetworkPost> topLiked({int limit = 10}) {
    final sorted = [...this]..sort((a, b) => b.likesCount.compareTo(a.likesCount));
    return sorted.take(limit).toList();
  }
  
  // Obtenir les posts les plus commentés
  List<NetworkPost> topCommented({int limit = 10}) {
    final sorted = [...this]..sort((a, b) => b.commentsCount.compareTo(a.commentsCount));
    return sorted.take(limit).toList();
  }
  
  // Obtenir les posts les plus partagés
  List<NetworkPost> topShared({int limit = 10}) {
    final sorted = [...this]..sort((a, b) => b.sharesCount.compareTo(a.sharesCount));
    return sorted.take(limit).toList();
  }
}
