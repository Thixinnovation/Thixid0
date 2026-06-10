// lib/models/vol.dart
import 'package:flutter/material.dart';

class Vol {
  final String id;
  final String compagnie;
  final String codeVol;
  final String depart;
  final String arrivee;
  final String heureDepart;
  final String heureArrivee;
  final String duree;
  final int escales;
  final String? escaleVille;
  final double prix;
  final String devise;
  final String bagageCabine;
  final String bagageSoute;
  final bool repasInclus;
  final String classe;
  final DateTime dateDepart;
  final DateTime? dateRetour;
  final String? imageUrl;

  Vol({
    required this.id,
    required this.compagnie,
    required this.codeVol,
    required this.depart,
    required this.arrivee,
    required this.heureDepart,
    required this.heureArrivee,
    required this.duree,
    required this.escales,
    this.escaleVille,
    required this.prix,
    required this.devise,
    required this.bagageCabine,
    required this.bagageSoute,
    required this.repasInclus,
    required this.classe,
    required this.dateDepart,
    this.dateRetour,
    this.imageUrl,
  });

  String get prixFormate => '$prix $devise';
  String get dureeFormate => escales == 0 ? '$duree (Direct)' : '$duree ($escales escale)';
  bool get isDirect => escales == 0;
  String get dateDepartFormate => '${dateDepart.day}/${dateDepart.month}/${dateDepart.year}';

  double get prixTotal => prix;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'compagnie': compagnie,
      'codeVol': codeVol,
      'depart': depart,
      'arrivee': arrivee,
      'heureDepart': heureDepart,
      'heureArrivee': heureArrivee,
      'duree': duree,
      'escales': escales,
      'escaleVille': escaleVille,
      'prix': prix,
      'devise': devise,
      'bagageCabine': bagageCabine,
      'bagageSoute': bagageSoute,
      'repasInclus': repasInclus,
      'classe': classe,
      'dateDepart': dateDepart.toIso8601String(),
      'dateRetour': dateRetour?.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }

  factory Vol.fromJson(Map<String, dynamic> json) {
    return Vol(
      id: json['id'] as String,
      compagnie: json['compagnie'] as String,
      codeVol: json['codeVol'] as String,
      depart: json['depart'] as String,
      arrivee: json['arrivee'] as String,
      heureDepart: json['heureDepart'] as String,
      heureArrivee: json['heureArrivee'] as String,
      duree: json['duree'] as String,
      escales: json['escales'] as int,
      escaleVille: json['escaleVille'] as String?,
      prix: (json['prix'] as num).toDouble(),
      devise: json['devise'] as String,
      bagageCabine: json['bagageCabine'] as String,
      bagageSoute: json['bagageSoute'] as String,
      repasInclus: json['repasInclus'] as bool,
      classe: json['classe'] as String,
      dateDepart: DateTime.parse(json['dateDepart'] as String),
      dateRetour: json['dateRetour'] != null ? DateTime.parse(json['dateRetour'] as String) : null,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

// Mock data pour les vols
List<Vol> mockVols = [
  Vol(
    id: '1',
    compagnie: 'Ethiopian Airlines',
    codeVol: 'ET 914',
    depart: 'Kinshasa (FIH)',
    arrivee: 'Paris (CDG)',
    heureDepart: '23:45',
    heureArrivee: '06:10',
    duree: '10h 25min',
    escales: 0,
    prix: 780,
    devise: 'USD',
    bagageCabine: '7kg',
    bagageSoute: '23kg',
    repasInclus: true,
    classe: 'Économique',
    dateDepart: DateTime.now().add(const Duration(days: 7)),
  ),
  Vol(
    id: '2',
    compagnie: 'Turkish Airlines',
    codeVol: 'TK 543',
    depart: 'Kinshasa (FIH)',
    arrivee: 'Paris (CDG)',
    heureDepart: '18:30',
    heureArrivee: '09:15',
    duree: '13h 45min',
    escales: 1,
    escaleVille: 'Istanbul',
    prix: 650,
    devise: 'USD',
    bagageCabine: '8kg',
    bagageSoute: '23kg',
    repasInclus: true,
    classe: 'Économique',
    dateDepart: DateTime.now().add(const Duration(days: 7)),
  ),
  Vol(
    id: '3',
    compagnie: 'Air France',
    codeVol: 'AF 771',
    depart: 'Kinshasa (FIH)',
    arrivee: 'Paris (CDG)',
    heureDepart: '10:15',
    heureArrivee: '16:50',
    duree: '8h 35min',
    escales: 0,
    prix: 920,
    devise: 'USD',
    bagageCabine: '12kg',
    bagageSoute: '23kg',
    repasInclus: true,
    classe: 'Économique',
    dateDepart: DateTime.now().add(const Duration(days: 7)),
  ),
  Vol(
    id: '4',
    compagnie: 'Qatar Airways',
    codeVol: 'QR 1490',
    depart: 'Kinshasa (FIH)',
    arrivee: 'Paris (CDG)',
    heureDepart: '01:20',
    heureArrivee: '13:40',
    duree: '14h 20min',
    escales: 1,
    escaleVille: 'Doha',
    prix: 670,
    devise: 'USD',
    bagageCabine: '7kg',
    bagageSoute: '25kg',
    repasInclus: true,
    classe: 'Économique',
    dateDepart: DateTime.now().add(const Duration(days: 7)),
  ),
];
