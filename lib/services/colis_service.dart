// lib/services/colis_service.dart
import 'dart:async';
import '../models/colis.dart';

class ColisService {
  // Créer un envoi de colis
  Future<Colis> createEnvoi({
    required String expediteur,
    required String expediteurAdresse,
    required String expediteurVille,
    required String destinataire,
    required String destinataireAdresse,
    required String destinataireVille,
    required String typeColis,
    required double poids,
    required String modeLivraison,
    required double prix,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    return Colis(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      numeroSuivi: 'THIX${DateTime.now().millisecondsSinceEpoch.toString().substring(8, 12)}'.toUpperCase(),
      status: ColisStatus.enregistre,
      expediteur: expediteur,
      expediteurAdresse: expediteurAdresse,
      expediteurVille: expediteurVille,
      destinataire: destinataire,
      destinataireAdresse: destinataireAdresse,
      destinataireVille: destinataireVille,
      typeColis: typeColis,
      poids: poids,
      modeLivraison: modeLivraison,
      prix: prix,
      devise: 'FCFA',
      dateEnvoi: DateTime.now(),
      dateLivraisonEstimee: DateTime.now().add(const Duration(days: 3)),
      historique: [
        ColisHistorique(
          id: '1',
          status: ColisStatus.enregistre,
          date: DateTime.now(),
          localisation: expediteurVille,
          description: 'Colis enregistré',
        ),
      ],
    );
  }

  // Suivre un colis par numéro
  Future<Colis?> suivreColis(String numeroSuivi) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock data pour le suivi
    if (numeroSuivi == 'THIX3F7K') {
      return Colis(
        id: '1',
        numeroSuivi: 'THIX3F7K',
        status: ColisStatus.enTransit,
        expediteur: 'Jean Dupont',
        expediteurAdresse: '12 Rue des Lagunes',
        expediteurVille: 'Abidjan',
        destinataire: 'Marie Claire',
        destinataireAdresse: '45 Avenue Houphouët',
        destinataireVille: 'Yamoussoukro',
        typeColis: 'Colis',
        poids: 2.5,
        modeLivraison: 'Standard (2-3 jours)',
        prix: 3000,
        devise: 'FCFA',
        dateEnvoi: DateTime.now().subtract(const Duration(days: 1)),
        dateLivraisonEstimee: DateTime.now().add(const Duration(days: 2)),
        historique: [
          ColisHistorique(
            id: '1',
            status: ColisStatus.enregistre,
            date: DateTime.now().subtract(const Duration(days: 1)),
            localisation: 'Abidjan',
            description: 'Colis enregistré',
          ),
          ColisHistorique(
            id: '2',
            status: ColisStatus.priseEnCharge,
            date: DateTime.now().subtract(const Duration(hours: 12)),
            localisation: 'Abidjan',
            description: 'Colis pris en charge',
          ),
          ColisHistorique(
            id: '3',
            status: ColisStatus.enTransit,
            date: DateTime.now().subtract(const Duration(hours: 6)),
            localisation: 'En route',
            description: 'Colis en transit vers Yamoussoukro',
          ),
        ],
      );
    }
    return null;
  }

  // Calculer le prix d'envoi
  Future<double> calculerPrix({
    required String typeEnvoi,
    required double poids,
    required String modeLivraison,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    double basePrix = typeEnvoi == 'national' ? 2000 : 15000;
    double prixParKg = typeEnvoi == 'national' ? 500 : 2000;
    double prix = basePrix + (poids * prixParKg);
    
    if (modeLivraison == 'Express (24-48h)') {
      prix *= 1.3;
    } else if (modeLivraison == 'Point Relais') {
      prix *= 0.8;
    }
    
    return prix;
  }

  // Récupérer l'historique des envois
  Future<List<Colis>> getHistoriqueEnvois() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      Colis(
        id: '1',
        numeroSuivi: 'THIX3F7K',
        status: ColisStatus.livre,
        expediteur: 'Jean Dupont',
        expediteurAdresse: '',
        expediteurVille: 'Abidjan',
        destinataire: 'Marie Claire',
        destinataireAdresse: '',
        destinataireVille: 'Yamoussoukro',
        typeColis: 'Colis',
        poids: 2.5,
        modeLivraison: 'Standard (2-3 jours)',
        prix: 3000,
        devise: 'FCFA',
        dateEnvoi: DateTime.now().subtract(const Duration(days: 5)),
        dateLivraisonEstimee: DateTime.now().subtract(const Duration(days: 2)),
        historique: [],
      ),
    ];
  }
}
