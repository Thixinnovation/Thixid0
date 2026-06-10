// lib/models/hotel.dart
import 'package:flutter/material.dart';

class Hotel {
  final String id;
  final String nom;
  final String ville;
  final String pays;
  final double note;
  final int avisCount;
  final double prixMin;
  final String devise;
  final List<String> imagesUrl;
  final List<String> amenities;
  final String description;
  final double latitude;
  final double longitude;
  final String? adresseComplete;

  Hotel({
    required this.id,
    required this.nom,
    required this.ville,
    required this.pays,
    required this.note,
    required this.avisCount,
    required this.prixMin,
    required this.devise,
    required this.imagesUrl,
    required this.amenities,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.adresseComplete,
  });

  String get prixFormate => '$prixMin $devise';
  String get noteFormate => note.toStringAsFixed(1);
  String get localisation => '$ville, $pays';
  double get prixEnFcfa => devise == 'EUR' ? prixMin * 655.96 : prixMin;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'ville': ville,
      'pays': pays,
      'note': note,
      'avisCount': avisCount,
      'prixMin': prixMin,
      'devise': devise,
      'imagesUrl': imagesUrl,
      'amenities': amenities,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'adresseComplete': adresseComplete,
    };
  }

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json['id'] as String,
      nom: json['nom'] as String,
      ville: json['ville'] as String,
      pays: json['pays'] as String,
      note: (json['note'] as num).toDouble(),
      avisCount: json['avisCount'] as int,
      prixMin: (json['prixMin'] as num).toDouble(),
      devise: json['devise'] as String,
      imagesUrl: List<String>.from(json['imagesUrl']),
      amenities: List<String>.from(json['amenities']),
      description: json['description'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      adresseComplete: json['adresseComplete'] as String?,
    );
  }
}

// Mock data pour les hôtels
List<Hotel> mockHotels = [
  Hotel(
    id: '1',
    nom: 'Azalai Hôtel Abidjan',
    ville: 'Abidjan',
    pays: 'Côte d\'Ivoire',
    note: 4.5,
    avisCount: 1234,
    prixMin: 68000,
    devise: 'FCFA',
    imagesUrl: [],
    amenities: ['Wi-Fi', 'Piscine', 'Spa', 'Restaurant', 'Parking', 'Salle de sport'],
    description: 'L\'Azalai Hôtel Abidjan est un établissement 4 étoiles situé en plein cœur du Plateau. Il propose des chambres luxueuses, une piscine extérieure, un spa et un restaurant gastronomique.',
    latitude: 5.3176,
    longitude: -4.0125,
  ),
  Hotel(
    id: '2',
    nom: 'Onomo Hôtel Dakar',
    ville: 'Dakar',
    pays: 'Sénégal',
    note: 4.2,
    avisCount: 892,
    prixMin: 63750,
    devise: 'FCFA',
    imagesUrl: [],
    amenities: ['Wi-Fi', 'Piscine', 'Restaurant', 'Parking'],
    description: 'L\'Onomo Hôtel Dakar propose des chambres modernes et confortables à proximité de l\'aéroport.',
    latitude: 14.7167,
    longitude: -17.4677,
  ),
  Hotel(
    id: '3',
    nom: 'Pullman Hôtel Paris',
    ville: 'Paris',
    pays: 'France',
    note: 4.6,
    avisCount: 2345,
    prixMin: 198,
    devise: 'EUR',
    imagesUrl: [],
    amenities: ['Wi-Fi', 'Piscine', 'Spa', 'Restaurant', 'Parking', 'Salle de sport', 'Business center'],
    description: 'Le Pullman Hôtel Paris est situé en plein centre de Paris, à proximité de la Tour Eiffel.',
    latitude: 48.8566,
    longitude: 2.3522,
  ),
];
