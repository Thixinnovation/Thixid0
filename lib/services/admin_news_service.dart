// lib/services/admin_news_service.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thix_id/supabase/supabase_config.dart';

class AdminNewsService {
  // ⚠️ Table corrigée pour correspondre à ton système
  static const String table = 'news_articles';  // ← au lieu de 'thix_news'
  static const String coverBucketDefault = 'news_images';  // ← bucket corrigé

  final SupabaseClient _client;

  AdminNewsService({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  Future<List<Map<String, dynamic>>> listNews() async {
    try {
      final res = await _client
          .from(table)
          .select('*')
          .order('published_at', ascending: false);  // ← order par published_at
      return (res is List) ? res.cast<Map<String, dynamic>>() : [];
    } catch (e) {
      debugPrint('AdminNewsService.listNews error: $e');
      rethrow;
    }
  }

  Future<String> upsertNews({
    String? id,
    required String title,
    String? summary,           // ← renamed (était subtitle)
    required String category,
    String? source,            // ← optionnel
    String? severity,          // ← optionnel
    required String content,
    bool isFeatured = false,   // ← default false
    String? imageUrl,          // ← nouvelle propriété
    String? videoUrl,          // ← nouvelle propriété
    bool isBreaking = false,   // ← nouvelle propriété
    String status = 'published', // ← default published
  }) async {
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      final data = {
        'title': title,
        'summary': summary,              // ← au lieu de subtitle
        'category': category,
        'content': content,
        'is_featured': isFeatured,
        'is_breaking': isBreaking,       // ← nouveau
        'status': status,
        'updated_at': now,
        if (source != null && source.isNotEmpty) 'source': source,
        if (severity != null && severity.isNotEmpty) 'severity': severity,
        if (imageUrl != null && imageUrl.isNotEmpty) 'image_url': imageUrl,
        if (videoUrl != null && videoUrl.isNotEmpty) 'video_url': videoUrl,
      };

      if (id == null || id.isEmpty) {
        data['created_at'] = now;
        data['published_at'] = now;      // ← ajouté
        final res = await _client.from(table).insert(data).select().single();
        return res['id'].toString();
      } else {
        await _client.from(table).update(data).eq('id', id);
        return id;
      }
    } catch (e) {
      debugPrint('AdminNewsService.upsertNews error: $e');
      rethrow;
    }
  }

  // ⚠️ Méthode à adapter pour ton système
  Future<void> updateCoverImage({
    required String newsId,
    required String bucket,
    required String storagePath,
  }) async {
    try {
      // Dans ton système, l'image est stockée dans image_url
      await _client.from(table).update({
        'image_url': _getPublicUrl(bucket, storagePath),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', newsId);
    } catch (e) {
      debugPrint('AdminNewsService.updateCoverImage error: $e');
      rethrow;
    }
  }

  String _getPublicUrl(String bucket, String path) {
    return _client.storage.from(bucket).getPublicUrl(path);
  }

  Future<void> deleteNews({required String id}) async {
    try {
      await _client.from(table).delete().eq('id', id);
    } catch (e) {
      debugPrint('AdminNewsService.deleteNews error: $e');
      rethrow;
    }
  }

  // ⭐ Nouvelle méthode pour uploader une image
  Future<String?> uploadImage(String filePath) async {
    try {
      final currentUserId = _client.auth.currentUser?.id;
      if (currentUserId == null) return null;

      final file = File(filePath);
      final bytes = await file.readAsBytes();
      
      final extension = filePath.split('.').last;
      final fileName = 'img_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final storagePath = '$currentUserId/$fileName';
      
      await _client.storage
          .from(coverBucketDefault)
          .uploadBinary(storagePath, bytes);
      
      return _client.storage.from(coverBucketDefault).getPublicUrl(storagePath);
    } catch (e) {
      debugPrint('AdminNewsService.uploadImage error: $e');
      return null;
    }
  }

  // ⭐ Nouvelle méthode pour uploader une vidéo
  Future<String?> uploadVideo(String filePath) async {
    try {
      final currentUserId = _client.auth.currentUser?.id;
      if (currentUserId == null) return null;

      final file = File(filePath);
      final bytes = await file.readAsBytes();
      
      final extension = filePath.split('.').last;
      final fileName = 'video_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final storagePath = '$currentUserId/$fileName';
      
      await _client.storage
          .from('news_videos')
          .uploadBinary(storagePath, bytes);
      
      return _client.storage.from('news_videos').getPublicUrl(storagePath);
    } catch (e) {
      debugPrint('AdminNewsService.uploadVideo error: $e');
      return null;
    }
  }
}
