// lib/services/annonce_service.dart
import 'dart:async';
import '../models/annonce.dart';

class AnnonceService {
  // Récupérer toutes les annonces
  Future<List<Annonce>> getAllAnnonces() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return mockAnnonces;
  }

  // Récupérer les annonces par type
  Future<List<Annonce>> getAnnoncesByType(AnnonceType type) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockAnnonces.where((a) => a.type == type).toList();
  }

  // Récupérer une annonce par ID
  Future<Annonce?> getAnnonceById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return mockAnnonces.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  // Créer une annonce
  Future<Annonce> createAnnonce({
    required AnnonceType type,
    required String titre,
    required String description,
    required double prix,
    required String devise,
    String? localisation,
    String? contact,
    List<String> imagesUrl = const [],
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    return Annonce(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      titre: titre,
      description: description,
      prix: prix,
      devise: devise,
      localisation: localisation,
      contact: contact,
      imagesUrl: imagesUrl,
      datePublication: DateTime.now(),
      vendeurNom: 'Utilisateur',
      estVerifie: false,
    );
  }

  // Supprimer une annonce
  Future<bool> deleteAnnonce(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  // Récupérer les annonces par prix
  Future<List<Annonce>> getAnnoncesByPriceRange(double minPrice, double maxPrice) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockAnnonces.where((a) => a.prix >= minPrice && a.prix <= maxPrice).toList();
  }

  // Récupérer les annonces vérifiées
  Future<List<Annonce>> getAnnoncesVerifiees() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockAnnonces.where((a) => a.estVerifie).toList();
  }
}
