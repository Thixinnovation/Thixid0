// lib/services/vol_service.dart
import 'dart:async';
import '../models/vol.dart';

class VolService {
  // Récupérer tous les vols
  Future<List<Vol>> getAllVols() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return mockVols;
  }

  // Rechercher des vols
  Future<List<Vol>> rechercherVols({
    required String origine,
    required String destination,
    required DateTime depart,
    DateTime? retour,
    required int passagers,
    required String classe,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Filtrer les vols mockés
    var vols = mockVols.where((vol) {
      return vol.depart.contains(origine.split(' ').first) &&
             vol.arrivee.contains(destination.split(' ').first);
    }).toList();
    
    return vols;
  }

  // Récupérer un vol par ID
  Future<Vol?> getVolById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return mockVols.firstWhere((vol) => vol.id == id);
    } catch (e) {
      return null;
    }
  }

  // Récupérer les vols populaires
  Future<List<Vol>> getVolsPopulaires() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockVols.take(3).toList();
  }

  // Récupérer les offres spéciales
  Future<List<Vol>> getOffresSpeciales() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockVols.where((vol) => vol.prix < 700).toList();
  }
}
