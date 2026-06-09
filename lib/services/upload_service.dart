import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart';

class UploadService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> uploadPostImage(File image) async {
    final fileName = 'post_${DateTime.now().millisecondsSinceEpoch}_${basename(image.path)}';
    final filePath = 'network_posts/$fileName';
    
    await _supabase.storage.from('public').upload(filePath, image);
    
    final publicUrl = _supabase.storage.from('public').getPublicUrl(filePath);
    return publicUrl;
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
    final extension = image.path.split('.').last;
    final fileName = 'avatar_$userId.$extension';
    final filePath = 'avatars/$fileName';
    
    await _supabase.storage.from('public').upload(filePath, image);
    
    final publicUrl = _supabase.storage.from('public').getPublicUrl(filePath);
    
    // Mettre à jour le profil
    await _supabase.from('profiles').update({
      'avatar_url': publicUrl,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);
    
    return publicUrl;
  }

  Future<String> uploadCommunityBanner(File image, String communityId) async {
    final fileName = 'community_banner_$communityId.jpg';
    final filePath = 'community_banners/$fileName';
    
    await _supabase.storage.from('public').upload(filePath, image);
    
    final publicUrl = _supabase.storage.from('public').getPublicUrl(filePath);
    
    await _supabase.from('network_communities').update({
      'banner_url': publicUrl,
    }).eq('id', communityId);
    
    return publicUrl;
  }

  Future<String> uploadStoryImage(File image) async {
    final fileName = 'story_${DateTime.now().millisecondsSinceEpoch}_${basename(image.path)}';
    final filePath = 'stories/$fileName';
    
    await _supabase.storage.from('public').upload(filePath, image);
    
    final publicUrl = _supabase.storage.from('public').getPublicUrl(filePath);
    return publicUrl;
  }

  Future<String> uploadDocument(File file, String userId, String type) async {
    final fileName = '${type}_${DateTime.now().millisecondsSinceEpoch}_${basename(file.path)}';
    final filePath = 'documents/$userId/$fileName';
    
    await _supabase.storage.from('private').upload(filePath, file);
    
    final publicUrl = _supabase.storage.from('private').getPublicUrl(filePath);
    return publicUrl;
  }

  Future<void> deleteFile(String url) async {
    try {
      // Extraire le chemin du fichier depuis l'URL
      final uri = Uri.parse(url);
      final path = uri.pathSegments.skip(2).join('/');
      await _supabase.storage.from('public').remove([path]);
    } catch (e) {
      debugPrint('Error deleting file: $e');
    }
  }
}
