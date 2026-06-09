import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class NotificationService {
  final SupabaseClient _client;
  static const String _table = 'notifications';

  NotificationService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  Map<String, dynamic> _normalizeRow(Map<String, dynamic> row) {
    return {
      'id': row['id'],
      'user_id': row['user_id'],
      'type': (row['type'] ?? 'generic').toString(),
      'title': (row['title'] ?? 'Notification').toString(),
      'body': (row['body'] ?? row['message'] ?? '').toString(),
      'read': row['read'] ?? row['seen'] ?? false,
      'data': row['data'] ?? {},
      'actor_id': row['actor_id'],
      'actor_name': row['actor_name'],
      'actor_avatar': row['actor_avatar'],
      'post_id': row['post_id'],
      'created_at': row['created_at'],
    };
  }

  String get currentUserId => _client.auth.currentUser?.id ?? '';

  /// Stream des notifications avec polling (sans Realtime)
  Stream<List<Map<String, dynamic>>> streamForUser(String uid) {
    final controller = StreamController<List<Map<String, dynamic>>>.broadcast();
    Timer? pollTimer;
    bool cancelled = false;

    Future<void> fetchAndEmit() async {
      if (cancelled) return;
      try {
        final data = await _client
            .from(_table)
            .select()
            .eq('user_id', uid)
            .order('created_at', ascending: false)
            .limit(50);

        final list = (data as List)
            .map((e) => _normalizeRow(e as Map<String, dynamic>))
            .toList();
        controller.add(list);
      } catch (e) {
        debugPrint('NotificationService fetch error: $e');
        controller.add([]);
      }
    }

    void startPolling() {
      pollTimer?.cancel();
      pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => fetchAndEmit());
    }

    startPolling();
    fetchAndEmit();

    controller.onCancel = () {
      cancelled = true;
      pollTimer?.cancel();
    };

    return controller.stream;
  }

  Stream<int> streamUnreadCount(String uid) {
    return streamForUser(uid)
        .map((list) => list.where((n) => n['read'] != true).length)
        .distinct();
  }

  // ==================== CRÉATION DE NOTIFICATIONS ====================

  Future<void> add({
    required String toUid,
    required String type,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? actorId,
    String? actorName,
    String? actorAvatar,
    String? postId,
  }) async {
    try {
      await _client.from(_table).insert({
        'user_id': toUid,
        'type': type,
        'title': title,
        'body': body,
        'read': false,
        'data': data ?? {},
        'actor_id': actorId,
        'actor_name': actorName,
        'actor_avatar': actorAvatar,
        'post_id': postId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Notification add error: $e');
    }
  }

  Future<void> notifyLike({
    required String toUid,
    required String actorId,
    required String actorName,
    String? actorAvatar,
    required String postId,
  }) async {
    await add(
      toUid: toUid,
      type: 'like',
      title: 'Nouveau like',
      body: '$actorName a aimé votre publication',
      actorId: actorId,
      actorName: actorName,
      actorAvatar: actorAvatar,
      postId: postId,
    );
  }

  Future<void> notifyComment({
    required String toUid,
    required String actorId,
    required String actorName,
    String? actorAvatar,
    required String postId,
  }) async {
    await add(
      toUid: toUid,
      type: 'comment',
      title: 'Nouveau commentaire',
      body: '$actorName a commenté votre publication',
      actorId: actorId,
      actorName: actorName,
      actorAvatar: actorAvatar,
      postId: postId,
    );
  }

  Future<void> notifyConnectionRequest({
    required String toUid,
    required String actorId,
    required String actorName,
    String? actorAvatar,
  }) async {
    await add(
      toUid: toUid,
      type: 'connection_request',
      title: 'Demande de connexion',
      body: '$actorName souhaite se connecter avec vous',
      actorId: actorId,
      actorName: actorName,
      actorAvatar: actorAvatar,
    );
  }

  Future<void> notifyConnectionAccepted({
    required String toUid,
    required String actorId,
    required String actorName,
    String? actorAvatar,
  }) async {
    await add(
      toUid: toUid,
      type: 'connection_accepted',
      title: 'Connexion acceptée',
      body: '$actorName a accepté votre demande de connexion',
      actorId: actorId,
      actorName: actorName,
      actorAvatar: actorAvatar,
    );
  }

  Future<void> notifyGeneric({
    required String toUid,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    await add(
      toUid: toUid,
      type: 'generic',
      title: title,
      body: body,
      data: data,
    );
  }

  // ==================== LECTURE DES NOTIFICATIONS ====================

  Future<void> markRead({required String uid, required String notificationId}) async {
    try {
      await _client
          .from(_table)
          .update({'read': true})
          .eq('id', notificationId)
          .eq('user_id', uid);
    } catch (e) {
      debugPrint('Notification markRead error: $e');
    }
  }

  Future<void> markAllRead(String uid) async {
    try {
      await _client
          .from(_table)
          .update({'read': true})
          .eq('user_id', uid)
          .eq('read', false);
    } catch (e) {
      debugPrint('Notification markAllRead error: $e');
    }
  }

  Future<int> getUnreadCount(String uid) async {
    try {
      // ✅ CORRECTION: utiliser '*' au lieu de 'id'
      final response = await _client
          .from(_table)
          .select('*', count: CountOption.exact)
          .eq('user_id', uid)
          .eq('read', false);
      
      return response.count ?? 0;
    } catch (e) {
      debugPrint('Notification getUnreadCount error: $e');
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> getNotifications(String uid) async {
    try {
      final data = await _client
          .from(_table)
          .select()
          .eq('user_id', uid)
          .order('created_at', ascending: false)
          .limit(50);
      
      return (data as List)
          .map((e) => _normalizeRow(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('NotificationService getNotifications error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getNotification(String id) async {
    try {
      final data = await _client
          .from(_table)
          .select()
          .eq('id', id)
          .maybeSingle();
      
      return data != null ? _normalizeRow(data as Map<String, dynamic>) : null;
    } catch (e) {
      debugPrint('Notification getNotification error: $e');
      return null;
    }
  }

  Future<void> delete(String notificationId) async {
    try {
      await _client.from(_table).delete().eq('id', notificationId);
    } catch (e) {
      debugPrint('Notification delete error: $e');
    }
  }

  Future<void> deleteAll(String uid) async {
    try {
      await _client.from(_table).delete().eq('user_id', uid);
    } catch (e) {
      debugPrint('Notification deleteAll error: $e');
    }
  }

  // ==================== NOTIFICATIONS PUSH ====================

  Future<void> registerPushToken(String userId, String token, String platform) async {
    try {
      await _client.from('push_tokens').upsert({
        'user_id': userId,
        'token': token,
        'platform': platform,
        'last_seen_at': DateTime.now().toIso8601String(),
      }, onConflict: 'token');
    } catch (e) {
      debugPrint('Notification registerPushToken error: $e');
    }
  }

  Future<void> unregisterPushToken(String token) async {
    try {
      await _client.from('push_tokens').delete().eq('token', token);
    } catch (e) {
      debugPrint('Notification unregisterPushToken error: $e');
    }
  }
}
