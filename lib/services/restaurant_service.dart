// lib/services/restaurant_service.dart
import 'dart:async';
import '../models/restaurant.dart';

class RestaurantService {
  // Récupérer tous les restaurants
  Future<List<Restaurant>> getAllRestaurants() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return mockRestaurants;
  }

  // Rechercher des restaurants
  Future<List<Restaurant>> rechercherRestaurants({
    String? query,
    String? cuisine,
    double? maxDistance,
    double? minNote,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    var restaurants = List.from(mockRestaurants);
    
    if (query != null && query.isNotEmpty) {
      restaurants = restaurants.where((r) =>
        r.nom.toLowerCase().contains(query.toLowerCase()) ||
        r.cuisine.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
    
    if (cuisine != null && cuisine != 'Tous') {
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
      return mockRestaurants.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  // Récupérer les restaurants à proximité
  Future<List<Restaurant>> getRestaurantsProches({double maxDistance = 5}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockRestaurants.where((r) => r.distanceKm <= maxDistance).toList();
  }

  // Récupérer les catégories de cuisine disponibles
  Future<List<String>> getCuisinesDisponibles() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return ['Africaine', 'Fast Food', 'Italienne', 'Japonaise', 'Française', 'Asiatique'];
  }
}
