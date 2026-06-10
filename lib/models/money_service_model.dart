// lib/models/money_service_model.dart
import 'package:flutter/material.dart';

class MoneyServiceModel {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final String route;
  final String category;
  final bool isAvailable;
  final String? badgeText;

  MoneyServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
    this.category = 'finance',
    this.isAvailable = true,
    this.badgeText,
  });

  MoneyServiceModel copyWith({
    String? id,
    String? name,
    String? description,
    IconData? icon,
    Color? color,
    String? route,
    String? category,
    bool? isAvailable,
    String? badgeText,
  }) {
    return MoneyServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      route: route ?? this.route,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      badgeText: badgeText ?? this.badgeText,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'color': color.value,
      'route': route,
      'category': category,
      'isAvailable': isAvailable,
      'badgeText': badgeText,
    };
  }

  factory MoneyServiceModel.fromJson(Map<String, dynamic> json) {
    return MoneyServiceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: IconData(json['icon'] as int, fontFamily: json['iconFontFamily'] as String?),
      color: Color(json['color'] as int),
      route: json['route'] as String,
      category: json['category'] as String? ?? 'finance',
      isAvailable: json['isAvailable'] as bool? ?? true,
      badgeText: json['badgeText'] as String?,
    );
  }
}

// Données mockées
List<MoneyServiceModel> mockMoneyServices = [
  MoneyServiceModel(
    id: '1',
    name: 'Crédit instantané',
    description: 'Obtenez un crédit rapidement',
    icon: Icons.flash_on,
    color: const Color(0xFFD4AF37),
    route: '/money/credit',
    category: 'finance',
    badgeText: 'Jusqu\'à 5M',
  ),
  MoneyServiceModel(
    id: '2',
    name: 'Assurance',
    description: 'Protégez-vous et vos proches',
    icon: Icons.shield,
    color: Colors.blue,
    route: '/money/insurance',
    category: 'finance',
  ),
  MoneyServiceModel(
    id: '3',
    name: 'Épargne planifiée',
    description: 'Atteignez vos objectifs',
    icon: Icons.savings,
    color: Colors.green,
    route: '/money/savings',
    category: 'savings',
  ),
  MoneyServiceModel(
    id: '4',
    name: 'Change',
    description: 'Achetez et vendez des devises',
    icon: Icons.currency_exchange,
    color: Colors.orange,
    route: '/money/exchange',
    category: 'finance',
  ),
  MoneyServiceModel(
    id: '5',
    name: 'Marchand',
    description: 'Gérez vos encaissements',
    icon: Icons.store,
    color: Colors.purple,
    route: '/money/merchant',
    category: 'business',
  ),
  MoneyServiceModel(
    id: '6',
    name: 'Don & Contributions',
    description: 'Soutenez des causes',
    icon: Icons.favorite,
    color: Colors.red,
    route: '/money/donations',
    category: 'social',
  ),
  MoneyServiceModel(
    id: '7',
    name: 'Ma Tontine',
    description: 'Épargnez et recevez',
    icon: Icons.group,
    color: Colors.teal,
    route: '/money/tontine',
    category: 'savings',
  ),
  MoneyServiceModel(
    id: '8',
    name: 'Éducation',
    description: 'Financez les études',
    icon: Icons.school,
    color: Colors.indigo,
    route: '/money/education',
    category: 'finance',
  ),
  MoneyServiceModel(
    id: '9',
    name: 'Virement international',
    description: 'Envoyez et recevez',
    icon: Icons.public,
    color: Colors.cyan,
    route: '/money/international',
    category: 'transfer',
  ),
  MoneyServiceModel(
    id: '10',
    name: 'Microfinance',
    description: 'Financements adaptés',
    icon: Icons.account_balance,
    color: Colors.brown,
    route: '/money/microfinance',
    category: 'finance',
  ),
  MoneyServiceModel(
    id: '11',
    name: 'Investissement',
    description: 'Faites fructifier votre argent',
    icon: Icons.show_chart,
    color: Colors.lime,
    route: '/money/investment',
    category: 'investment',
  ),
  MoneyServiceModel(
    id: '12',
    name: 'Planification financière',
    description: 'Planifiez votre avenir',
    icon: Icons.analytics,
    color: Colors.deepPurple,
    route: '/money/planning',
    category: 'planning',
  ),
  MoneyServiceModel(
    id: '13',
    name: 'Épargne groupe',
    description: 'Épargnez en groupe',
    icon: Icons.people,
    color: const Color(0xFFC0CA33),
    route: '/money/group-savings',
    category: 'savings',
  ),
];
