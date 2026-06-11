// lib/models/hashtag.dart
class Hashtag {
  final String id;
  final String name;
  final int postsCount;
  final int trendingScore;
  final DateTime? trendingAt;

  Hashtag({
    required this.id,
    required this.name,
    this.postsCount = 0,
    this.trendingScore = 0,
    this.trendingAt,
  });

  factory Hashtag.fromJson(Map<String, dynamic> json) {
    return Hashtag(
      id: json['id'],
      name: json['name'],
      postsCount: json['posts_count'] ?? 0,
      trendingScore: json['trending_score'] ?? 0,
      trendingAt: json['trending_at'] != null 
          ? DateTime.parse(json['trending_at']) 
          : null,
    );
  }

  String get displayName => '#$name';
}

class HashtagPost {
  final String postId;
  final String hashtagId;

  HashtagPost({required this.postId, required this.hashtagId});
}
