// lib/models/restaurant.dart
import 'package:flutter/material.dart';

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

// Mock data pour les restaurants
List<Restaurant> mockRestaurants = [
  Restaurant(
    id: '1',
    nom: "Le Goût d'Ici",
    type: 'Restaurant',
    cuisine: 'Africaine',
    note: 4.6,
    avisCount: 234,
    adresse: 'Cocody, Rue des Jardins',
    ville: 'Abidjan',
    prixMoyen: 15000,
    devise: 'FCFA',
    horaires: '11h - 22h',
    tempsLivraison: '20-30 min',
    distanceKm: 1.2,
    imagesUrl: [],
    specialites: ['Attiéké', 'Poisson braisé', 'Alloco'],
    fraisLivraison: 2000,
  ),
  Restaurant(
    id: '2',
    nom: 'Fast & Good',
    type: 'Fast Food',
    cuisine: 'Américaine',
    note: 4.8,
    avisCount: 567,
    adresse: 'Plateau, Boulevard Carde',
    ville: 'Abidjan',
    prixMoyen: 5000,
    devise: 'FCFA',
    horaires: '10h - 23h',
    tempsLivraison: '15-25 min',
    distanceKm: 0.8,
    imagesUrl: [],
    specialites: ['Burger', 'Frites', 'Tacos'],
    livraisonGratuite: true,
  ),
];
