// lib/services/news_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

import '../models/news_article.dart';

class NewsService {
  final SupabaseClient _supabase;

  NewsService(this._supabase);

  String get currentUserId => _supabase.auth.currentUser?.id ?? '';

  // ============================================================
  // LECTURE DES ARTICLES
  // ============================================================

  Future<List<NewsArticle>> getArticles({
    String? category,
    int limit = 50,
    bool onlyPublished = true,
  }) async {
    try {
      // ✅ CORRECTION : Construire la requête étape par étape
      var query = _supabase
          .from('news_articles')
          .select('*')
          .order('published_at', ascending: false)
          .limit(limit);

      if (onlyPublished) {
        query = query.eq('status', 'published');
      }
      if (category != null && category != 'featured') {
        query = query.eq('category', category);
      }
      if (category == 'featured') {
        query = query.eq('is_featured', true);
      }

      final response = await query;
      final articles = <NewsArticle>[];
      
      for (var e in response as List) {
        final isLiked = await _isArticleLiked(e['id']);
        final isSaved = await _isArticleSaved(e['id']);
        
        articles.add(NewsArticle.fromJson({
          ...e,
          'is_liked': isLiked,
          'is_saved': isSaved,
        }));
      }
      
      return articles;
    } catch (e) {
      debugPrint('❌ Error getArticles: $e');
      return [];
    }
  }

  Future<NewsArticle?> getArticleById(String articleId) async {
    try {
      // ✅ CORRECTION : Requête simple
      final response = await _supabase
          .from('news_articles')
          .select('*')
          .eq('id', articleId)
          .maybeSingle();

      if (response == null) return null;

      final isLiked = await _isArticleLiked(articleId);
      final isSaved = await _isArticleSaved(articleId);

      return NewsArticle.fromJson({
        ...response,
        'is_liked': isLiked,
        'is_saved': isSaved,
      });
    } catch (e) {
      debugPrint('❌ Error getArticleById: $e');
      return null;
    }
  }

  Future<List<NewsArticle>> getBreakingNews() async {
    try {
      // ✅ CORRECTION
      final response = await _supabase
          .from('news_articles')
          .select('*')
          .eq('is_breaking', true)
          .eq('status', 'published')
          .order('published_at', ascending: false)
          .limit(20);

      final articles = <NewsArticle>[];
      for (var e in response as List) {
        articles.add(NewsArticle.fromJson(e));
      }
      return articles;
    } catch (e) {
      debugPrint('❌ Error getBreakingNews: $e');
      return [];
    }
  }

  Future<List<NewsArticle>> getVideos() async {
    try {
      // ✅ CORRECTION
      final response = await _supabase
          .from('news_articles')
          .select('*')
          .not('video_url', 'is', null)
          .eq('status', 'published')
          .order('published_at', ascending: false)
          .limit(20);

      final articles = <NewsArticle>[];
      for (var e in response as List) {
        articles.add(NewsArticle.fromJson(e));
      }
      return articles;
    } catch (e) {
      debugPrint('❌ Error getVideos: $e');
      return [];
    }
  }

  Future<List<NewsArticle>> searchArticles(String query) async {
    try {
      // ✅ CORRECTION : Utiliser or() pour la recherche multiple
      final response = await _supabase
          .from('news_articles')
          .select('*')
          .eq('status', 'published')
          .or('title.ilike.%$query%,content.ilike.%$query%,summary.ilike.%$query%')
          .order('published_at', ascending: false)
          .limit(50);

      final articles = <NewsArticle>[];
      for (var e in response as List) {
        articles.add(NewsArticle.fromJson(e));
      }
      return articles;
    } catch (e) {
      debugPrint('❌ Error searchArticles: $e');
      return [];
    }
  }

  // ============================================================
  // ADMIN - CRUD COMPLET
  // ============================================================

  Future<NewsArticle> createArticle({
    required String title,
    String? summary,
    required String content,
    required String category,
    String? imageUrl,
    String? videoUrl,
    bool isFeatured = false,
    bool isBreaking = false,
    DateTime? publishedAt,
  }) async {
    final currentUserId = this.currentUserId;
    if (currentUserId.isEmpty) throw Exception('Admin non connecté');

    final now = DateTime.now().toIso8601String();
    final publishDate = (publishedAt ?? DateTime.now()).toIso8601String();

    final response = await _supabase.from('news_articles').insert({
      'title': title,
      'summary': summary,
      'content': content,
      'category': category,
      'image_url': imageUrl,
      'video_url': videoUrl,
      'is_featured': isFeatured,
      'is_breaking': isBreaking,
      'status': 'published',
      'published_at': publishDate,
      'created_at': now,
      'updated_at': now,
      'created_by': currentUserId,
    }).select().single();

    return NewsArticle.fromJson(response);
  }

