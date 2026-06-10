import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import '../models/network_post.dart';
import '../models/network_connection.dart';
import '../models/network_community.dart';
import '../models/network_message.dart';
import '../models/network_notification.dart';
import '../models/network_story.dart';
import 'package:flutter/material.dart';

class NetworkService {
  final SupabaseClient _supabase;

  NetworkService(this._supabase);

  String get currentUserId => _supabase.auth.currentUser?.id ?? '';

  // ==================== POSTS ====================

  Future<List<NetworkPost>> getFeedPosts({int limit = 20}) async {
  try {
    final currentUserId = this.currentUserId;
    
    // Récupérer les IDs des posts masqués
    final hiddenPosts = await _supabase
        .from('hidden_posts')
        .select('post_id')
        .eq('user_id', currentUserId);
    
    final hiddenIds = (hiddenPosts as List).map((e) => e['post_id']).toList();
    
    final response = await _supabase
        .from('network_posts')
        .select('''
          *,
          profiles!user_id (
            id,
            display_name,
            avatar_url,
            title
          ),
          likes:network_likes!post_id(count),
          comments:network_comments!post_id(count),
          user_liked:network_likes!post_id(user_id)
        ''')
        .order('created_at', ascending: false)
        .limit(limit);
    
    // ✅ Filtrer côté Dart pour exclure les posts masqués
    final filteredResponse = (response as List)
        .where((post) => !hiddenIds.contains(post['id']))
        .toList();
    
    return filteredResponse.map((e) {
      final userLiked = (e['user_liked'] as List?)?.any((like) => like['user_id'] == currentUserId) ?? false;
      
      return NetworkPost.fromJson({
        ...e,
        'likes_count': (e['likes'] as List?)?.length ?? 0,
        'comments_count': (e['comments'] as List?)?.length ?? 0,
        'is_liked_by_current_user': userLiked,
      });
    }).toList();
  } catch (e) {
    debugPrint('Error getFeedPosts: $e');
    return [];
  }
}

  Future<NetworkPost?> getPostById(String postId) async {
    try {
      final currentUserId = this.currentUserId;
      
      final response = await _supabase
          .from('network_posts')
          .select('''
            *,
            profiles!user_id (
              id,
              display_name,
              avatar_url,
              title
            ),
            likes:network_likes!post_id(count),
            comments:network_comments!post_id(count),
            user_liked:network_likes!post_id(user_id)
          ''')
          .eq('id', postId)
          .single();
      
      final userLiked = (response['user_liked'] as List?)?.any((like) => like['user_id'] == currentUserId) ?? false;
      
      return NetworkPost.fromJson({
        ...response,
        'likes_count': (response['likes'] as List?)?.length ?? 0,
        'comments_count': (response['comments'] as List?)?.length ?? 0,
        'is_liked_by_current_user': userLiked,
      });
    } catch (e) {
      debugPrint('Error getPostById: $e');
      return null;
    }
  }

