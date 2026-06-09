class HealthArticle {
  final String id;
  final String title;
  final String content;
  final String? imageUrl;
  final String? author;
  final int readTime;
  final List<String> tags;
  final bool isPublished;
  final int viewsCount;
  final DateTime createdAt;

  HealthArticle({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    this.author,
    required this.readTime,
    this.tags = const [],
    required this.isPublished,
    this.viewsCount = 0,
    required this.createdAt,
  });

  factory HealthArticle.fromJson(Map<String, dynamic> json) {
    final tagsList = json['tags'] as List? ?? [];
    
    return HealthArticle(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      imageUrl: json['image_url'],
      author: json['author'],
      readTime: json['read_time'] ?? 3,
      tags: tagsList.map((t) => t.toString()).toList(),
      isPublished: json['is_published'] ?? true,
      viewsCount: json['views_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'image_url': imageUrl,
    'author': author,
    'read_time': readTime,
    'tags': tags,
    'is_published': isPublished,
    'views_count': viewsCount,
    'created_at': createdAt.toIso8601String(),
  };

  String get excerpt => content.length > 150 ? '${content.substring(0, 150)}...' : content;
  String get formattedDate => '${createdAt.day}/${createdAt.month}/${createdAt.year}';
}
