// lib/models/story.dart
import 'package:flutter/material.dart';

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
    final userData = json['users'] as Map<String, dynamic>?;
    
    return Story(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      userName: userData?['display_name']?.toString() ?? 'Utilisateur',
      userAvatar: userData?['photo_url']?.toString(),
      userProfession: userData?['profession']?.toString(),
      mediaUrl: json['media_url']?.toString() ?? '',
      mediaType: json['media_type']?.toString() ?? 'image',
      content: json['content']?.toString(),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
      expiresAt: json['expires_at'] != null 
          ? DateTime.parse(json['expires_at'] as String) 
          : DateTime.now().add(const Duration(hours: 24)),
      isActive: json['is_active'] as bool? ?? true,
      isViewed: json['is_viewed'] as bool? ?? false,
      viewsCount: json['views_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
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
