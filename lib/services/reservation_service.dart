// lib/services/reservation_service.dart
import 'dart:async';
import '../models/reservation.dart';

class ReservationService {
  // Récupérer toutes les réservations de l'utilisateur
  Future<List<Reservation>> getMesReservations() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return mockReservations;
  }

  // Récupérer une réservation par ID
  Future<Reservation?> getReservationById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return mockReservations.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  // Récupérer une réservation par code
  Future<Reservation?> getReservationByCode(String code) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return mockReservations.firstWhere((r) => r.code == code);
    } catch (e) {
      return null;
    }
  }

  // Créer une réservation
  Future<Reservation> createReservation({
    required ReservationType type,
    required String titre,
    required String description,
    required double montant,
    required String devise,
    required DateTime dateService,
    DateTime? dateFin,
    required Map<String, dynamic> details,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final reservation = Reservation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      code: 'THIX${DateTime.now().millisecondsSinceEpoch.toString().substring(8, 12)}'.toUpperCase(),
      type: type,
      status: ReservationStatus.confirmed,
      dateReservation: DateTime.now(),
      dateService: dateService,
      dateFin: dateFin,
      titre: titre,
      description: description,
      montant: montant,
      devise: devise,
      details: details,
    );
    
    return reservation;
  }

  // Annuler une réservation
  Future<bool> annulerReservation(String reservationId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  // Récupérer le nombre de réservations par statut
  Future<Map<ReservationStatus, int>> getReservationCounts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final reservations = await getMesReservations();
    final counts = <ReservationStatus, int>{};
    
    for (var status in ReservationStatus.values) {
      counts[status] = reservations.where((r) => r.status == status).length;
    }
    
    return counts;
  }

  // Filtrer les réservations par type
  Future<List<Reservation>> getReservationsByType(ReservationType type) async {
    final all = await getMesReservations();
    return all.where((r) => r.type == type).toList();
  }

  // Filtrer les réservations par statut
  Future<List<Reservation>> getReservationsByStatus(ReservationStatus status) async {
    final all = await getMesReservations();
    return all.where((r) => r.status == status).toList();
  }
}
