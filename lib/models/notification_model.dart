// lib/models/notification_model.dart
import 'package:flutter/material.dart';

enum AppNotificationType {
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
  like,
  comment,
  connectionRequest,
  connectionAccepted,
  generic,
}

extension AppNotificationTypeExtension on AppNotificationType {
  String get label {
    switch (this) {
      case AppNotificationType.payment:
        return 'Paiement';
      case AppNotificationType.paymentReceived:
        return 'Paiement reçu';
      case AppNotificationType.transfer:
        return 'Virement';
      case AppNotificationType.transferReceived:
        return 'Virement reçu';
      case AppNotificationType.creditApproved:
        return 'Crédit approuvé';
      case AppNotificationType.creditRequest:
        return 'Demande de crédit';
      case AppNotificationType.savings:
        return 'Épargne';
      case AppNotificationType.savingsGoalReached:
        return 'Objectif atteint';
      case AppNotificationType.tontine:
        return 'Tontine';
      case AppNotificationType.tontineReminder:
        return 'Rappel tontine';
      case AppNotificationType.investment:
        return 'Investissement';
      case AppNotificationType.investmentReturn:
        return 'Retour investissement';
      case AppNotificationType.insurance:
        return 'Assurance';
      case AppNotificationType.cashback:
        return 'Cashback';
      case AppNotificationType.lowBalance:
        return 'Solde faible';
      case AppNotificationType.promotion:
        return 'Promotion';
      case AppNotificationType.paymentReminder:
        return 'Rappel paiement';
      case AppNotificationType.like:
        return 'Like';
      case AppNotificationType.comment:
        return 'Commentaire';
      case AppNotificationType.connectionRequest:
        return 'Demande de connexion';
      case AppNotificationType.connectionAccepted:
        return 'Connexion acceptée';
      case AppNotificationType.generic:
        return 'Notification';
    }
  }

  IconData get icon {
    switch (this) {
      case AppNotificationType.payment:
      case AppNotificationType.paymentReceived:
        return Icons.payment;
      case AppNotificationType.transfer:
      case AppNotificationType.transferReceived:
        return Icons.swap_horiz;
      case AppNotificationType.creditApproved:
      case AppNotificationType.creditRequest:
        return Icons.bolt;
      case AppNotificationType.savings:
      case AppNotificationType.savingsGoalReached:
        return Icons.savings;
      case AppNotificationType.tontine:
      case AppNotificationType.tontineReminder:
        return Icons.group;
      case AppNotificationType.investment:
      case AppNotificationType.investmentReturn:
        return Icons.trending_up;
      case AppNotificationType.insurance:
        return Icons.shield;
      case AppNotificationType.cashback:
        return Icons.percent;
      case AppNotificationType.lowBalance:
        return Icons.warning;
      case AppNotificationType.promotion:
        return Icons.local_offer;
      case AppNotificationType.paymentReminder:
        return Icons.alarm;
      case AppNotificationType.like:
        return Icons.favorite;
      case AppNotificationType.comment:
        return Icons.comment;
      case AppNotificationType.connectionRequest:
        return Icons.person_add;
      case AppNotificationType.connectionAccepted:
        return Icons.check_circle;
      case AppNotificationType.generic:
        return Icons.notifications;
    }
  }

  Color get color {
    switch (this) {
      case AppNotificationType.payment:
      case AppNotificationType.paymentReceived:
        return Colors.green;
      case AppNotificationType.transfer:
      case AppNotificationType.transferReceived:
        return Colors.blue;
      case AppNotificationType.creditApproved:
        return const Color(0xFFD4AF37);
      case AppNotificationType.creditRequest:
        return Colors.orange;
      case AppNotificationType.savings:
      case AppNotificationType.savingsGoalReached:
        return Colors.teal;
      case AppNotificationType.tontine:
      case AppNotificationType.tontineReminder:
        return Colors.indigo;
      case AppNotificationType.investment:
      case AppNotificationType.investmentReturn:
        return Colors.purple;
      case AppNotificationType.insurance:
        return Colors.cyan;
      case AppNotificationType.cashback:
        return Colors.amber;
      case AppNotificationType.lowBalance:
        return Colors.red;
      case AppNotificationType.promotion:
        return Colors.pink;
      case AppNotificationType.paymentReminder:
        return Colors.deepOrange;
      case AppNotificationType.like:
        return Colors.red;
      case AppNotificationType.comment:
        return Colors.blue;
      case AppNotificationType.connectionRequest:
      case AppNotificationType.connectionAccepted:
        return Colors.green;
      case AppNotificationType.generic:
        return Colors.grey;
    }
  }
}

class AppNotification {
  final String id;
  final String userId;
  final AppNotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  bool isRead;
  final Map<String, dynamic>? data;
  final String? actorId;
  final String? actorName;
  final String? actorAvatar;
  final String? postId;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    this.data,
    this.actorId,
    this.actorName,
    this.actorAvatar,
    this.postId,
  });

  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);
    
    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} j';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Il y a $weeks sem';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.name,
      'title': title,
      'body': body,
      'created_at': createdAt.toIso8601String(),
      'read': isRead,
      'data': data,
      'actor_id': actorId,
      'actor_name': actorName,
      'actor_avatar': actorAvatar,
      'post_id': postId,
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: AppNotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AppNotificationType.generic,
      ),
      title: json['title'] as String,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['read'] as bool? ?? false,
      data: json['data'] as Map<String, dynamic>?,
      actorId: json['actor_id'] as String?,
      actorName: json['actor_name'] as String?,
      actorAvatar: json['actor_avatar'] as String?,
      postId: json['post_id'] as String?,
    );
  }
}
