// lib/services/hotel_service.dart
import 'dart:async';
import '../models/hotel.dart';

class HotelService {
  // Récupérer tous les hôtels
  Future<List<Hotel>> getAllHotels() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return mockHotels;
  }

  // Rechercher des hôtels
  Future<List<Hotel>> rechercherHotels({
    required String destination,
    required DateTime arrivee,
    required DateTime depart,
    required int chambres,
    required int adultes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Filtrer les hôtels mockés
    var hotels = mockHotels.where((hotel) {
      return hotel.ville.toLowerCase().contains(destination.toLowerCase().split(',').first.toLowerCase());
    }).toList();
    
    return hotels;
  }

  // Récupérer un hôtel par ID
  Future<Hotel?> getHotelById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return mockHotels.firstWhere((hotel) => hotel.id == id);
    } catch (e) {
      return null;
    }
  }

  // Récupérer les hôtels populaires
  Future<List<Hotel>> getHotelsPopulaires() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockHotels;
  }

  // Récupérer les offres du moment
  Future<List<Hotel>> getOffresMoment() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockHotels.map((hotel) {
      return Hotel(
        id: hotel.id,
        nom: hotel.nom,
        ville: hotel.ville,
        pays: hotel.pays,
        note: hotel.note,
        avisCount: hotel.avisCount,
        prixMin: hotel.prixMin * 0.8,
        devise: hotel.devise,
        imagesUrl: hotel.imagesUrl,
        amenities: hotel.amenities,
        description: hotel.description,
        latitude: hotel.latitude,
        longitude: hotel.longitude,
      );
    }).toList();
  }
}
