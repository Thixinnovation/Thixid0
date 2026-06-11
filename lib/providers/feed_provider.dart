// lib/providers/feed_provider.dart
import 'package:flutter/material.dart';
import '../services/network_service.dart';
import '../models/network_post.dart';

class FeedProvider extends ChangeNotifier {
  final NetworkService _networkService;
  
  List<NetworkPost> _posts = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String _currentFeedType = 'smart';
  String? _error;
  
  FeedProvider(this._networkService);
  
  // Getters
  List<NetworkPost> get posts => _posts;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String get currentFeedType => _currentFeedType;
  String? get error => _error;
  
  // ============================================================
  // CHARGEMENT DU FEED
  // ============================================================
  
  Future<void> loadFeed({String? feedType, int limit = 20}) async {
    if (_isLoading) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      if (feedType != null) _currentFeedType = feedType;
      
      late List<NetworkPost> newPosts;
      
      switch (_currentFeedType) {
        case 'smart':
          newPosts = await _networkService.getSmartFeed(limit: limit);
          break;
        case 'popular':
          final allPosts = await _networkService.getFeedPosts(limit: 50);
          allPosts.sort((a, b) => b.likesCount.compareTo(a.likesCount));
          newPosts = allPosts.take(limit).toList();
          break;
        default:
          newPosts = await _networkService.getFeedPosts(limit: limit);
      }
      
      _posts = newPosts;
      _hasMore = newPosts.length >= limit;
      
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ FeedProvider loadFeed error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // ============================================================
  // CRÉATION DE POST
  // ============================================================
  
  Future<bool> createPost(String content, List<String> images) async {
    try {
      debugPrint('📝 FeedProvider: création du post...');
      
      final postId = await _networkService.createPost(content, images);
      
      if (postId.isEmpty) {
        debugPrint('❌ FeedProvider: pas d\'ID retourné');
        return false;
      }
      
      debugPrint('✅ FeedProvider: post créé avec ID: $postId');
      
      // Recharger tout le feed
      await loadFeed(feedType: _currentFeedType);
      debugPrint('🔄 FeedProvider: feed rechargé, ${_posts.length} posts');
      
      return true;
    } catch (e) {
      debugPrint('❌ FeedProvider createPost error: $e');
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // ============================================================
  // INTERACTIONS (LIKE, COMMENTAIRE)
  // ============================================================
  
  Future<void> toggleLike(String postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;
    
    final post = _posts[index];
    final wasLiked = post.isLikedByCurrentUser;
    
    // Optimistic update
    _posts[index] = post.copyWith(
      isLikedByCurrentUser: !wasLiked,
      likesCount: wasLiked ? post.likesCount - 1 : post.likesCount + 1,
    );
    notifyListeners();
    
    try {
      if (wasLiked) {
        await _networkService.unlikePost(postId);
      } else {
        await _networkService.likePost(postId);
      }
    } catch (e) {
      // Revert on error
      _posts[index] = post;
      notifyListeners();
      debugPrint('❌ FeedProvider toggleLike error: $e');
    }
  }
  
  Future<void> addComment(String postId, String comment) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;
    
    final post = _posts[index];
    
    // Optimistic update
    _posts[index] = post.copyWith(
      commentsCount: post.commentsCount + 1,
    );
    notifyListeners();
    
    try {
      await _networkService.addComment(postId, comment);
    } catch (e) {
      // Revert on error
      _posts[index] = post.copyWith(
        commentsCount: post.commentsCount,
      );
      notifyListeners();
      debugPrint('❌ FeedProvider addComment error: $e');
    }
  }
  
  // ============================================================
  // SAUVEGARDER
  // ============================================================
  
  Future<void> savePost(String postId) async {
    try {
      await _networkService.savePost(postId);
      debugPrint('✅ FeedProvider: post $postId sauvegardé');
    } catch (e) {
      debugPrint('❌ FeedProvider savePost error: $e');
      rethrow;
    }
  }
  
  // ============================================================
  // PARTAGER
  // ============================================================
  
  Future<void> sharePost(String postId) async {
    try {
      await _networkService.sharePost(postId);
      debugPrint('✅ FeedProvider: post $postId partagé');
    } catch (e) {
      debugPrint('❌ FeedProvider sharePost error: $e');
      rethrow;
    }
  }
  
  // ============================================================
  // SUPPRIMER
  // ============================================================
  
  Future<void> deletePost(String postId) async {
    try {
      await _networkService.deletePost(postId);
      debugPrint('✅ FeedProvider: post $postId supprimé');
      
      // Recharger le feed après suppression
      await loadFeed(feedType: _currentFeedType);
    } catch (e) {
      debugPrint('❌ FeedProvider deletePost error: $e');
      rethrow;
    }
  }
  
  // ============================================================
  // SIGNALER
  // ============================================================
  
  Future<void> reportPost(String postId, String reason) async {
    try {
      await _networkService.reportPost(postId, reason);
      debugPrint('✅ FeedProvider: post $postId signalé pour: $reason');
    } catch (e) {
      debugPrint('❌ FeedProvider reportPost error: $e');
      rethrow;
    }
  }
  
  // ============================================================
  // UTILITAIRES
  // ============================================================
  
  void clearPosts() {
    _posts = [];
    _error = null;
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
