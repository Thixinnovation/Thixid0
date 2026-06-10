// lib/models/colis.dart
import 'package:flutter/material.dart';

enum ColisStatus { enregistre, priseEnCharge, enTransit, arrivee, livre, annule }

extension ColisStatusExtension on ColisStatus {
  String get label {
    switch (this) {
      case ColisStatus.enregistre:
        return 'Enregistré';
      case ColisStatus.priseEnCharge:
        return 'Prise en charge';
      case ColisStatus.enTransit:
        return 'En transit';
      case ColisStatus.arrivee:
        return 'Arrivé à destination';
      case ColisStatus.livre:
        return 'Livré';
      case ColisStatus.annule:
        return 'Annulé';
    }
  }

  Color get color {
    switch (this) {
      case ColisStatus.enregistre:
        return Colors.blue;
      case ColisStatus.priseEnCharge:
        return Colors.orange;
      case ColisStatus.enTransit:
        return Colors.purple;
      case ColisStatus.arrivee:
        return Colors.teal;
      case ColisStatus.livre:
        return Colors.green;
      case ColisStatus.annule:
        return Colors.red;
    }
  }
}

class Colis {
  final String id;
  final String numeroSuivi;
  final ColisStatus status;
  final String expediteur;
  final String expediteurAdresse;
  final String expediteurVille;
  final String destinataire;
  final String destinataireAdresse;
  final String destinataireVille;
  final String typeColis;
  final double poids;
  final String modeLivraison;
  final double prix;
  final String devise;
  final DateTime dateEnvoi;
  final DateTime? dateLivraisonEstimee;
  final List<ColisHistorique> historique;

  Colis({
    required this.id,
    required this.numeroSuivi,
    required this.status,
    required this.expediteur,
    required this.expediteurAdresse,
    required this.expediteurVille,
    required this.destinataire,
    required this.destinataireAdresse,
    required this.destinataireVille,
    required this.typeColis,
    required this.poids,
    required this.modeLivraison,
    required this.prix,
    required this.devise,
    required this.dateEnvoi,
    this.dateLivraisonEstimee,
    this.historique = const [],
  });

  String get prixFormate => '$prix $devise';
  String get dateEnvoiFormate => '${dateEnvoi.day}/${dateEnvoi.month}/${dateEnvoi.year}';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numeroSuivi': numeroSuivi,
      'status': status.name,
      'expediteur': expediteur,
      'expediteurAdresse': expediteurAdresse,
      'expediteurVille': expediteurVille,
      'destinataire': destinataire,
      'destinataireAdresse': destinataireAdresse,
      'destinataireVille': destinataireVille,
      'typeColis': typeColis,
      'poids': poids,
      'modeLivraison': modeLivraison,
      'prix': prix,
      'devise': devise,
      'dateEnvoi': dateEnvoi.toIso8601String(),
      'dateLivraisonEstimee': dateLivraisonEstimee?.toIso8601String(),
    };
  }

  factory Colis.fromJson(Map<String, dynamic> json) {
    return Colis(
      id: json['id'] as String,
      numeroSuivi: json['numeroSuivi'] as String,
      status: ColisStatus.values.firstWhere((e) => e.name == json['status']),
      expediteur: json['expediteur'] as String,
      expediteurAdresse: json['expediteurAdresse'] as String,
      expediteurVille: json['expediteurVille'] as String,
      destinataire: json['destinataire'] as String,
      destinataireAdresse: json['destinataireAdresse'] as String,
      destinataireVille: json['destinataireVille'] as String,
      typeColis: json['typeColis'] as String,
      poids: (json['poids'] as num).toDouble(),
      modeLivraison: json['modeLivraison'] as String,
      prix: (json['prix'] as num).toDouble(),
      devise: json['devise'] as String,
      dateEnvoi: DateTime.parse(json['dateEnvoi'] as String),
      dateLivraisonEstimee: json['dateLivraisonEstimee'] != null
          ? DateTime.parse(json['dateLivraisonEstimee'] as String)
          : null,
    );
  }
}

class ColisHistorique {
  final String id;
  final ColisStatus status;
  final DateTime date;
  final String localisation;
  final String? description;

  ColisHistorique({
    required this.id,
    required this.status,
    required this.date,
    required this.localisation,
    this.description,
  });

  String get dateFormate => '${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
}