  Future<void> updateArticle(String articleId, Map<String, dynamic> data) async {
    final currentUserId = this.currentUserId;
    if (currentUserId.isEmpty) throw Exception('Admin non connecté');

    await _supabase
        .from('news_articles')
        .update({
          ...data,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', articleId);
  }

  Future<void> deleteArticle(String articleId) async {
    final currentUserId = this.currentUserId;
    if (currentUserId.isEmpty) throw Exception('Admin non connecté');

    await _supabase.from('news_articles').delete().eq('id', articleId);
  }

  // ============================================================
  // INTERACTIONS UTILISATEUR
  // ============================================================

  Future<void> incrementViews(String articleId) async {
    try {
      // ✅ CORRECTION : Méthode alternative sans RPC
      final article = await _supabase
          .from('news_articles')
          .select('views_count')
          .eq('id', articleId)
          .single();
      
      final currentViews = article['views_count'] ?? 0;
      await _supabase
          .from('news_articles')
          .update({'views_count': currentViews + 1})
          .eq('id', articleId);
    } catch (e) {
      debugPrint('❌ Error incrementViews: $e');
    }
  }

  Future<bool> _isArticleLiked(String articleId) async {
    final currentUserId = this.currentUserId;
    if (currentUserId.isEmpty) return false;

    try {
      final response = await _supabase
          .from('news_likes')
          .select('id')
          .eq('article_id', articleId)
          .eq('user_id', currentUserId)
          .maybeSingle();
      return response != null;
    } catch (e) {
      return false;
    }
  }

  Future<void> likeArticle(String articleId) async {
    final currentUserId = this.currentUserId;
    if (currentUserId.isEmpty) return;

    final exists = await _isArticleLiked(articleId);
    if (!exists) {
      await _supabase.from('news_likes').insert({
        'article_id': articleId,
        'user_id': currentUserId,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> unlikeArticle(String articleId) async {
    final currentUserId = this.currentUserId;
    if (currentUserId.isEmpty) return;

    await _supabase
        .from('news_likes')
        .delete()
        .eq('article_id', articleId)
        .eq('user_id', currentUserId);
  }

  Future<bool> _isArticleSaved(String articleId) async {
    final currentUserId = this.currentUserId;
    if (currentUserId.isEmpty) return false;

    try {
      final response = await _supabase
          .from('news_saved')
          .select('id')
          .eq('article_id', articleId)
          .eq('user_id', currentUserId)
          .maybeSingle();
      return response != null;
    } catch (e) {
      return false;
    }
  }

  Future<void> saveArticle(String articleId) async {
    final currentUserId = this.currentUserId;
    if (currentUserId.isEmpty) return;

    final exists = await _isArticleSaved(articleId);
    if (!exists) {
      await _supabase.from('news_saved').insert({
        'article_id': articleId,
        'user_id': currentUserId,
        'saved_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> unsaveArticle(String articleId) async {
    final currentUserId = this.currentUserId;
    if (currentUserId.isEmpty) return;

    await _supabase
        .from('news_saved')
        .delete()
        .eq('article_id', articleId)
        .eq('user_id', currentUserId);
  }

  Future<List<NewsArticle>> getSavedArticles() async {
    final currentUserId = this.currentUserId;
    if (currentUserId.isEmpty) return [];

    try {
      final response = await _supabase
          .from('news_saved')
          .select('article:article_id(*)')
          .eq('user_id', currentUserId)
          .order('saved_at', ascending: false);

      final articles = <NewsArticle>[];
      for (var e in response as List) {
        articles.add(NewsArticle.fromJson({
          ...e['article'],
          'is_saved': true,
        }));
      }
      return articles;
    } catch (e) {
      debugPrint('❌ Error getSavedArticles: $e');
      return [];
    }
  }

  // ============================================================
  // UPLOAD D'IMAGES
  // ============================================================

  Future<String?> uploadImage(String filePath) async {
    try {
      final currentUserId = this.currentUserId;
      if (currentUserId.isEmpty) return null;

      final file = File(filePath);
      final bytes = await file.readAsBytes();
      
      final extension = filePath.split('.').last;
      final fileName = 'news_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final storagePath = 'news_images/$fileName';
      
      await _supabase.storage
          .from('news_images')
          .uploadBinary(storagePath, bytes);
      
      return _supabase.storage.from('news_images').getPublicUrl(storagePath);
    } catch (e) {
      debugPrint('Error uploading news image: $e');
      return null;
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      final uri = Uri.parse(imageUrl);
      final segments = uri.pathSegments;
      final bucketIndex = segments.indexOf('news_images');
      
      if (bucketIndex != -1 && bucketIndex + 1 < segments.length) {
        final filePath = segments.sublist(bucketIndex + 1).join('/');
        await _supabase.storage.from('news_images').remove([filePath]);
      }
    } catch (e) {
      debugPrint('Error deleting news image: $e');
    }
  }
}
