// lib/services/notification_service.dart
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

  // ==================== CRÉATION DE NOTIFICATIONS (RÉSEAU PRO) ====================

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

  // ==================== NOTIFICATIONS THIX MONEY ====================

  /// Notification de paiement effectué
  Future<void> notifyPayment({
    required String toUid,
    required double amount,
    required String merchantName,
    String? transactionId,
  }) async {
    await add(
      toUid: toUid,
      type: 'payment',
      title: 'Paiement effectué',
      body: 'Paiement de ${_formatAmount(amount)} FCFA chez $merchantName',
      data: {
        'amount': amount,
        'merchant': merchantName,
        'transaction_id': transactionId,
        'type': 'payment',
      },
    );
  }

  /// Notification de réception de paiement
  Future<void> notifyPaymentReceived({
    required String toUid,
    required double amount,
    required String fromName,
    String? transactionId,
  }) async {
    await add(
      toUid: toUid,
      type: 'payment_received',
      title: 'Paiement reçu',
      body: 'Vous avez reçu ${_formatAmount(amount)} FCFA de $fromName',
      data: {
        'amount': amount,
        'from': fromName,
        'transaction_id': transactionId,
        'type': 'payment_received',
      },
    );
  }

  /// Notification de virement effectué
  Future<void> notifyTransfer({
    required String toUid,
    required double amount,
    required String recipientName,
    String? recipientPhone,
    String? transactionId,
  }) async {
    await add(
      toUid: toUid,
      type: 'transfer',
      title: 'Virement effectué',
      body: 'Virement de ${_formatAmount(amount)} FCFA à $recipientName',
      data: {
        'amount': amount,
        'recipient': recipientName,
        'recipient_phone': recipientPhone,
        'transaction_id': transactionId,
        'type': 'transfer',
      },
    );
  }

  /// Notification de réception de virement
  Future<void> notifyTransferReceived({
    required String toUid,
    required double amount,
    required String fromName,
    String? fromPhone,
    String? transactionId,
  }) async {
    await add(
      toUid: toUid,
      type: 'transfer_received',
      title: 'Virement reçu',
      body: 'Vous avez reçu ${_formatAmount(amount)} FCFA de $fromName',
      data: {
        'amount': amount,
        'from': fromName,
        'from_phone': fromPhone,
        'transaction_id': transactionId,
        'type': 'transfer_received',
      },
    );
  }

  /// Notification de crédit approuvé
  Future<void> notifyCreditApproved({
    required String toUid,
    required double amount,
    required int durationMonths,
    required double monthlyPayment,
    String? creditId,
  }) async {
    await add(
      toUid: toUid,
      type: 'credit_approved',
      title: 'Crédit approuvé',
      body: 'Votre crédit de ${_formatAmount(amount)} FCFA a été approuvé',
      data: {
        'amount': amount,
        'duration_months': durationMonths,
        'monthly_payment': monthlyPayment,
        'credit_id': creditId,
        'type': 'credit_approved',
      },
    );
  }

  /// Notification de demande de crédit
  Future<void> notifyCreditRequest({
    required String toUid,
    required double amount,
    required String status,
    String? reason,
  }) async {
    await add(
      toUid: toUid,
      type: 'credit_request',
      title: 'Demande de crédit',
      body: status == 'pending'
          ? 'Votre demande de crédit de ${_formatAmount(amount)} FCFA est en cours d\'étude'
          : 'Votre demande de crédit a été ${status == 'approved' ? 'approuvée' : 'refusée'}',
      data: {
        'amount': amount,
        'status': status,
        'reason': reason,
        'type': 'credit_request',
      },
    );
  }

  /// Notification d'épargne
  Future<void> notifySavings({
    required String toUid,
    required double amount,
    required String goalName,
    double? progress,
  }) async {
    await add(
      toUid: toUid,
      type: 'savings',
      title: 'Épargne',
      body: '${_formatAmount(amount)} FCFA ajoutés à votre objectif "$goalName"',
      data: {
        'amount': amount,
        'goal_name': goalName,
        'progress': progress,
        'type': 'savings',
      },
    );
  }

  /// Notification d'objectif d'épargne atteint
  Future<void> notifySavingsGoalReached({
    required String toUid,
    required String goalName,
    required double targetAmount,
  }) async {
    await add(
      toUid: toUid,
      type: 'savings_goal_reached',
      title: 'Objectif atteint !',
      body: 'Félicitations ! Vous avez atteint votre objectif "$goalName"',
      data: {
        'goal_name': goalName,
        'target_amount': targetAmount,
        'type': 'savings_goal_reached',
      },
    );
  }

  /// Notification de tontine
  Future<void> notifyTontineContribution({
    required String toUid,
    required String tontineName,
    required double amount,
    DateTime? dueDate,
  }) async {
    final body = dueDate != null && dueDate.isAfter(DateTime.now())
        ? 'Votre contribution de ${_formatAmount(amount)} FCFA à "$tontineName" est due le ${_formatDate(dueDate)}'
        : 'Contribution de ${_formatAmount(amount)} FCFA effectuée pour "$tontineName"';
    
    await add(
      toUid: toUid,
      type: 'tontine',
      title: 'Tontine',
      body: body,
      data: {
        'tontine_name': tontineName,
        'amount': amount,
        'due_date': dueDate?.toIso8601String(),
        'type': 'tontine',
      },
    );
  }

  /// Notification de rappel tontine
  Future<void> notifyTontineReminder({
    required String toUid,
    required String tontineName,
    required double amount,
    required DateTime dueDate,
  }) async {
    await add(
      toUid: toUid,
      type: 'tontine_reminder',
      title: 'Rappel tontine',
      body: 'Rappel : Votre contribution de ${_formatAmount(amount)} FCFA à "$tontineName" est due dans ${_daysUntil(dueDate)} jours',
      data: {
        'tontine_name': tontineName,
        'amount': amount,
        'due_date': dueDate.toIso8601String(),
        'type': 'tontine_reminder',
      },
    );
  }

  /// Notification d'investissement
  Future<void> notifyInvestment({
    required String toUid,
    required String investmentName,
    required double amount,
    double? returnRate,
  }) async {
    await add(
      toUid: toUid,
      type: 'investment',
      title: 'Investissement',
      body: 'Investissement de ${_formatAmount(amount)} FCFA dans "$investmentName" confirmé',
      data: {
        'investment_name': investmentName,
        'amount': amount,
        'return_rate': returnRate,
        'type': 'investment',
      },
    );
  }

  /// Notification de retour sur investissement
  Future<void> notifyInvestmentReturn({
    required String toUid,
    required String investmentName,
    required double amount,
    required double profit,
  }) async {
    await add(
      toUid: toUid,
      type: 'investment_return',
      title: 'Retour sur investissement',
      body: 'Votre investissement "$investmentName" a généré ${_formatAmount(profit)} FCFA',
      data: {
        'investment_name': investmentName,
        'amount': amount,
        'profit': profit,
        'type': 'investment_return',
      },
    );
  }

  /// Notification d'assurance
  Future<void> notifyInsurance({
    required String toUid,
    required String insuranceName,
    required String status,
    double? premium,
    DateTime? dueDate,
  }) async {
    String title, body;
    
    switch (status) {
      case 'active':
        title = 'Assurance activée';
        body = 'Votre assurance "$insuranceName" est maintenant active';
        break;
      case 'payment_due':
        title = 'Paiement assurance';
        body = 'Votre paiement de ${_formatAmount(premium ?? 0)} FCFA pour "$insuranceName" est dû le ${_formatDate(dueDate ?? DateTime.now())}';
        break;
      case 'payment_received':
        title = 'Paiement reçu';
        body = 'Votre paiement de ${_formatAmount(premium ?? 0)} FCFA pour "$insuranceName" a été reçu';
        break;
      default:
        title = 'Assurance';
        body = 'Mise à jour de votre assurance "$insuranceName"';
    }
    
    await add(
      toUid: toUid,
      type: 'insurance',
      title: title,
      body: body,
      data: {
        'insurance_name': insuranceName,
        'status': status,
        'premium': premium,
        'due_date': dueDate?.toIso8601String(),
        'type': 'insurance',
      },
    );
  }

  /// Notification de cashback
  Future<void> notifyCashback({
    required String toUid,
    required double amount,
    required String merchantName,
    String? transactionId,
  }) async {
    await add(
      toUid: toUid,
      type: 'cashback',
      title: 'Cashback reçu',
      body: 'Vous avez reçu ${_formatAmount(amount)} FCFA de cashback chez $merchantName',
      data: {
        'amount': amount,
        'merchant': merchantName,
        'transaction_id': transactionId,
        'type': 'cashback',
      },
    );
  }

  /// Notification de solde faible
  Future<void> notifyLowBalance({
    required String toUid,
    required double currentBalance,
    double? threshold,
  }) async {
    await add(
      toUid: toUid,
      type: 'low_balance',
      title: 'Solde faible',
      body: 'Votre solde est de ${_formatAmount(currentBalance)} FCFA. Pensez à recharger',
      data: {
        'current_balance': currentBalance,
        'threshold': threshold ?? 50000,
        'type': 'low_balance',
      },
    );
  }

  /// Notification de promotion
  Future<void> notifyPromotion({
    required String toUid,
    required String title,
    required String body,
    String? promoCode,
    DateTime? validUntil,
  }) async {
    await add(
      toUid: toUid,
      type: 'promotion',
      title: title,
      body: body,
      data: {
        'promo_code': promoCode,
        'valid_until': validUntil?.toIso8601String(),
        'type': 'promotion',
      },
    );
  }

  /// Notification de rappel de paiement
  Future<void> notifyPaymentReminder({
    required String toUid,
    required String billName,
    required double amount,
    required DateTime dueDate,
  }) async {
    await add(
      toUid: toUid,
      type: 'payment_reminder',
      title: 'Rappel de paiement',
      body: 'Rappel : "$billName" de ${_formatAmount(amount)} FCFA est dû le ${_formatDate(dueDate)}',
      data: {
        'bill_name': billName,
        'amount': amount,
        'due_date': dueDate.toIso8601String(),
        'type': 'payment_reminder',
      },
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
      final response = await _client
          .from(_table)
          .select('id')
          .eq('user_id', uid)
          .eq('read', false);
      
      return (response as List).length;
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

  /// Supprimer les notifications plus anciennes qu'une certaine date
  Future<void> deleteOlderThan(String uid, DateTime date) async {
    try {
      await _client
          .from(_table)
          .delete()
          .eq('user_id', uid)
          .lt('created_at', date.toIso8601String());
    } catch (e) {
      debugPrint('Notification deleteOlderThan error: $e');
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

  Future<List<String>> getUserPushTokens(String userId) async {
    try {
      final data = await _client
          .from('push_tokens')
          .select('token')
          .eq('user_id', userId);
      
      return (data as List)
          .map((e) => e['token'] as String)
          .toList();
    } catch (e) {
      debugPrint('Notification getUserPushTokens error: $e');
      return [];
    }
  }

  // ==================== MÉTHODES UTILITAIRES ====================

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  int _daysUntil(DateTime date) {
    final difference = date.difference(DateTime.now());
    return difference.inDays;
  }

  /// Regrouper les notifications par date
  Map<String, List<Map<String, dynamic>>> groupByDate(List<Map<String, dynamic>> notifications) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    
    for (final notification in notifications) {
      final createdAt = DateTime.parse(notification['created_at'] as String);
      final key = _getDateKey(createdAt);
      
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(notification);
    }
    
    return grouped;
  }

  String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return "Aujourd'hui";
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return 'Cette semaine';
    } else if (difference.inDays < 30) {
      return 'Ce mois';
    } else {
      return 'Plus ancien';
    }
  }

  /// Filtrer les notifications par type
  List<Map<String, dynamic>> filterByType(List<Map<String, dynamic>> notifications, String type) {
    return notifications.where((n) => n['type'] == type).toList();
  }

  /// Obtenir les notifications non lues (version simplifiée)
  List<Map<String, dynamic>> getUnread(List<Map<String, dynamic>> notifications) {
    return notifications.where((n) => n['read'] != true).toList();
  }

  /// Obtenir les notifications lues
  List<Map<String, dynamic>> getRead(List<Map<String, dynamic>> notifications) {
    return notifications.where((n) => n['read'] == true).toList();
  }
}

