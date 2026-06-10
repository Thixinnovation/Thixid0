// lib/services/bus_service.dart
import 'dart:async';
import '../models/bus.dart';

class BusService {
  // Récupérer tous les bus
  Future<List<Bus>> getAllBus() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return mockBus;
  }

  // Rechercher des bus
  Future<List<Bus>> rechercherBus({
    required String depart,
    required String arrivee,
    required DateTime date,
    required int passagers,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    var bus = mockBus.where((b) {
      return b.depart == depart && b.arrivee == arrivee;
    }).toList();
    
    return bus;
  }

  // Récupérer un bus par ID
  Future<Bus?> getBusById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return mockBus.firstWhere((bus) => bus.id == id);
    } catch (e) {
      return null;
    }
  }

  // Récupérer les routes populaires
  Future<List<Map<String, String>>> getRoutesPopulaires() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      {'route': 'Abidjan → Yamoussoukro', 'heure': '08:00', 'prix': '5.000 FCFA'},
      {'route': 'Abidjan → Bouaké', 'heure': '09:00', 'prix': '6.000 FCFA'},
      {'route': 'Abidjan → Korhogo', 'heure': '10:00', 'prix': '7.000 FCFA'},
      {'route': 'Yamoussoukro → Abidjan', 'heure': '14:00', 'prix': '5.000 FCFA'},
    ];
  }
}
