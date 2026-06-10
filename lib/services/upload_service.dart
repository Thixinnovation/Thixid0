import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;  // ← AJOUTER CET IMPORT

class UploadService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Bucket names
  static const String _publicBucket = 'public';
  static const String _privateBucket = 'private';

  Future<String> uploadPostImage(File image) async {
    try {
      final fileName = 'post_${DateTime.now().millisecondsSinceEpoch}_${basename(image.path)}';
      final filePath = 'network_posts/$fileName';
      
      await _supabase.storage.from(_publicBucket).upload(filePath, image);
      
      final publicUrl = _supabase.storage.from(_publicBucket).getPublicUrl(filePath);
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
      final extension = image.path.split('.').last;
      final fileName = 'avatar_$userId.$extension';
      final filePath = 'avatars/$fileName';
      
      await _supabase.storage.from(_publicBucket).upload(filePath, image);
      
      final publicUrl = _supabase.storage.from(_publicBucket).getPublicUrl(filePath);
      
      // Mettre à jour le profil
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
      final fileName = 'community_banner_$communityId.jpg';
      final filePath = 'community_banners/$fileName';
      
      await _supabase.storage.from(_publicBucket).upload(filePath, image);
      
      final publicUrl = _supabase.storage.from(_publicBucket).getPublicUrl(filePath);
      
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
      final fileName = 'story_${DateTime.now().millisecondsSinceEpoch}_${basename(image.path)}';
      final filePath = 'stories/$fileName';
      
      await _supabase.storage.from(_publicBucket).upload(filePath, image);
      
      final publicUrl = _supabase.storage.from(_publicBucket).getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading story image: $e');
      throw Exception('Failed to upload story image: $e');
    }
  }

  Future<String> uploadDocument(File file, String userId, String type) async {
    try {
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

  Future<void> deleteFile(String url) async {
    try {
      // Extraire le chemin du fichier depuis l'URL
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      
      // Trouver l'index du bucket (généralement après 'storage/v1/object/public/')
      final bucketIndex = pathSegments.indexWhere((s) => s == 'public' || s == 'private');
      if (bucketIndex != -1 && bucketIndex + 1 < pathSegments.length) {
        final bucket = pathSegments[bucketIndex];
        final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
        await _supabase.storage.from(bucket).remove([filePath]);
        debugPrint('File deleted: $filePath');
      }
    } catch (e) {
      debugPrint('Error deleting file: $e');
    }
  }

  // Vérifier si le fichier existe
  Future<bool> fileExists(String url) async {
    try {
      final uri = Uri.parse(url);
      final response = await http.head(uri);  // ← Maintenant http est défini
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
