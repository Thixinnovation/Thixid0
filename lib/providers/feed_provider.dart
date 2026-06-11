// lib/providers/feed_provider.dart
import 'package:flutter/material.dart';
import '../services/network_service.dart';
import '../models/network_post.dart';

class FeedProvider extends ChangeNotifier {
  final NetworkService _networkService;
  
  List<NetworkPost> _posts = [];
  bool _isLoading = false;
  String _currentFeedType = 'smart';
  
  FeedProvider(this._networkService);
  
  List<NetworkPost> get posts => _posts;
  bool get isLoading => _isLoading;
  String get currentFeedType => _currentFeedType;
  
  Future<void> loadFeed({String? feedType, int limit = 20}) async {
    if (_isLoading) return;
    
    _isLoading = true;
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
      debugPrint('✅ Feed chargé: ${_posts.length} posts'); // ← LOG
    } catch (e) {
      debugPrint('❌ FeedProvider loadFeed error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // ⭐ MODIFICATION IMPORTANTE ICI ⭐
  // lib/providers/feed_provider.dart
Future<bool> createPost(String content, List<String> images) async {
  try {
    debugPrint('📝 FeedProvider: création du post...');
    
    // Maintenant createPost retourne directement l'ID
    final postId = await _networkService.createPost(content, images);
    
    if (postId.isEmpty) {
      debugPrint('❌ FeedProvider: pas d\'ID retourné');
      return false;
    }
    
    debugPrint('✅ FeedProvider: post créé avec ID: $postId');
    
    // Recharger tout le feed
    await loadFeed();
    debugPrint('🔄 FeedProvider: feed rechargé, ${_posts.length} posts');
    
    return true;
  } catch (e) {
    debugPrint('❌ FeedProvider createPost error: $e');
    return false;
  }
}
  
  Future<void> toggleLike(String postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;
    
    final post = _posts[index];
    final wasLiked = post.isLikedByCurrentUser;
    
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
      _posts[index] = post;
      notifyListeners();
      debugPrint('FeedProvider toggleLike error: $e');
    }
  }
  
  void clearPosts() {
    _posts = [];
    notifyListeners();
  }
}
