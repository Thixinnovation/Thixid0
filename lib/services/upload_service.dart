// lib/services/upload_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

class UploadService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Bucket names
  static const String _publicBucket = 'public';
  static const String _privateBucket = 'private';
  
  // Cache pour les URLs
  final Map<String, String> _urlCache = {};
  
  // Tailles maximales (en MB)
  static const int maxImageSizeMB = 10;
  static const int maxDocumentSizeMB = 20;
  static const int maxAvatarSizeMB = 5;

  // ==================== VALIDATIONS ====================

  Future<bool> _validateFileSize(File file, {int maxSizeMB = 10}) async {
    final size = await file.length();
    final sizeInMB = size / (1024 * 1024);
    if (sizeInMB > maxSizeMB) {
      throw Exception('Le fichier ne doit pas dépasser $maxSizeMB MB');
    }
    return true;
  }

  bool _isValidImage(String path) {
    final extension = basename(path).split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);
  }

  bool _isValidDocument(String path) {
    final extension = basename(path).split('.').last.toLowerCase();
    return ['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx', 'csv'].contains(extension);
  }

  // ==================== MÉTHODES PRINCIPALES ====================

  Future<String> uploadPostImage(File image) async {
    try {
      if (!_isValidImage(image.path)) {
        throw Exception('Format d\'image non supporté');
      }
      await _validateFileSize(image, maxSizeMB: maxImageSizeMB);
      
      final fileName = 'post_${DateTime.now().millisecondsSinceEpoch}_${basename(image.path)}';
      final filePath = 'network_posts/$fileName';
      
      await _supabase.storage.from(_publicBucket).upload(filePath, image);
      
      final publicUrl = _supabase.storage.from(_publicBucket).getPublicUrl(filePath);
      _urlCache[filePath] = publicUrl;
      debugPrint('Image uploaded: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading post image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<List<String>> uploadMultipleImages(List<File> images) async {
    final List<String> urls = [];
    for (final image in images) {
      final url = await uploadPostImage(image);
      urls.add(url);
    }
    return urls;
  }

  Future<String> uploadAvatar(File image, String userId) async {
    try {
      if (!_isValidImage(image.path)) {
        throw Exception('Format d\'image non supporté');
      }
      await _validateFileSize(image, maxSizeMB: maxAvatarSizeMB);
      
      final extension = image.path.split('.').last;
      final fileName = 'avatar_$userId.$extension';
      final filePath = 'avatars/$fileName';
      
      await _supabase.storage.from(_publicBucket).upload(filePath, image);
      
      final publicUrl = _supabase.storage.from(_publicBucket).getPublicUrl(filePath);
      _urlCache[filePath] = publicUrl;
      
      await _supabase.from('profiles').update({
        'avatar_url': publicUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
      
      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading avatar: $e');
      throw Exception('Failed to upload avatar: $e');
    }
  }

  Future<String> uploadCommunityBanner(File image, String communityId) async {
    try {
      if (!_isValidImage(image.path)) {
        throw Exception('Format d\'image non supporté');
      }
      await _validateFileSize(image, maxSizeMB: maxImageSizeMB);
      
      final fileName = 'community_banner_$communityId.jpg';
      final filePath = 'community_banners/$fileName';
      
      await _supabase.storage.from(_publicBucket).upload(filePath, image);
      
      final publicUrl = _supabase.storage.from(_publicBucket).getPublicUrl(filePath);
      _urlCache[filePath] = publicUrl;
      
      await _supabase.from('network_communities').update({
        'banner_url': publicUrl,
      }).eq('id', communityId);
      
      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading community banner: $e');
      throw Exception('Failed to upload community banner: $e');
    }
  }

  Future<String> uploadStoryImage(File image) async {
    try {
      if (!_isValidImage(image.path)) {
        throw Exception('Format d\'image non supporté');
      }
      await _validateFileSize(image, maxSizeMB: maxImageSizeMB);
      
      final fileName = 'story_${DateTime.now().millisecondsSinceEpoch}_${basename(image.path)}';
      final filePath = 'stories/$fileName';
      
      await _supabase.storage.from(_publicBucket).upload(filePath, image);
      
      final publicUrl = _supabase.storage.from(_publicBucket).getPublicUrl(filePath);
      _urlCache[filePath] = publicUrl;
      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading story image: $e');
      throw Exception('Failed to upload story image: $e');
    }
  }

  Future<String> uploadDocument(File file, String userId, String type) async {
    try {
      if (!_isValidDocument(file.path)) {
        throw Exception('Type de document non supporté');
      }
      await _validateFileSize(file, maxSizeMB: maxDocumentSizeMB);
      
      final fileName = '${type}_${DateTime.now().millisecondsSinceEpoch}_${basename(file.path)}';
      final filePath = 'documents/$userId/$fileName';
      
      await _supabase.storage.from(_privateBucket).upload(filePath, file);
      
      final publicUrl = _supabase.storage.from(_privateBucket).getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading document: $e');
      throw Exception('Failed to upload document: $e');
    }
  }

  Future<String> uploadFromUrl(String imageUrl, String folder) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to download image from URL');
      }
      
      final tempDir = await Directory.systemTemp.createTemp();
      final fileName = '${folder}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(response.bodyBytes);
      
      final uploadedUrl = await uploadPostImage(file);
      await file.delete();
      await tempDir.delete(recursive: true);
      
      return uploadedUrl;
    } catch (e) {
      debugPrint('Error uploading from URL: $e');
      throw Exception('Failed to upload from URL: $e');
    }
  }

  // ==================== GESTION DES FICHIERS ====================

  Future<void> deleteFile(String url) async {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      
      final bucketIndex = pathSegments.indexWhere((s) => s == 'public' || s == 'private');
      if (bucketIndex != -1 && bucketIndex + 1 < pathSegments.length) {
        final bucket = pathSegments[bucketIndex];
        final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
        await _supabase.storage.from(bucket).remove([filePath]);
        _urlCache.remove(filePath);
        debugPrint('File deleted: $filePath');
      }
    } catch (e) {
      debugPrint('Error deleting file: $e');
    }
  }

  Future<void> deleteMultipleFiles(List<String> urls) async {
    for (final url in urls) {
      await deleteFile(url);
    }
  }

  Future<bool> fileExists(String url) async {
    try {
      final uri = Uri.parse(url);
      final response = await http.head(uri);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  String getCachedUrl(String filePath) {
    if (_urlCache.containsKey(filePath)) {
      return _urlCache[filePath]!;
    }
    final url = _supabase.storage.from(_publicBucket).getPublicUrl(filePath);
    _urlCache[filePath] = url;
    return url;
  }

  void clearCache() => _urlCache.clear();

  // ==================== BUCKET MANAGEMENT ====================

  Future<void> ensureBucketsExist() async {
    await _ensureBucketExists(_publicBucket);
    await _ensureBucketExists(_privateBucket);
  }

  Future<void> _ensureBucketExists(String bucketName) async {
    try {
      final buckets = await _supabase.storage.listBuckets();
      final exists = buckets.any((b) => b.id == bucketName);
      
      if (!exists) {
        await _supabase.storage.createBucket(bucketName);
        debugPrint('Bucket created: $bucketName');
      }
    } catch (e) {
      debugPrint('Error ensuring bucket exists: $e');
    }
  }
}
