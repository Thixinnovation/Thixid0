class NetworkCommunity {
  final String id;
  final String name;
  final String? description;
  final String? bannerUrl;
  final int membersCount;
  final int postsCount;
  final String? createdBy;
  final String? creatorName;
  final DateTime createdAt;
  final bool isMember;

  NetworkCommunity({
    required this.id,
    required this.name,
    this.description,
    this.bannerUrl,
    required this.membersCount,
    required this.postsCount,
    this.createdBy,
    this.creatorName,
    required this.createdAt,
    this.isMember = false,
  });

  factory NetworkCommunity.fromJson(Map<String, dynamic> json) {
    final creator = json['creator'] as Map<String, dynamic>?;
    
    return NetworkCommunity(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      bannerUrl: json['banner_url'],
      membersCount: json['members_count'] ?? 0,
      postsCount: json['posts_count'] ?? 0,
      createdBy: json['created_by'],
      creatorName: creator?['display_name'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      isMember: json['is_member'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'banner_url': bannerUrl,
    'members_count': membersCount,
    'posts_count': postsCount,
    'created_by': createdBy,
    'created_at': createdAt.toIso8601String(),
  };

  NetworkCommunity copyWith({
    String? id,
    String? name,
    String? description,
    String? bannerUrl,
    int? membersCount,
    int? postsCount,
    String? createdBy,
    DateTime? createdAt,
    bool? isMember,
  }) {
    return NetworkCommunity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      membersCount: membersCount ?? this.membersCount,
      postsCount: postsCount ?? this.postsCount,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      isMember: isMember ?? this.isMember,
    );
  }
}

class CommunityMember {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String userTitle;
  final String? role; // admin, moderator, member
  final DateTime joinedAt;

  CommunityMember({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.userTitle,
    this.role,
    required this.joinedAt,
  });

  factory CommunityMember.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    
    return CommunityMember(
      id: json['id'],
      userId: user?['id'] ?? json['user_id'],
      userName: user?['display_name'] ?? 'Utilisateur',
      userAvatar: user?['avatar_url'],
      userTitle: user?['title'] ?? 'Membre',
      role: json['role'] ?? 'member',
      joinedAt: DateTime.parse(json['joined_at']),
    );
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'user_name': userName,
    'user_avatar': userAvatar,
    'user_title': userTitle,
    'role': role,
    'joined_at': joinedAt.toIso8601String(),
  };
}
