// lib/models/taxi.dart
import 'package:flutter/material.dart';

enum TaxiStatus { enAttente, enRoute, termine, annule }
enum VehiculeType { standard, confort, berline, van }

extension VehiculeTypeExtension on VehiculeType {
  String get label {
    switch (this) {
      case VehiculeType.standard:
        return 'Standard';
      case VehiculeType.confort:
        return 'Confort';
      case VehiculeType.berline:
        return 'Berline';
      case VehiculeType.van:
        return 'Van';
    }
  }

  double get tarifBase {
    switch (this) {
      case VehiculeType.standard:
        return 1000;
      case VehiculeType.confort:
        return 1500;
      case VehiculeType.berline:
        return 2000;
      case VehiculeType.van:
        return 2500;
    }
  }

  int get capacite {
    switch (this) {
      case VehiculeType.standard:
        return 4;
      case VehiculeType.confort:
        return 4;
      case VehiculeType.berline:
        return 4;
      case VehiculeType.van:
        return 7;
    }
  }
}

class Trajet {
  final String id;
  final String depart;
  final String arrivee;
  final String departAdresse;
  final String? arriveeAdresse;
  final double distanceKm;
  final int dureeMinutes;
  final DateTime date;
  final VehiculeType vehiculeType;
  final double prix;
  final String devise;
  final TaxiStatus status;
  final String? chauffeurNom;
  final String? chauffeurPhoto;
  final String? chauffeurNote;

  Trajet({
    required this.id,
    required this.depart,
    required this.arrivee,
    required this.departAdresse,
    this.arriveeAdresse,
    required this.distanceKm,
    required this.dureeMinutes,
    required this.date,
    required this.vehiculeType,
    required this.prix,
    required this.devise,
    required this.status,
    this.chauffeurNom,
    this.chauffeurPhoto,
    this.chauffeurNote,
  });

  String get prixFormate => '$prix $devise';
  String get dateFormate => '${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute}';
  String get distanceFormate => '${distanceKm.toStringAsFixed(1)} km';
  String get dureeFormate => '${dureeMinutes ~/ 60}h ${dureeMinutes % 60}min';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'depart': depart,
      'arrivee': arrivee,
      'departAdresse': departAdresse,
      'arriveeAdresse': arriveeAdresse,
      'distanceKm': distanceKm,
      'dureeMinutes': dureeMinutes,
      'date': date.toIso8601String(),
      'vehiculeType': vehiculeType.name,
      'prix': prix,
      'devise': devise,
      'status': status.name,
      'chauffeurNom': chauffeurNom,
      'chauffeurPhoto': chauffeurPhoto,
      'chauffeurNote': chauffeurNote,
    };
  }

  factory Trajet.fromJson(Map<String, dynamic> json) {
    return Trajet(
      id: json['id'] as String,
      depart: json['depart'] as String,
      arrivee: json['arrivee'] as String,
      departAdresse: json['departAdresse'] as String,
      arriveeAdresse: json['arriveeAdresse'] as String?,
      distanceKm: (json['distanceKm'] as num).toDouble(),
      dureeMinutes: json['dureeMinutes'] as int,
      date: DateTime.parse(json['date'] as String),
      vehiculeType: VehiculeType.values.firstWhere((e) => e.name == json['vehiculeType']),
      prix: (json['prix'] as num).toDouble(),
      devise: json['devise'] as String,
      status: TaxiStatus.values.firstWhere((e) => e.name == json['status']),
      chauffeurNom: json['chauffeurNom'] as String?,
      chauffeurPhoto: json['chauffeurPhoto'] as String?,
      chauffeurNote: json['chauffeurNote'] as String?,
    );
  }
}

// Mock data pour les trajets
List<Trajet> mockTrajets = [
  Trajet(
    id: '1',
    depart: 'Abidjan',
    arrivee: 'Yamoussoukro',
    departAdresse: 'Abidjan, Cocody',
    arriveeAdresse: 'Yamoussoukro, Centre',
    distanceKm: 240,
    dureeMinutes: 180,
    date: DateTime.now().subtract(const Duration(days: 2)),
    vehiculeType: VehiculeType.standard,
    prix: 25000,
    devise: 'FCFA',
    status: TaxiStatus.termine,
    chauffeurNom: 'Jean K.',
    chauffeurNote: '4.8',
  ),
];