// ==================== TYPES DE NOTIFICATIONS POUR THIX MONEY ====================

class NotificationType {
  static const String payment = 'payment';
  static const String paymentReceived = 'payment_received';
  static const String transfer = 'transfer';
  static const String transferReceived = 'transfer_received';
  static const String creditApproved = 'credit_approved';
  static const String creditRequest = 'credit_request';
  static const String savings = 'savings';
  static const String savingsGoalReached = 'savings_goal_reached';
  static const String tontine = 'tontine';
  static const String tontineReminder = 'tontine_reminder';
  static const String investment = 'investment';
  static const String investmentReturn = 'investment_return';
  static const String insurance = 'insurance';
  static const String cashback = 'cashback';
  static const String lowBalance = 'low_balance';
  static const String promotion = 'promotion';
  static const String paymentReminder = 'payment_reminder';
  static const String like = 'like';
  static const String comment = 'comment';
  static const String connectionRequest = 'connection_request';
  static const String connectionAccepted = 'connection_accepted';
  static const String generic = 'generic';

  static List<String> getMoneyTypes() => [
    payment,
    paymentReceived,
    transfer,
    transferReceived,
    creditApproved,
    creditRequest,
    savings,
    savingsGoalReached,
    tontine,
    tontineReminder,
    investment,
    investmentReturn,
    insurance,
    cashback,
    lowBalance,
    promotion,
    paymentReminder,
  ];

  static List<String> getSocialTypes() => [
    like,
    comment,
    connectionRequest,
    connectionAccepted,
  ];

  static String getIcon(String type) {
    switch (type) {
      case payment:
      case paymentReceived:
        return '💰';
      case transfer:
      case transferReceived:
        return '💸';
      case creditApproved:
      case creditRequest:
        return '⚡';
      case savings:
      case savingsGoalReached:
        return '🏦';
      case tontine:
      case tontineReminder:
        return '👥';
      case investment:
      case investmentReturn:
        return '📈';
      case insurance:
        return '🛡️';
      case cashback:
        return '🔄';
      case lowBalance:
        return '⚠️';
      case promotion:
        return '🎉';
      case paymentReminder:
        return '⏰';
      case like:
        return '❤️';
      case comment:
        return '💬';
      case connectionRequest:
        return '🤝';
      case connectionAccepted:
        return '✓';
      default:
        return '📢';
    }
  }
}
