// lib/services/tontine_service.dart
import 'dart:async';
import 'package:thix_id/models/tontine.dart';
import 'package:thix_id/services/wallet_service.dart';

class TontineService {
  final WalletService _walletService = WalletService();

  Future<List<Tontine>> getMyTontines() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return mockTontines;
  }

  Future<List<Tontine>> getAvailableTontines() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      Tontine(
        id: '4',
        name: 'Tontine Entrepreneurs',
        progress: 0.45,
        currentMembers: 9,
        maxMembers: 20,
        contributionAmount: 75000,
        frequency: TontineFrequency.monthly,
      ),
      Tontine(
        id: '5',
        name: 'Tontine Jeunes',
        progress: 0.30,
        currentMembers: 6,
        maxMembers: 20,
        contributionAmount: 25000,
        frequency: TontineFrequency.weekly,
      ),
    ];
  }

  Future<TontineResult> createTontine({
    required String name,
    required double contributionAmount,
    required int maxMembers,
    required String frequency,
    String? description,
    bool isPrivate = true,
  }) async {
    try {
      if (contributionAmount <= 0) {
        return TontineResult(
          success: false,
          message: 'Montant de contribution invalide',
          errorCode: 'INVALID_AMOUNT',
        );
      }

      if (maxMembers < 2 || maxMembers > 50) {
        return TontineResult(
          success: false,
          message: 'Nombre de membres invalide (2-50)',
          errorCode: 'INVALID_MEMBERS',
        );
      }

      final tontineId = await _createTontineApi(
        name, contributionAmount, maxMembers, frequency, description, isPrivate,
      );

      return TontineResult(
        success: true,
        message: 'Tontine créée avec succès',
        tontineId: tontineId,
      );
    } catch (e) {
      return TontineResult(
        success: false,
        message: 'Erreur lors de la création',
        errorCode: 'CREATE_ERROR',
        details: e.toString(),
      );
    }
  }

  Future<TontineResult> contributeToTontine({
    required String tontineId,
    required double amount,
  }) async {
    try {
      if (!_walletService.hasSufficientFunds(amount)) {
        return TontineResult(
          success: false,
          message: 'Solde insuffisant',
          errorCode: 'INSUFFICIENT_FUNDS',
        );
      }

      await _walletService.debit(amount);
      await _submitContribution(tontineId, amount);

      return TontineResult(
        success: true,
        message: 'Contribution de ${amount.toStringAsFixed(0)} FCFA effectuée',
        tontineId: tontineId,
        amount: amount,
      );
    } catch (e) {
      return TontineResult(
        success: false,
        message: 'Erreur lors de la contribution',
        errorCode: 'CONTRIBUTION_ERROR',
        details: e.toString(),
      );
    }
  }

  Future<String> _createTontineApi(
    String name,
    double amount,
    int members,
    String frequency,
    String? description,
    bool isPrivate,
  ) async {
    await Future.delayed(const Duration(seconds: 1));
    // Appel API
    return 'tontine_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> _submitContribution(String tontineId, double amount) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Appel API
  }
}

class TontineResult {
  final bool success;
  final String message;
  final String? errorCode;
  final String? tontineId;
  final double? amount;
  final String? details;

  TontineResult({
    required this.success,
    required this.message,
    this.errorCode,
    this.tontineId,
    this.amount,
    this.details,
  });
}