  Future<void> createPost(String content, List<String> images) async {
    final currentUserId = this.currentUserId;
    await _supabase.from('network_posts').insert({
      'user_id': currentUserId,
      'content': content,
      'images': images,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updatePost(String postId, String newContent) async {
    final currentUserId = this.currentUserId;
    
    final post = await _supabase
        .from('network_posts')
        .select('user_id')
        .eq('id', postId)
        .single();
    
    if (post['user_id'] != currentUserId) {
      throw Exception('Vous ne pouvez pas modifier cette publication');
    }
    
    await _supabase
        .from('network_posts')
        .update({
          'content': newContent,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', postId);
  }

  Future<void> deletePost(String postId) async {
    final currentUserId = this.currentUserId;
    
    final post = await _supabase
        .from('network_posts')
        .select('user_id')
        .eq('id', postId)
        .single();
    
    if (post['user_id'] != currentUserId) {
      throw Exception('Vous ne pouvez pas supprimer cette publication');
    }
    
    await _supabase.from('network_posts').delete().eq('id', postId);
  }

  Future<void> hidePost(String postId) async {
    final currentUserId = this.currentUserId;
    
    await _supabase.from('hidden_posts').insert({
      'post_id': postId,
      'user_id': currentUserId,
      'hidden_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> reportPost(String postId, String reason) async {
    final currentUserId = this.currentUserId;
    
    await _supabase.from('reported_posts').insert({
      'post_id': postId,
      'user_id': currentUserId,
      'reason': reason,
      'reported_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> sharePost(String postId) async {
    await _supabase.rpc('increment_post_shares', params: {'post_id': postId});
  }

  Future<void> likePost(String postId) async {
    final currentUserId = this.currentUserId;
    await _supabase.from('network_likes').insert({
      'post_id': postId,
      'user_id': currentUserId,
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await _createNotification(
      userId: await _getPostOwnerId(postId),
      type: 'like',
      postId: postId,
    );
  }

  Future<void> unlikePost(String postId) async {
    final currentUserId = this.currentUserId;
    await _supabase
        .from('network_likes')
        .delete()
        .eq('post_id', postId)
        .eq('user_id', currentUserId);
  }

  Future<void> addComment(String postId, String content) async {
    final currentUserId = this.currentUserId;
    await _supabase.from('network_comments').insert({
      'post_id': postId,
      'user_id': currentUserId,
      'content': content,
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await _createNotification(
      userId: await _getPostOwnerId(postId),
      type: 'comment',
      postId: postId,
    );
  }

  Future<List<Map<String, dynamic>>> getComments(String postId) async {
    try {
      final response = await _supabase
          .from('network_comments')
          .select('''
            *,
            profiles!user_id (
              id,
              display_name,
              avatar_url
            )
          ''')
          .eq('post_id', postId)
          .order('created_at', ascending: true);
      
      return (response as List).map((e) => {
        'id': e['id'],
        'user_id': e['user_id'],
        'user_name': e['profiles']['display_name'],
        'user_avatar': e['profiles']['avatar_url'],
        'content': e['content'],
        'created_at': e['created_at'],
      }).toList();
    } catch (e) {
      debugPrint('Error getComments: $e');
      return [];
    }
  }

  Future<String> _getPostOwnerId(String postId) async {
    final response = await _supabase
        .from('network_posts')
        .select('user_id')
        .eq('id', postId)
        .single();
    return response['user_id'];
  }

  // ==================== GESTION DES COMMENTAIRES ====================

  Future<void> deleteComment(String commentId) async {
    final currentUserId = this.currentUserId;
    
    final comment = await _supabase
        .from('network_comments')
        .select('user_id')
        .eq('id', commentId)
        .single();
    
    if (comment['user_id'] != currentUserId) {
      throw Exception('Vous ne pouvez pas supprimer ce commentaire');
    }
    
    await _supabase.from('network_comments').delete().eq('id', commentId);
  }

  // ==================== COMMUNAUTÉS ====================

  Future<NetworkCommunity> createCommunity({
    required String name,
    String? description,
    String? bannerUrl,
  }) async {
    final currentUserId = this.currentUserId;
    
    final response = await _supabase
        .from('network_communities')
        .insert({
          'name': name,
          'description': description,
          'banner_url': bannerUrl,
          'created_by': currentUserId,
          'created_at': DateTime.now().toIso8601String(),
          'members_count': 1,
          'posts_count': 0,
        })
        .select()
        .single();
    
    await _supabase.from('community_members').insert({
      'community_id': response['id'],
      'user_id': currentUserId,
      'role': 'admin',
      'joined_at': DateTime.now().toIso8601String(),
    });
    
    return NetworkCommunity.fromJson(response);
  }

  Future<List<NetworkCommunity>> getAllCommunities({int limit = 50}) async {
    try {
      final currentUserId = this.currentUserId;
      
      final response = await _supabase
          .from('network_communities')
          .select('''
            *,
            creator:profiles!created_by (
              id, display_name, avatar_url
            ),
            is_member:community_members!community_id(user_id)
          ''')
          .order('members_count', ascending: false)
          .limit(limit);
      
      return (response as List).map((e) {
        final isMember = (e['is_member'] as List?)
            ?.any((member) => member['user_id'] == currentUserId) ?? false;
        
        return NetworkCommunity.fromJson({
          ...e,
          'is_member': isMember,
        });
      }).toList();
    } catch (e) {
      debugPrint('Error getAllCommunities: $e');
      return [];
    }
  }

  Future<List<NetworkCommunity>> getSuggestedCommunities({int limit = 10}) async {
    try {
      final currentUserId = this.currentUserId;
      
      final response = await _supabase
          .from('network_communities')
          .select('''
            *,
            creator:profiles!created_by (
              id, display_name, avatar_url
            ),
            is_member:community_members!community_id(user_id)
          ''')
          .order('members_count', ascending: false)
          .limit(limit);
      
      return (response as List).map((e) {
        final isMember = (e['is_member'] as List?)
            ?.any((member) => member['user_id'] == currentUserId) ?? false;
        
        if (isMember) return null;
        
        return NetworkCommunity.fromJson({
          ...e,
          'is_member': isMember,
        });
      }).where((e) => e != null).cast<NetworkCommunity>().toList();
    } catch (e) {
      debugPrint('Error getSuggestedCommunities: $e');
      return [];
    }
  }

  Future<List<NetworkCommunity>> getMyCommunities() async {
    try {
      final currentUserId = this.currentUserId;
      
      final response = await _supabase
          .from('community_members')
          .select('''
            community:communities!community_id (
              *,
              creator:profiles!created_by (
                id, display_name, avatar_url
              )
            )
          ''')
          .eq('user_id', currentUserId);
      
      return (response as List).map((e) {
        final community = e['community'] as Map<String, dynamic>;
        return NetworkCommunity.fromJson({
          ...community,
          'is_member': true,
        });
      }).toList();
    } catch (e) {
      debugPrint('Error getMyCommunities: $e');
      return [];
    }
  }

  Future<NetworkCommunity?> getCommunityById(String communityId) async {
    try {
      final currentUserId = this.currentUserId;
      
      final response = await _supabase
          .from('network_communities')
          .select('''
            *,
            creator:profiles!created_by (
              id, display_name, avatar_url
            ),
            is_member:community_members!community_id(user_id)
          ''')
          .eq('id', communityId)
          .single();
      
      final isMember = (response['is_member'] as List?)
          ?.any((member) => member['user_id'] == currentUserId) ?? false;
      
      return NetworkCommunity.fromJson({
        ...response,
        'is_member': isMember,
      });
    } catch (e) {
      debugPrint('Error getCommunityById: $e');
      return null;
    }
  }

  Future<void> updateCommunity({
    required String communityId,
    String? name,
    String? description,
    String? bannerUrl,
  }) async {
    final currentUserId = this.currentUserId;
    
    final isAdmin = await _isCommunityAdmin(communityId, currentUserId);
    if (!isAdmin) {
      throw Exception('Seuls les administrateurs peuvent modifier la communauté');
    }
    
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (description != null) updates['description'] = description;
    if (bannerUrl != null) updates['banner_url'] = bannerUrl;
    updates['updated_at'] = DateTime.now().toIso8601String();
    
    await _supabase
        .from('network_communities')
        .update(updates)
        .eq('id', communityId);
  }

  Future<void> deleteCommunity(String communityId) async {
    final currentUserId = this.currentUserId;
    
    final community = await _supabase
        .from('network_communities')
        .select('created_by')
        .eq('id', communityId)
        .single();
    
    if (community['created_by'] != currentUserId) {
      throw Exception('Seul le créateur peut supprimer la communauté');
    }
    
    await _supabase.from('network_communities').delete().eq('id', communityId);
  }

  // ==================== MEMBRES ====================

  Future<void> joinCommunity(String communityId) async {
    final currentUserId = this.currentUserId;
    
    final existing = await _supabase
        .from('community_members')
        .select('id')
        .eq('community_id', communityId)
        .eq('user_id', currentUserId)
        .maybeSingle();
    
    if (existing == null) {
      await _supabase.from('community_members').insert({
        'community_id': communityId,
        'user_id': currentUserId,
        'role': 'member',
        'joined_at': DateTime.now().toIso8601String(),
      });
      
      await _supabase.rpc('increment_community_members', params: {'community_id': communityId});
    }
  }

  Future<void> leaveCommunity(String communityId) async {
    final currentUserId = this.currentUserId;
    
    final isAdmin = await _isCommunityAdmin(communityId, currentUserId);
    if (isAdmin) {
      throw Exception('Les administrateurs ne peuvent pas quitter la communauté. Transférez d\'abord le rôle.');
    }
    
    await _supabase
        .from('community_members')
        .delete()
        .eq('community_id', communityId)
        .eq('user_id', currentUserId);
    
    await _supabase.rpc('decrement_community_members', params: {'community_id': communityId});
  }

  Future<List<CommunityMember>> getCommunityMembers(String communityId, {int limit = 50}) async {
    try {
      final response = await _supabase
          .from('community_members')
          .select('''
            *,
            user:profiles!user_id (
              id, display_name, avatar_url, title
            )
          ''')
          .eq('community_id', communityId)
          .order('joined_at', ascending: true)
          .limit(limit);
      
      return (response as List).map((e) => CommunityMember.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error getCommunityMembers: $e');
      return [];
    }
  }

  Future<void> addMember(String communityId, String userId, {String role = 'member'}) async {
    final currentUserId = this.currentUserId;
    
    final isAdmin = await _isCommunityAdmin(communityId, currentUserId);
    if (!isAdmin) {
      throw Exception('Seuls les administrateurs peuvent ajouter des membres');
    }
    
    final existing = await _supabase
        .from('community_members')
        .select('id')
        .eq('community_id', communityId)
        .eq('user_id', userId)
        .maybeSingle();
    
    if (existing == null) {
      await _supabase.from('community_members').insert({
        'community_id': communityId,
        'user_id': userId,
        'role': role,
        'joined_at': DateTime.now().toIso8601String(),
      });
      
      await _supabase.rpc('increment_community_members', params: {'community_id': communityId});
    }
  }

  Future<void> removeMember(String communityId, String userId) async {
    final currentUserId = this.currentUserId;
    
    final isAdmin = await _isCommunityAdmin(communityId, currentUserId);
    if (!isAdmin) {
      throw Exception('Seuls les administrateurs peuvent supprimer des membres');
    }
    
    await _supabase
        .from('community_members')
        .delete()
        .eq('community_id', communityId)
        .eq('user_id', userId);
    
    await _supabase.rpc('decrement_community_members', params: {'community_id': communityId});
  }

  Future<void> changeMemberRole(String communityId, String userId, String newRole) async {
    final currentUserId = this.currentUserId;
    
    final isAdmin = await _isCommunityAdmin(communityId, currentUserId);
    if (!isAdmin) {
      throw Exception('Seuls les administrateurs peuvent changer les rôles');
    }
    
    await _supabase
        .from('community_members')
        .update({'role': newRole})
        .eq('community_id', communityId)
        .eq('user_id', userId);
  }

  Future<bool> _isCommunityAdmin(String communityId, String userId) async {
    try {
      final response = await _supabase
          .from('community_members')
          .select('role')
          .eq('community_id', communityId)
          .eq('user_id', userId)
          .maybeSingle();
      
      return response != null && response['role'] == 'admin';
    } catch (e) {
      return false;
    }
  }

  Future<bool> _isCommunityMember(String communityId, String userId) async {
    try {
      final response = await _supabase
          .from('community_members')
          .select('id')
          .eq('community_id', communityId)
          .eq('user_id', userId)
          .maybeSingle();
      
      return response != null;
    } catch (e) {
      return false;
    }
  }

  // ==================== POSTS DANS COMMUNAUTÉ ====================

  Future<void> createCommunityPost({
    required String communityId,
    required String content,
    List<String> images = const [],
  }) async {
    final currentUserId = this.currentUserId;
    
    final isMember = await _isCommunityMember(communityId, currentUserId);
    if (!isMember) {
      throw Exception('Vous devez être membre pour publier dans cette communauté');
    }
    
    await _supabase.from('network_posts').insert({
      'user_id': currentUserId,
      'community_id': communityId,
      'content': content,
      'images': images,
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await _supabase.rpc('increment_community_posts', params: {'community_id': communityId});
  }

  Future<List<NetworkPost>> getCommunityPosts(String communityId, {int limit = 20}) async {
    try {
      final currentUserId = this.currentUserId;
      
      final response = await _supabase
          .from('network_posts')
          .select('''
            *,
            profiles!user_id (
              id, display_name, avatar_url, title
            ),
            user_liked:network_likes!post_id(user_id)
          ''')
          .eq('community_id', communityId)
          .order('created_at', ascending: false)
          .limit(limit);
      
      return (response as List).map((e) {
        final userLiked = (e['user_liked'] as List?)
            ?.any((like) => like['user_id'] == currentUserId) ?? false;
        
        return NetworkPost.fromJson({
          ...e,
          'likes_count': 0,
          'comments_count': 0,
          'is_liked_by_current_user': userLiked,
        });
      }).toList();
    } catch (e) {
      debugPrint('Error getCommunityPosts: $e');
      return [];
    }
  }

  // ==================== PARTAGER UNE COMMUNAUTÉ ====================

  String getCommunityShareLink(String communityId) {
    return 'https://thix.app/community/$communityId';
  }

  Future<void> shareCommunity(BuildContext context, String communityId, String communityName) async {
    final link = getCommunityShareLink(communityId);
    final shareText = 'Rejoins la communauté "$communityName" sur THIX Réseau Pro ! $link';
    
    await Share.share(shareText);
  }

  // ==================== RECHERCHE ====================

  Future<List<NetworkCommunity>> searchCommunities(String query) async {
    try {
      final currentUserId = this.currentUserId;
      
      final response = await _supabase
          .from('network_communities')
          .select('''
            *,
            creator:profiles!created_by (
              id, display_name, avatar_url
            ),
            is_member:community_members!community_id(user_id)
          ''')
          .ilike('name', '%$query%')
          .order('members_count', ascending: false)
          .limit(20);
      
      return (response as List).map((e) {
        final isMember = (e['is_member'] as List?)
            ?.any((member) => member['user_id'] == currentUserId) ?? false;
        
        return NetworkCommunity.fromJson({
          ...e,
          'is_member': isMember,
        });
      }).toList();
    } catch (e) {
      debugPrint('Error searchCommunities: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('id, display_name, avatar_url, title')
          .ilike('display_name', '%$query%')
          .limit(20);
      
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error searchUsers: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> searchPosts(String query) async {
    try {
      final response = await _supabase
          .from('network_posts')
          .select('''
            id, content, created_at,
            profiles!user_id (display_name, avatar_url)
          ''')
          .ilike('content', '%$query%')
          .order('created_at', ascending: false)
          .limit(20);
      
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error searchPosts: $e');
      return [];
    }
  }

  Future<Map<String, int>> getRecommendationsCount() async {
    final currentUserId = this.currentUserId;
    
    final people = await _supabase
        .from('profiles')
        .select('id')
        .neq('id', currentUserId)
        .limit(10);
    
    final opportunities = await _supabase
        .from('opportunities')
        .select('id')
        .eq('is_active', true)
        .limit(10);
    
    final communities = await _supabase
        .from('network_communities')
        .select('id')
        .limit(10);
    
    return {
      'people': (people as List).length,
      'opportunities': (opportunities as List).length,
      'communities': (communities as List).length,
    };
  }

  // ==================== CONNECTIONS ====================

  Future<List<NetworkConnection>> getSuggestedConnections({int limit = 10}) async {
    try {
      final currentUserId = this.currentUserId;
      
      final response = await _supabase
          .from('profiles')
          .select('''
            id,
            display_name,
            avatar_url,
            title,
            mutual_connections:network_connections!target_id(count)
          ''')
          .neq('id', currentUserId)
          .limit(limit);
      
      return (response as List).map((e) => NetworkConnection(
        id: e['id'],
        name: e['display_name'],
        avatar: e['avatar_url'],
        title: e['title'] ?? 'Membre THIX',
        mutualConnections: e['mutual_connections'] != null && (e['mutual_connections'] as List).isNotEmpty 
            ? (e['mutual_connections'][0]['count'] ?? 0) 
            : 0,
      )).toList();
    } catch (e) {
      debugPrint('Error getSuggestedConnections: $e');
      return [];
    }
  }

  Future<void> sendConnectionRequest(String targetUserId) async {
    final currentUserId = this.currentUserId;
    await _supabase.from('network_connections').insert({
      'requester_id': currentUserId,
      'target_id': targetUserId,
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await _createNotification(
      userId: targetUserId,
      type: 'connection_request',
    );
  }

  Future<void> acceptConnectionRequest(String requestId) async {
    await _supabase
        .from('network_connections')
        .update({'status': 'accepted', 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', requestId);
  }

  Future<String?> getConnectionStatus(String userId) async {
    try {
      final currentUserId = this.currentUserId;
      final response = await _supabase
          .from('network_connections')
          .select('status')
          .or('requester_id.eq.$currentUserId,target_id.eq.$currentUserId')
          .or('requester_id.eq.$userId,target_id.eq.$userId')
          .maybeSingle();
      
      return response?['status'];
    } catch (e) {
      debugPrint('Error getConnectionStatus: $e');
      return null;
    }
  }

  // ==================== BLOCAGE UTILISATEURS ====================

  Future<void> blockUser(String userIdToBlock) async {
    final currentUserId = this.currentUserId;
    
    final existing = await _supabase
        .from('blocked_users')
        .select('id')
        .eq('user_id', currentUserId)
        .eq('blocked_user_id', userIdToBlock)
        .maybeSingle();
    
    if (existing == null) {
      await _supabase.from('blocked_users').insert({
        'user_id': currentUserId,
        'blocked_user_id': userIdToBlock,
        'blocked_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> unblockUser(String userIdToUnblock) async {
    final currentUserId = this.currentUserId;
    await _supabase
        .from('blocked_users')
        .delete()
        .eq('user_id', currentUserId)
        .eq('blocked_user_id', userIdToUnblock);
  }

  Future<List<String>> getBlockedUsers() async {
    final currentUserId = this.currentUserId;
    final response = await _supabase
        .from('blocked_users')
        .select('blocked_user_id')
        .eq('user_id', currentUserId);
    
    return (response as List).map((e) => e['blocked_user_id'] as String).toList();
  }

  // ==================== STORIES ====================

  Future<List<NetworkStory>> getActiveStories() async {
    try {
      final currentUserId = this.currentUserId;
      NetworkStory.setCurrentUserId(currentUserId);
      
      final response = await _supabase
          .from('network_stories')
          .select('''
            *,
            profiles!user_id (
              display_name, avatar_url, title
            )
          ''')
          .eq('is_active', true)
          .gte('expires_at', DateTime.now().toIso8601String())
          .order('created_at', ascending: false)
          .limit(20);
      
      return (response as List).map((e) => NetworkStory.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error getActiveStories: $e');
      return [];
    }
  }

  Future<void> createStory(String imageUrl, {int duration = 24}) async {
    final currentUserId = this.currentUserId;
    await _supabase.from('network_stories').insert({
      'user_id': currentUserId,
      'image_url': imageUrl,
      'duration': duration,
      'is_active': true,
      'created_at': DateTime.now().toIso8601String(),
      'expires_at': DateTime.now().add(Duration(hours: duration)).toIso8601String(),
    });
  }

  Future<void> deleteStory(String storyId) async {
    final currentUserId = this.currentUserId;
    await _supabase
        .from('network_stories')
        .delete()
        .eq('id', storyId)
        .eq('user_id', currentUserId);
  }

  Future<void> markStoryAsViewed(String storyId) async {
    final currentUserId = this.currentUserId;
    
    final existing = await _supabase
        .from('story_views')
        .select('id')
        .eq('story_id', storyId)
        .eq('user_id', currentUserId)
        .maybeSingle();
    
    if (existing == null) {
      await _supabase.from('story_views').insert({
        'story_id': storyId,
        'user_id': currentUserId,
        'viewed_at': DateTime.now().toIso8601String(),
      });
    }
  }

  // ==================== PROFIL UTILISATEUR ====================

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('''
            id,
            display_name,
            avatar_url,
            title,
            bio,
            skills,
            posts_count:network_posts(count),
            followers_count:network_connections!target_id(count),
            following_count:network_connections!requester_id(count)
          ''')
          .eq('id', userId)
          .maybeSingle();
      
      if (response == null) return null;
      
      return {
        'id': response['id'],
        'display_name': response['display_name'],
        'avatar_url': response['avatar_url'],
        'title': response['title'],
        'bio': response['bio'],
        'skills': response['skills'] ?? [],
        'posts_count': (response['posts_count'] as List?)?.length ?? 0,
        'followers_count': (response['followers_count'] as List?)?.length ?? 0,
        'following_count': (response['following_count'] as List?)?.length ?? 0,
      };
    } catch (e) {
      debugPrint('Error getUserProfile: $e');
      return null;
    }
  }

  Future<List<NetworkPost>> getUserPosts(String userId) async {
    try {
      final response = await _supabase
          .from('network_posts')
          .select('''
            *,
            profiles!user_id (
              display_name, avatar_url, title
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return (response as List).map((e) => NetworkPost.fromJson({
        ...e,
        'likes_count': 0,
        'comments_count': 0,
      })).toList();
    } catch (e) {
      debugPrint('Error getUserPosts: $e');
      return [];
    }
  }

  // ==================== MESSAGES ====================

  Future<List<Conversation>> getConversations() async {
    try {
      final currentUserId = this.currentUserId;
      
      final response = await _supabase
          .from('network_conversations')
          .select('''
            id,
            user1_id,
            user2_id,
            last_message,
            last_message_at,
            last_sender_id,
            user1:profiles!network_conversations_user1_id(
              id, display_name, avatar_url
            ),
            user2:profiles!network_conversations_user2_id(
              id, display_name, avatar_url
            ),
            unread_count:network_messages!conversation_id(count)
          ''')
          .or('user1_id.eq.$currentUserId,user2_id.eq.$currentUserId')
          .order('last_message_at', ascending: false);
      
      return (response as List).map((e) => Conversation.fromJson(e, currentUserId)).toList();
    } catch (e) {
      debugPrint('Error getConversations: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> sendMessage(String receiverId, String content) async {
    final currentUserId = this.currentUserId;
    
    var conv = await _supabase
        .from('network_conversations')
        .select()
        .or('user1_id.eq.$currentUserId,user2_id.eq.$currentUserId')
        .or('user1_id.eq.$receiverId,user2_id.eq.$receiverId')
        .maybeSingle();
    
    String conversationId;
    if (conv == null) {
      final newConv = await _supabase
          .from('network_conversations')
          .insert({
            'user1_id': currentUserId,
            'user2_id': receiverId,
            'last_message': content,
            'last_message_at': DateTime.now().toIso8601String(),
            'last_sender_id': currentUserId,
          })
          .select()
          .single();
      conversationId = newConv['id'];
    } else {
      conversationId = conv['id'];
      await _supabase
          .from('network_conversations')
          .update({
            'last_message': content,
            'last_message_at': DateTime.now().toIso8601String(),
            'last_sender_id': currentUserId,
          })
          .eq('id', conversationId);
    }
    
    final response = await _supabase
        .from('network_messages')
        .insert({
          'conversation_id': conversationId,
          'sender_id': currentUserId,
          'receiver_id': receiverId,
          'content': content,
          'is_read': false,
          'created_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();
    
    return {
      'id': response['id'],
      'content': response['content'],
      'is_sent_by_me': true,
      'created_at': DateTime.parse(response['created_at']),
    };
  }

  Future<List<Map<String, dynamic>>> getMessages(String otherUserId) async {
    try {
      final currentUserId = this.currentUserId;
      
      final response = await _supabase
          .from('network_messages')
          .select('*')
          .or('sender_id.eq.$currentUserId,receiver_id.eq.$currentUserId')
          .or('sender_id.eq.$otherUserId,receiver_id.eq.$otherUserId')
          .order('created_at', ascending: true);
      
      return (response as List).map((e) => ({
        'id': e['id'],
        'content': e['content'],
        'is_sent_by_me': e['sender_id'] == currentUserId,
        'created_at': DateTime.parse(e['created_at']),
      })).toList();
    } catch (e) {
      debugPrint('Error getMessages: $e');
      return [];
    }
  }

  Future<void> markMessagesAsRead(String otherUserId) async {
    try {
      final currentUserId = this.currentUserId;
      await _supabase
          .from('network_messages')
          .update({'is_read': true})
          .eq('receiver_id', currentUserId)
          .eq('sender_id', otherUserId);
    } catch (e) {
      debugPrint('Error markMessagesAsRead: $e');
    }
  }

  // ==================== NOTIFICATIONS ====================

  Future<List<NetworkNotification>> getNotifications() async {
    try {
      final currentUserId = this.currentUserId;
      
      final response = await _supabase
          .from('network_notifications')
          .select('''
            *,
            actor:profiles!actor_id(
              id, display_name, avatar_url
            ),
            post:network_posts!post_id(
              id, content
            )
          ''')
          .eq('user_id', currentUserId)
          .order('created_at', ascending: false)
          .limit(50);
      
      return (response as List).map((e) => NetworkNotification.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error getNotifications: $e');
      return [];
    }
  }

  Future<int> getUnreadNotificationsCount() async {
    try {
      final currentUserId = this.currentUserId;
      final response = await _supabase
          .from('network_notifications')
          .select('id')
          .eq('user_id', currentUserId)
          .eq('is_read', false);
      
      return (response as List).length;
    } catch (e) {
      debugPrint('Error getUnreadNotificationsCount: $e');
      return 0;
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      final currentUserId = this.currentUserId;
      await _supabase
          .from('network_notifications')
          .update({'is_read': true})
          .eq('user_id', currentUserId)
          .eq('is_read', false);
    } catch (e) {
      debugPrint('Error markAllNotificationsAsRead: $e');
    }
  }

  Future<void> _createNotification({
    required String userId,
    required String type,
    String? postId,
  }) async {
    final currentUserId = this.currentUserId;
    if (userId == currentUserId) return;
    
    await _supabase.from('network_notifications').insert({
      'user_id': userId,
      'type': type,
      'actor_id': currentUserId,
      'post_id': postId,
      'is_read': false,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // ==================== ÉVÉNEMENTS ====================

  Future<void> markEventInterest(String eventId) async {
    final currentUserId = this.currentUserId;
    
    final existing = await _supabase
        .from('event_interests')
        .select('id')
        .eq('event_id', eventId)
        .eq('user_id', currentUserId)
        .maybeSingle();
    
    if (existing == null) {
      await _supabase.from('event_interests').insert({
        'event_id': eventId,
        'user_id': currentUserId,
        'interested_at': DateTime.now().toIso8601String(),
      });
      
      await _supabase.rpc('increment_event_interest_count', params: {'event_id': eventId});
    }
  }

  Future<bool> hasEventInterest(String eventId) async {
    try {
      final currentUserId = this.currentUserId;
      final response = await _supabase
          .from('event_interests')
          .select('id')
          .eq('event_id', eventId)
          .eq('user_id', currentUserId)
          .maybeSingle();
      
      return response != null;
    } catch (e) {
      debugPrint('Error hasEventInterest: $e');
      return false;
    }
  }
}
