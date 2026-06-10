// lib/models/bus.dart
import 'package:flutter/material.dart';

class Bus {
  final String id;
  final String compagnie;
  final String depart;
  final String arrivee;
  final String heureDepart;
  final String heureArrivee;
  final String duree;
  final double prix;
  final String devise;
  final int siegesDisponibles;
  final int siegesTotal;
  final List<String> amenities;
  final DateTime dateDepart;
  final String? imageUrl;

  Bus({
    required this.id,
    required this.compagnie,
    required this.depart,
    required this.arrivee,
    required this.heureDepart,
    required this.heureArrivee,
    required this.duree,
    required this.prix,
    required this.devise,
    required this.siegesDisponibles,
    required this.siegesTotal,
    required this.amenities,
    required this.dateDepart,
    this.imageUrl,
  });

  String get prixFormate => '$prix $devise';
  String get dateDepartFormate => '${dateDepart.day}/${dateDepart.month}/${dateDepart.year}';
  int get siegesOccupes => siegesTotal - siegesDisponibles;
  double get tauxRemplissage => siegesOccupes / siegesTotal;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'compagnie': compagnie,
      'depart': depart,
      'arrivee': arrivee,
      'heureDepart': heureDepart,
      'heureArrivee': heureArrivee,
      'duree': duree,
      'prix': prix,
      'devise': devise,
      'siegesDisponibles': siegesDisponibles,
      'siegesTotal': siegesTotal,
      'amenities': amenities,
      'dateDepart': dateDepart.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }

  factory Bus.fromJson(Map<String, dynamic> json) {
    return Bus(
      id: json['id'] as String,
      compagnie: json['compagnie'] as String,
      depart: json['depart'] as String,
      arrivee: json['arrivee'] as String,
      heureDepart: json['heureDepart'] as String,
      heureArrivee: json['heureArrivee'] as String,
      duree: json['duree'] as String,
      prix: (json['prix'] as num).toDouble(),
      devise: json['devise'] as String,
      siegesDisponibles: json['siegesDisponibles'] as int,
      siegesTotal: json['siegesTotal'] as int,
      amenities: List<String>.from(json['amenities']),
      dateDepart: DateTime.parse(json['dateDepart'] as String),
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

// Mock data pour les bus
List<Bus> mockBus = [
  Bus(
    id: '1',
    compagnie: 'Rapide Bus',
    depart: 'Abidjan',
    arrivee: 'Yamoussoukro',
    heureDepart: '08:00',
    heureArrivee: '12:00',
    duree: '4h',
    prix: 5000,
    devise: 'FCFA',
    siegesDisponibles: 45,
    siegesTotal: 50,
    amenities: ['Climatisation', 'Wi-Fi', 'Prise USB'],
    dateDepart: DateTime.now().add(const Duration(days: 7)),
  ),
  Bus(
    id: '2',
    compagnie: 'Confort Lines',
    depart: 'Abidjan',
    arrivee: 'Yamoussoukro',
    heureDepart: '10:00',
    heureArrivee: '14:00',
    duree: '4h',
    prix: 6500,
    devise: 'FCFA',
    siegesDisponibles: 50,
    siegesTotal: 50,
    amenities: ['Climatisation', 'Wi-Fi', 'Prise USB', 'TV', 'Boisson offerte'],
    dateDepart: DateTime.now().add(const Duration(days: 7)),
  ),
  Bus(
    id: '3',
    compagnie: 'Express Voyages',
    depart: 'Abidjan',
    arrivee: 'Bouaké',
    heureDepart: '14:00',
    heureArrivee: '18:00',
    duree: '4h',
    prix: 5500,
    devise: 'FCFA',
    siegesDisponibles: 40,
    siegesTotal: 50,
    amenities: ['Climatisation', 'Prise USB'],
    dateDepart: DateTime.now().add(const Duration(days: 7)),
  ),
];
