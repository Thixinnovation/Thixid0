// lib/models/reservation.dart
import 'package:flutter/material.dart';

enum ReservationType { vol, hotel, bus, taxi, colis, restaurant, event }
enum ReservationStatus { pending, confirmed, completed, cancelled, refunded }

extension ReservationTypeExtension on ReservationType {
  String get label {
    switch (this) {
      case ReservationType.vol:
        return 'Vol';
      case ReservationType.hotel:
        return 'Hôtel';
      case ReservationType.bus:
        return 'Bus';
      case ReservationType.taxi:
        return 'Taxi';
      case ReservationType.colis:
        return 'Colis';
      case ReservationType.restaurant:
        return 'Restaurant';
      case ReservationType.event:
        return 'Événement';
    }
  }

  IconData get icon {
    switch (this) {
      case ReservationType.vol:
        return Icons.flight;
      case ReservationType.hotel:
        return Icons.hotel;
      case ReservationType.bus:
        return Icons.directions_bus;
      case ReservationType.taxi:
        return Icons.local_taxi;
      case ReservationType.colis:
        return Icons.inventory;
      case ReservationType.restaurant:
        return Icons.restaurant;
      case ReservationType.event:
        return Icons.event;
    }
  }
}

extension ReservationStatusExtension on ReservationStatus {
  String get label {
    switch (this) {
      case ReservationStatus.pending:
        return 'En attente';
      case ReservationStatus.confirmed:
        return 'Confirmée';
      case ReservationStatus.completed:
        return 'Terminée';
      case ReservationStatus.cancelled:
        return 'Annulée';
      case ReservationStatus.refunded:
        return 'Remboursée';
    }
  }

  Color get color {
    switch (this) {
      case ReservationStatus.pending:
        return Colors.orange;
      case ReservationStatus.confirmed:
        return Colors.green;
      case ReservationStatus.completed:
        return Colors.blue;
      case ReservationStatus.cancelled:
        return Colors.red;
      case ReservationStatus.refunded:
        return Colors.purple;
    }
  }
}

class Reservation {
  final String id;
  final String code;
  final ReservationType type;
  final ReservationStatus status;
  final DateTime dateReservation;
  final DateTime dateService;
  final DateTime? dateFin;
  final String titre;
  final String description;
  final double montant;
  final String devise;
  final String? imageUrl;
  final Map<String, dynamic> details;

  Reservation({
    required this.id,
    required this.code,
    required this.type,
    required this.status,
    required this.dateReservation,
    required this.dateService,
    this.dateFin,
    required this.titre,
    required this.description,
    required this.montant,
    required this.devise,
    this.imageUrl,
    required this.details,
  });

  String get montantFormate => '$montant $devise';
  String get dateReservationFormate => '${dateReservation.day}/${dateReservation.month}/${dateReservation.year}';
  String get dateServiceFormate => '${dateService.day}/${dateService.month}/${dateService.year}';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'type': type.name,
      'status': status.name,
      'dateReservation': dateReservation.toIso8601String(),
      'dateService': dateService.toIso8601String(),
      'dateFin': dateFin?.toIso8601String(),
      'titre': titre,
      'description': description,
      'montant': montant,
      'devise': devise,
      'imageUrl': imageUrl,
      'details': details,
    };
  }

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] as String,
      code: json['code'] as String,
      type: ReservationType.values.firstWhere((e) => e.name == json['type']),
      status: ReservationStatus.values.firstWhere((e) => e.name == json['status']),
      dateReservation: DateTime.parse(json['dateReservation'] as String),
      dateService: DateTime.parse(json['dateService'] as String),
      dateFin: json['dateFin'] != null ? DateTime.parse(json['dateFin'] as String) : null,
      titre: json['titre'] as String,
      description: json['description'] as String,
      montant: (json['montant'] as num).toDouble(),
      devise: json['devise'] as String,
      imageUrl: json['imageUrl'] as String?,
      details: json['details'] as Map<String, dynamic>,
    );
  }
}

// Mock data pour les réservations
List<Reservation> mockReservations = [
  Reservation(
    id: '1',
    code: 'THIX3F7K',
    type: ReservationType.vol,
    status: ReservationStatus.confirmed,
    dateReservation: DateTime.now().subtract(const Duration(days: 2)),
    dateService: DateTime.now().add(const Duration(days: 5)),
    titre: 'Kinshasa → Paris',
    description: 'Ethiopian Airlines - Vol ET914',
    montant: 780,
    devise: 'USD',
    details: {
      'compagnie': 'Ethiopian Airlines',
      'codeVol': 'ET914',
      'classe': 'Économique',
      'passagers': '1 adulte',
    },
  ),
  Reservation(
    id: '2',
    code: 'THIX9A2L',
    type: ReservationType.hotel,
    status: ReservationStatus.confirmed,
    dateReservation: DateTime.now().subtract(const Duration(days: 5)),
    dateService: DateTime.now().add(const Duration(days: 10)),
    dateFin: DateTime.now().add(const Duration(days: 12)),
    titre: 'Azalai Hôtel Abidjan',
    description: 'Chambre Standard - 2 nuits',
    montant: 148000,
    devise: 'FCFA',
    details: {
      'ville': 'Abidjan',
      'chambres': 1,
      'adultes': 2,
    },
  ),
];
