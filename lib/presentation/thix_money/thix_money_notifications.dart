// lib/presentation/thix_money/thix_money_notifications.dart
import 'package:flutter/material.dart';
import 'package:thix_id/presentation/thix_money/widgets/notification_item.dart';
import 'package:thix_id/presentation/thix_money/widgets/empty_state.dart';

class ThixMoneyNotifications extends StatelessWidget {
  const ThixMoneyNotifications({super.key});

  final List<Map<String, dynamic>> _notifications = const [
    {
      'title': 'Paiement reçu',
      'message': 'Vous avez reçu 150 000 FCFA de Jean Dupont',
      'time': 'Il y a 5 minutes',
      'icon': Icons.arrow_downward,
      'iconColor': Colors.green,
      'isRead': false,
    },
    {
      'title': 'Crédit approuvé',
      'message': 'Votre demande de crédit de 500 000 FCFA a été approuvée',
      'time': 'Il y a 2 heures',
      'icon': Icons.bolt,
      'iconColor': Color(0xFFD4AF37),
      'isRead': false,
    },
    {
      'title': 'Paiement effectué',
      'message': 'Paiement de 35 000 FCFA chez Market Store',
      'time': 'Hier',
      'icon': Icons.shopping_cart,
      'iconColor': Colors.red,
      'isRead': true,
    },
    {
      'title': 'Cashback crédité',
      'message': 'Vous avez reçu 5 000 FCFA de cashback',
      'time': 'Hier',
      'icon': Icons.percent,
      'iconColor': Colors.orange,
      'isRead': true,
    },
    {
      'title': 'Tontine',
      'message': 'Votre contribution à Tontine Business est due dans 3 jours',
      'time': 'Il y a 2 jours',
      'icon': Icons.group,
      'iconColor': Colors.teal,
      'isRead': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF0B1B3D),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Tout marquer lu', style: TextStyle(color: Color(0xFFD4AF37))),
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? const EmptyState(
              icon: Icons.notifications_none,
              message: 'Aucune notification',
              subtitle: 'Vos notifications apparaîtront ici',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: NotificationItem(
                    title: notification['title'],
                    message: notification['message'],
                    time: notification['time'],
                    icon: notification['icon'],
                    iconColor: notification['iconColor'],
                    isRead: notification['isRead'],
                    onTap: () {
                      // Marquer comme lu et naviguer
                    },
                  ),
                );
              },
            ),
    );
  }
}
