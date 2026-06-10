// lib/models/annonce.dart
import 'package:flutter/material.dart';

enum AnnonceType { vente, location, service, emploi, evenement }

extension AnnonceTypeExtension on AnnonceType {
  String get label {
    switch (this) {
      case AnnonceType.vente:
        return 'À VENDRE';
      case AnnonceType.location:
        return 'À LOUER';
      case AnnonceType.service:
        return 'SERVICE';
      case AnnonceType.emploi:
        return 'EMPLOI';
      case AnnonceType.evenement:
        return 'ÉVÉNEMENT';
    }
  }

  Color get color {
    switch (this) {
      case AnnonceType.vente:
        return Colors.green;
      case AnnonceType.location:
        return Colors.red;
      case AnnonceType.service:
        return Colors.teal;
      case AnnonceType.emploi:
        return Colors.blue;
      case AnnonceType.evenement:
        return Colors.purple;
    }
  }
}

class Annonce {
  final String id;
  final AnnonceType type;
  final String titre;
  final String description;
  final double prix;
  final String devise;
  final String? localisation;
  final String? contact;
  final List<String> imagesUrl;
  final DateTime datePublication;
  final DateTime? dateExpiration;
  final String? vendeurNom;
  final String? vendeurAvatar;
  final bool estVerifie;

  Annonce({
    required this.id,
    required this.type,
    required this.titre,
    required this.description,
    required this.prix,
    required this.devise,
    this.localisation,
    this.contact,
    required this.imagesUrl,
    required this.datePublication,
    this.dateExpiration,
    this.vendeurNom,
    this.vendeurAvatar,
    this.estVerifie = false,
  });

  String get prixFormate => '$prix $devise';
  String get datePublicationFormate => '${datePublication.day}/${datePublication.month}/${datePublication.year}';
  bool get estActif => dateExpiration == null || dateExpiration!.isAfter(DateTime.now());

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'titre': titre,
      'description': description,
      'prix': prix,
      'devise': devise,
      'localisation': localisation,
      'contact': contact,
      'imagesUrl': imagesUrl,
      'datePublication': datePublication.toIso8601String(),
      'dateExpiration': dateExpiration?.toIso8601String(),
      'vendeurNom': vendeurNom,
      'vendeurAvatar': vendeurAvatar,
      'estVerifie': estVerifie,
    };
  }

  factory Annonce.fromJson(Map<String, dynamic> json) {
    return Annonce(
      id: json['id'] as String,
      type: AnnonceType.values.firstWhere((e) => e.name == json['type']),
      titre: json['titre'] as String,
      description: json['description'] as String,
      prix: (json['prix'] as num).toDouble(),
      devise: json['devise'] as String,
      localisation: json['localisation'] as String?,
      contact: json['contact'] as String?,
      imagesUrl: List<String>.from(json['imagesUrl']),
      datePublication: DateTime.parse(json['datePublication'] as String),
      dateExpiration: json['dateExpiration'] != null ? DateTime.parse(json['dateExpiration'] as String) : null,
      vendeurNom: json['vendeurNom'] as String?,
      vendeurAvatar: json['vendeurAvatar'] as String?,
      estVerifie: json['estVerifie'] as bool? ?? false,
    );
  }
}

// Mock data pour les annonces
List<Annonce> mockAnnonces = [
  Annonce(
    id: '1',
    type: AnnonceType.vente,
    titre: 'Toyota RAV4 2021',
    description: 'Véhicule en excellent état, 45000 km, entretien régulier.',
    prix: 25000000,
    devise: 'FC',
    localisation: 'Abidjan',
    contact: '07XXXXXXXX',
    imagesUrl: [],
    datePublication: DateTime.now().subtract(const Duration(days: 3)),
    vendeurNom: 'Jean K.',
    estVerifie: true,
  ),
  Annonce(
    id: '2',
    type: AnnonceType.location,
    titre: 'Appartement 3 pièces',
    description: 'Appartement meublé, quartier calme, proche commerces.',
    prix: 600000,
    devise: 'FC',
    localisation: 'Abidjan, Cocody',
    contact: '07XXXXXXXX',
    imagesUrl: [],
    datePublication: DateTime.now().subtract(const Duration(days: 5)),
    vendeurNom: 'Marie L.',
    estVerifie: false,
  ),
  Annonce(
    id: '3',
    type: AnnonceType.service,
    titre: 'Ménage à domicile',
    description: 'Service de ménage professionnel, matériel fourni.',
    prix: 10000,
    devise: 'FC',
    localisation: 'Abidjan',
    contact: '07XXXXXXXX',
    imagesUrl: [],
    datePublication: DateTime.now().subtract(const Duration(days: 1)),
    vendeurNom: 'Service Pro',
    estVerifie: true,
  ),
];
