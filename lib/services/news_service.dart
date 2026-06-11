// lib/services/news_service.dart (extrait des méthodes problématiques)
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

import '../models/news_article.dart';

class NewsService {
  final SupabaseClient _supabase;

  NewsService(this._supabase);

  String get currentUserId => _supabase.auth.currentUser?.id ?? '';

  // ============================================================
  // LECTURE DES ARTICLES - CORRIGÉ
  // ============================================================

  Future<List<NewsArticle>> getArticles({
    String? category,
    int limit = 50,
    bool onlyPublished = true,
  }) async {
    try {
      // ✅ CORRECTION : Construire la requête correctement
      PostgrestFilterBuilder query = _supabase
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

  // ... le reste du code (createArticle, updateArticle, deleteArticle, uploadImage, uploadVideo, etc.)
}
