// lib/providers/news_provider.dart
import 'package:flutter/material.dart';
import '../services/news_service.dart';
import '../models/news_article.dart';

class NewsProvider extends ChangeNotifier {
  final NewsService _newsService;

  List<NewsArticle> _articles = [];
  List<NewsArticle> _videos = [];
  List<NewsArticle> _breakingNews = [];
  List<NewsArticle> _savedArticles = [];
  bool _isLoading = false;
  String? _error;
  String _currentCategory = 'featured';
  String? _searchQuery;

  NewsProvider(this._newsService);

  // Getters
  List<NewsArticle> get articles => _articles;
  List<NewsArticle> get videos => _videos;
  List<NewsArticle> get breakingNews => _breakingNews;
  List<NewsArticle> get savedArticles => _savedArticles;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentCategory => _currentCategory;

  NewsArticle? get featuredArticle {
    return _articles.firstWhere(
      (a) => a.isFeatured,
      orElse: () => _articles.isNotEmpty ? _articles.first : null,
    );
  }

  List<NewsArticle> get recentArticles {
    return _articles.where((a) => !a.isFeatured).take(10).toList();
  }

  // ============================================================
  // CHARGEMENT DES DONNÉES
  // ============================================================

  Future<void> fetchArticles({String? category}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newCategory = category ?? _currentCategory;
      _currentCategory = newCategory;
      
      _articles = await _newsService.getArticles(category: newCategory);
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ fetchArticles error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchVideos() async {
    try {
      _videos = await _newsService.getVideos();
      notifyListeners();
    } catch (e) {
      debugPrint('❌ fetchVideos error: $e');
    }
  }

  Future<void> fetchBreakingNews() async {
    try {
      _breakingNews = await _newsService.getBreakingNews();
      notifyListeners();
    } catch (e) {
      debugPrint('❌ fetchBreakingNews error: $e');
    }
  }

  Future<NewsArticle?> fetchArticleById(String id) async {
    try {
      final article = await _newsService.getArticleById(id);
      return article;
    } catch (e) {
      debugPrint('❌ fetchArticleById error: $e');
      return null;
    }
  }

  Future<List<NewsArticle>> fetchArticlesByCategory(String category) async {
    try {
      return await _newsService.getArticles(category: category);
    } catch (e) {
      debugPrint('❌ fetchArticlesByCategory error: $e');
      return [];
    }
  }

  Future<List<NewsArticle>> searchArticles(String query) async {
    _searchQuery = query;
    _isLoading = true;
    notifyListeners();

    try {
      final results = await _newsService.searchArticles(query);
      return results;
    } catch (e) {
      _error = e.toString();
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // INTERACTIONS
  // ============================================================

  Future<void> incrementViews(String articleId) async {
    await _newsService.incrementViews(articleId);
  }

  Future<void> toggleLike(String articleId) async {
    final index = _articles.indexWhere((a) => a.id == articleId);
    if (index != -1) {
      final article = _articles[index];
      if (article.isLiked) {
        await _newsService.unlikeArticle(articleId);
        _articles[index] = article.copyWith(isLiked: false);
      } else {
        await _newsService.likeArticle(articleId);
        _articles[index] = article.copyWith(isLiked: true);
      }
      notifyListeners();
    }
  }

  Future<void> saveArticle(String articleId) async {
    await _newsService.saveArticle(articleId);
    
    // Mettre à jour dans articles
    final index = _articles.indexWhere((a) => a.id == articleId);
    if (index != -1) {
      _articles[index] = _articles[index].copyWith(isSaved: true);
    }
    
    // Recharger les favoris
    await loadSavedArticles();
    notifyListeners();
  }

  Future<void> unsaveArticle(String articleId) async {
    await _newsService.unsaveArticle(articleId);
    
    // Mettre à jour dans articles
    final index = _articles.indexWhere((a) => a.id == articleId);
    if (index != -1) {
      _articles[index] = _articles[index].copyWith(isSaved: false);
    }
    
    // Recharger les favoris
    await loadSavedArticles();
    notifyListeners();
  }

  Future<bool> isArticleSaved(String articleId) async {
    final saved = await _newsService.getSavedArticles();
    return saved.any((a) => a.id == articleId);
  }

  Future<void> loadSavedArticles() async {
    try {
      _savedArticles = await _newsService.getSavedArticles();
      notifyListeners();
    } catch (e) {
      debugPrint('❌ loadSavedArticles error: $e');
    }
  }

  // ============================================================
  // ADMIN
  // ============================================================

  Future<NewsArticle?> createArticle({
    required String title,
    String? summary,
    required String content,
    required String category,
    String? imageUrl,
    String? videoUrl,
    bool isFeatured = false,
    bool isBreaking = false,
  }) async {
    try {
      final article = await _newsService.createArticle(
        title: title,
        summary: summary,
        content: content,
        category: category,
        imageUrl: imageUrl,
        videoUrl: videoUrl,
        isFeatured: isFeatured,
        isBreaking: isBreaking,
      );
      
      // Recharger les articles
      await fetchArticles();
      
      return article;
    } catch (e) {
      debugPrint('❌ createArticle error: $e');
      return null;
    }
  }

  Future<void> updateArticle(String articleId, Map<String, dynamic> data) async {
    try {
      await _newsService.updateArticle(articleId, data);
      await fetchArticles();
    } catch (e) {
      debugPrint('❌ updateArticle error: $e');
    }
  }

  Future<void> deleteArticle(String articleId) async {
    try {
      await _newsService.deleteArticle(articleId);
      await fetchArticles();
    } catch (e) {
      debugPrint('❌ deleteArticle error: $e');
    }
  }

  // ============================================================
  // UPLOAD
  // ============================================================

  Future<String?> uploadImage(String filePath) async {
    return await _newsService.uploadImage(filePath);
  }

  // ============================================================
  // UTILITAIRES
  // ============================================================

  void setCategory(String category) {
    if (_currentCategory == category) return;
    _currentCategory = category;
    fetchArticles(category: category);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void refresh() {
    fetchArticles();
    fetchVideos();
    fetchBreakingNews();
    loadSavedArticles();
  }
}
