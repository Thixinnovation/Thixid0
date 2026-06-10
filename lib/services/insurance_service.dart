// lib/services/insurance_service.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:thix_id/services/wallet_service.dart';

class InsuranceService {
  final WalletService _walletService = WalletService();

  Future<List<Insurance>> getAvailableInsurances() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      Insurance(
        id: '1',
        name: 'Assurance Santé',
        description: 'Couverture médicale complète',
        monthlyPremium: 15000,
        coverageAmount: 5000000,
        icon: Icons.health_and_safety,
        color: 0xFF4CAF50,
        features: [
          'Consultations médicales',
          'Hospitalisation',
          'Médicaments',
          'Analyses',
        ],
      ),
      Insurance(
        id: '2',
        name: 'Assurance Vie',
        description: 'Protection pour vos proches',
        monthlyPremium: 25000,
        coverageAmount: 10000000,
        icon: Icons.favorite,
        color: 0xFFE91E63,
        features: [
          'Capital décès',
          'Invalidité',
          'Maladies graves',
        ],
      ),
      Insurance(
        id: '3',
        name: 'Assurance Auto',
        description: 'Protection pour votre véhicule',
        monthlyPremium: 20000,
        coverageAmount: 3000000,
        icon: Icons.directions_car,
        color: 0xFF2196F3,
        features: [
          'Responsabilité civile',
          'Vol et incendie',
          'Bris de glace',
          'Assistance',
        ],
      ),
      Insurance(
        id: '4',
        name: 'Assurance Habitation',
        description: 'Protection pour votre logement',
        monthlyPremium: 10000,
        coverageAmount: 2000000,
        icon: Icons.home,
        color: 0xFFFF9800,
        features: [
          'Incendie',
          'Dégâts des eaux',
          'Vol',
          'Responsabilité civile',
        ],
      ),
    ];
  }

  Future<List<ActiveInsurance>> getMyInsurances() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      ActiveInsurance(
        id: '101',
        name: 'Assurance Santé',
        status: InsuranceStatus.active,
        startDate: DateTime.now().subtract(const Duration(days: 60)),
        nextPaymentDate: DateTime.now().add(const Duration(days: 30)),
        monthlyPremium: 15000,
      ),
      ActiveInsurance(
        id: '102',
        name: 'Assurance Auto',
        status: InsuranceStatus.pending,
        startDate: DateTime.now(),
        nextPaymentDate: DateTime.now().add(const Duration(days: 30)),
        monthlyPremium: 20000,
      ),
    ];
  }

  Future<InsuranceResult> subscribe({
    required String insuranceId,
  }) async {
    try {
      final insurance = await _getInsuranceById(insuranceId);
      
      if (insurance == null) {
        return InsuranceResult(
          success: false,
          message: 'Assurance non trouvée',
          errorCode: 'NOT_FOUND',
        );
      }

      if (!_walletService.hasSufficientFunds(insurance.monthlyPremium)) {
        return InsuranceResult(
          success: false,
          message: 'Solde insuffisant pour le premier paiement',
          errorCode: 'INSUFFICIENT_FUNDS',
        );
      }

      await _walletService.debit(insurance.monthlyPremium);
      await _submitSubscription(insuranceId);

      return InsuranceResult(
        success: true,
        message: 'Souscription à ${insurance.name} effectuée',
        insuranceId: insuranceId,
        monthlyPremium: insurance.monthlyPremium,
      );
    } catch (e) {
      return InsuranceResult(
        success: false,
        message: 'Erreur lors de la souscription',
        errorCode: 'SUBSCRIPTION_ERROR',
        details: e.toString(),
      );
    }
  }

  Future<Insurance?> _getInsuranceById(String id) async {
    final insurances = await getAvailableInsurances();
    try {
      return insurances.firstWhere((i) => i.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> _submitSubscription(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    // Appel API
  }
}

enum InsuranceStatus { active, pending, expired, cancelled }

extension InsuranceStatusExtension on InsuranceStatus {
  String get label {
    switch (this) {
      case InsuranceStatus.active:
        return 'Active';
      case InsuranceStatus.pending:
        return 'En attente';
      case InsuranceStatus.expired:
        return 'Expirée';
      case InsuranceStatus.cancelled:
        return 'Annulée';
    }
  }

  Color get color {
    switch (this) {
      case InsuranceStatus.active:
        return Colors.green;
      case InsuranceStatus.pending:
        return Colors.orange;
      case InsuranceStatus.expired:
        return Colors.red;
      case InsuranceStatus.cancelled:
        return Colors.grey;
    }
  }
}

class Insurance {
  final String id;
  final String name;
  final String description;
  final double monthlyPremium;
  final double coverageAmount;
  final IconData icon;
  final int color;
  final List<String> features;

  Insurance({
    required this.id,
    required this.name,
    required this.description,
    required this.monthlyPremium,
    required this.coverageAmount,
    required this.icon,
    required this.color,
    required this.features,
  });
}

class ActiveInsurance {
  final String id;
  final String name;
  final InsuranceStatus status;
  final DateTime startDate;
  final DateTime nextPaymentDate;
  final double monthlyPremium;

  ActiveInsurance({
    required this.id,
    required this.name,
    required this.status,
    required this.startDate,
    required this.nextPaymentDate,
    required this.monthlyPremium,
  });
}

class InsuranceResult {
  final bool success;
  final String message;
  final String? errorCode;
  final String? insuranceId;
  final double? monthlyPremium;
  final String? details;

  InsuranceResult({
    required this.success,
    required this.message,
    this.errorCode,
    this.insuranceId,
    this.monthlyPremium,
    this.details,
  });
}
