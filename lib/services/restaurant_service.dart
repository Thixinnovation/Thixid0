// lib/services/restaurant_service.dart
import 'dart:async';

class Restaurant {
  final String id;
  final String nom;
  final String type;
  final String cuisine;
  final double note;
  final int avisCount;
  final String adresse;
  final String ville;
  final double prixMoyen;
  final String devise;
  final String horaires;
  final String tempsLivraison;
  final double distanceKm;
  final List<String> imagesUrl;
  final List<String> specialites;
  final bool livraisonGratuite;
  final double? fraisLivraison;

  Restaurant({
    required this.id,
    required this.nom,
    required this.type,
    required this.cuisine,
    required this.note,
    required this.avisCount,
    required this.adresse,
    required this.ville,
    required this.prixMoyen,
    required this.devise,
    required this.horaires,
    required this.tempsLivraison,
    required this.distanceKm,
    required this.imagesUrl,
    required this.specialites,
    this.livraisonGratuite = false,
    this.fraisLivraison,
  });

  String get noteFormate => note.toStringAsFixed(1);
  String get prixFormate => '$prixMoyen $devise';
  String get distanceFormate => '${distanceKm.toStringAsFixed(1)} km';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'type': type,
      'cuisine': cuisine,
      'note': note,
      'avisCount': avisCount,
      'adresse': adresse,
      'ville': ville,
      'prixMoyen': prixMoyen,
      'devise': devise,
      'horaires': horaires,
      'tempsLivraison': tempsLivraison,
      'distanceKm': distanceKm,
      'imagesUrl': imagesUrl,
      'specialites': specialites,
      'livraisonGratuite': livraisonGratuite,
      'fraisLivraison': fraisLivraison,
    };
  }

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] as String,
      nom: json['nom'] as String,
      type: json['type'] as String,
      cuisine: json['cuisine'] as String,
      note: (json['note'] as num).toDouble(),
      avisCount: json['avisCount'] as int,
      adresse: json['adresse'] as String,
      ville: json['ville'] as String,
      prixMoyen: (json['prixMoyen'] as num).toDouble(),
      devise: json['devise'] as String,
      horaires: json['horaires'] as String,
      tempsLivraison: json['tempsLivraison'] as String,
      distanceKm: (json['distanceKm'] as num).toDouble(),
      imagesUrl: List<String>.from(json['imagesUrl']),
      specialites: List<String>.from(json['specialites']),
      livraisonGratuite: json['livraisonGratuite'] as bool? ?? false,
      fraisLivraison: json['fraisLivraison'] as double?,
    );
  }
}

class RestaurantService {
  // Récupérer tous les restaurants
  Future<List<Restaurant>> getAllRestaurants() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _getMockRestaurants();
  }

  // Rechercher des restaurants
  Future<List<Restaurant>> rechercherRestaurants({
    String? query,
    String? cuisine,
    double? maxDistance,
    double? minNote,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    List<Restaurant> restaurants = _getMockRestaurants();
    
    if (query != null && query.isNotEmpty) {
      restaurants = restaurants.where((r) =>
        r.nom.toLowerCase().contains(query.toLowerCase()) ||
        r.cuisine.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
    
    if (cuisine != null && cuisine != 'Tous' && cuisine != 'Toutes') {
      restaurants = restaurants.where((r) => r.cuisine == cuisine).toList();
    }
    
    if (maxDistance != null) {
      restaurants = restaurants.where((r) => r.distanceKm <= maxDistance).toList();
    }
    
    if (minNote != null) {
      restaurants = restaurants.where((r) => r.note >= minNote).toList();
    }
    
    return restaurants;
  }

  // Récupérer un restaurant par ID
  Future<Restaurant?> getRestaurantById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _getMockRestaurants().firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  // Récupérer les restaurants à proximité
  Future<List<Restaurant>> getRestaurantsProches({double maxDistance = 5}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _getMockRestaurants().where((r) => r.distanceKm <= maxDistance).toList();
  }

  // Récupérer les catégories de cuisine disponibles
  Future<List<String>> getCuisinesDisponibles() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return ['Africaine', 'Fast Food', 'Italienne', 'Japonaise', 'Francaise', 'Asiatique', 'Americaine'];
  }

  // Récupérer les restaurants populaires
  Future<List<Restaurant>> getRestaurantsPopulaires() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final restaurants = _getMockRestaurants();
    restaurants.sort((a, b) => b.avisCount.compareTo(a.avisCount));
    return restaurants.take(3).toList();
  }

  // Récupérer les offres du moment
  Future<List<Restaurant>> getOffresMoment() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _getMockRestaurants().take(2).toList();
  }

  // Données mockées
  List<Restaurant> _getMockRestaurants() {
    return [
      Restaurant(
        id: '1',
        nom: 'Le Gout Ici',
        type: 'Restaurant',
        cuisine: 'Africaine',
        note: 4.6,
        avisCount: 234,
        adresse: 'Cocody, Rue des Jardins',
        ville: 'Abidjan',
        prixMoyen: 15000,
        devise: 'FCFA',
        horaires: '11h-22h',
        tempsLivraison: '20-30 min',
        distanceKm: 1.2,
        imagesUrl: [],
        specialites: ['Attieke', 'Poisson braise', 'Alloco'],
        livraisonGratuite: false,
        fraisLivraison: 2000,
      ),
      Restaurant(
        id: '2',
        nom: 'Fast Good',
        type: 'Fast Food',
        cuisine: 'Americaine',
        note: 4.8,
        avisCount: 567,
        adresse: 'Plateau, Boulevard Carde',
        ville: 'Abidjan',
        prixMoyen: 5000,
        devise: 'FCFA',
        horaires: '10h-23h',
        tempsLivraison: '15-25 min',
        distanceKm: 0.8,
        imagesUrl: [],
        specialites: ['Burger', 'Frites', 'Tacos'],
        livraisonGratuite: true,
      ),
      Restaurant(
        id: '3',
        nom: 'Pizza Time',
        type: 'Restaurant',
        cuisine: 'Italienne',
        note: 4.5,
        avisCount: 389,
        adresse: 'Deux Plateaux, Rue des Pates',
        ville: 'Abidjan',
        prixMoyen: 12000,
        devise: 'FCFA',
        horaires: '12h-23h',
        tempsLivraison: '20-30 min',
        distanceKm: 2.1,
        imagesUrl: [],
        specialites: ['Pizza', 'Pasta', 'Tiramisu'],
        livraisonGratuite: false,
        fraisLivraison: 1500,
      ),
      Restaurant(
        id: '4',
        nom: 'Sushi House',
        type: 'Restaurant',
        cuisine: 'Japonaise',
        note: 4.7,
        avisCount: 456,
        adresse: 'Zone 4, Rue des Sushis',
        ville: 'Abidjan',
        prixMoyen: 18000,
        devise: 'FCFA',
        horaires: '12h-22h30',
        tempsLivraison: '25-35 min',
        distanceKm: 3.0,
        imagesUrl: [],
        specialites: ['Sushi', 'Sashimi', 'Maki'],
        livraisonGratuite: false,
        fraisLivraison: 2500,
      ),
    ];
  }
}
