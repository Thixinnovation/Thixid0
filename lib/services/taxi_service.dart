// lib/services/taxi_service.dart
import 'dart:async';
import '../models/taxi.dart';

class TaxiService {
  // Commander un taxi
  Future<Trajet> commanderTaxi({
    required String depart,
    required String arrivee,
    required String departAdresse,
    String? arriveeAdresse,
    required VehiculeType vehiculeType,
    required DateTime date,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // Calculer le prix approximatif (simulation)
    double distanceKm = 10.0;
    double prixBase = vehiculeType.tarifBase;
    double prix = distanceKm * prixBase;
    
    return Trajet(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      depart: depart,
      arrivee: arrivee,
      departAdresse: departAdresse,
      arriveeAdresse: arriveeAdresse,
      distanceKm: distanceKm,
      dureeMinutes: 30,
      date: date,
      vehiculeType: vehiculeType,
      prix: prix,
      devise: 'FCFA',
      status: TaxiStatus.enAttente,
    );
  }

  // Récupérer l'historique des trajets
  Future<List<Trajet>> getHistoriqueTrajets() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return mockTrajets;
  }

  // Suivre un trajet en cours
  Future<Trajet?> suivreTrajet(String trajetId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return mockTrajets.firstWhere((t) => t.id == trajetId);
    } catch (e) {
      return null;
    }
  }

  // Annuler un trajet
  Future<bool> annulerTrajet(String trajetId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  // Estimer le prix d'un trajet
  Future<double> estimerPrix({
    required String depart,
    required String arrivee,
    required VehiculeType vehiculeType,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Simulation de calcul de distance
    double distanceKm = 8.0;
    double prix = distanceKm * vehiculeType.tarifBase;
    
    return prix;
  }

  // Récupérer les offres du moment
  Future<List<Map<String, dynamic>>> getOffresMoment() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      {'titre': 'Premier trajet', 'reduction': '-20%', 'prix': '2.000 FCFA', 'original': '2.500 FCFA'},
      {'titre': 'Trajet Aéroport', 'reduction': '-15%', 'prix': '3.000 FCFA', 'original': '3.500 FCFA'},
      {'titre': 'Trajets Confort', 'reduction': '-10%', 'prix': '2.700 FCFA', 'original': '3.000 FCFA'},
      {'titre': 'Abonnement', 'reduction': '-10%', 'prix': '15.000 FCFA', 'original': '16.500 FCFA'},
    ];
  }
}
