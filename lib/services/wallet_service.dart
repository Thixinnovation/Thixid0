// lib/services/wallet_service.dart
import 'dart:async';
import 'package:thix_id/models/transaction.dart';
import 'package:thix_id/models/tontine.dart';

class WalletService {
  double _balance = 12500000; // 12 500 000 FCFA
  double _savingsBalance = 2500000;
  double _investmentBalance = 1250000;

  // ==================== BALANCE ====================
  
  Future<double> getBalance() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _balance;
  }

  Future<double> getSavingsBalance() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _savingsBalance;
  }

  Future<double> getInvestmentBalance() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _investmentBalance;
  }

  Future<Map<String, double>> getAllBalances() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return {
      'balance': _balance,
      'savings': _savingsBalance,
      'investments': _investmentBalance,
    };
  }

  // ==================== VERIFICATION ====================
  
  bool hasSufficientFunds(double amount) {
    return _balance >= amount;
  }

  Future<bool> checkSufficientFundsAsync(double amount) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _balance >= amount;
  }

  // ==================== OPERATIONS ====================
  
  Future<void> debit(double amount) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (!hasSufficientFunds(amount)) {
      throw Exception('Fonds insuffisants');
    }
    
    _balance -= amount;
  }

  Future<void> credit(double amount) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _balance += amount;
  }

  Future<void> transferToSavings(double amount) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (!hasSufficientFunds(amount)) {
      throw Exception('Fonds insuffisants pour le transfert vers épargne');
    }
    
    _balance -= amount;
    _savingsBalance += amount;
  }

  Future<void> transferToInvestment(double amount) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (!hasSufficientFunds(amount)) {
      throw Exception('Fonds insuffisants pour l\'investissement');
    }
    
    _balance -= amount;
    _investmentBalance += amount;
  }

  // ==================== CREDIT ====================
  
  Future<void> requestCredit(double amount) async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (amount <= 0) {
      throw Exception('Montant invalide');
    }
    
    if (amount > 5000000) {
      throw Exception('Montant maximum: 5 000 000 FCFA');
    }
    
    _balance += amount;
  }

  Future<Map<String, dynamic>> getCreditEligibility() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return {
      'eligible': true,
      'maxAmount': 5000000,
      'interestRate': 5.5,
      'availableMonths': [1, 3, 6, 12],
    };
  }

  // ==================== TRANSACTIONS ====================
  
  Future<List<Transaction>> getTransactions() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      Transaction(
        id: '1',
        amount: 250000,
        date: DateTime.now().subtract(const Duration(hours: 2)),
        merchant: 'Orange Money',
        type: TransactionType.payment,
        reference: 'DEP-001',
      ),
      Transaction(
        id: '2',
        amount: 35000,
        date: DateTime.now().subtract(const Duration(days: 1)),
        merchant: 'Market Store',
        type: TransactionType.payment,
        reference: 'PAY-001',
      ),
      Transaction(
        id: '3',
        amount: 5000,
        date: DateTime.now().subtract(const Duration(days: 1)),
        merchant: 'Cashback THIX',
        type: TransactionType.cashback,
        reference: 'CB-001',
      ),
      Transaction(
        id: '4',
        amount: 500000,
        date: DateTime.now().subtract(const Duration(days: 3)),
        merchant: 'Crédit THIX',
        type: TransactionType.credit,
        reference: 'CR-001',
      ),
      Transaction(
        id: '5',
        amount: 150000,
        date: DateTime.now().subtract(const Duration(days: 5)),
        merchant: 'Tontine Business',
        type: TransactionType.savings,
        reference: 'TON-001',
      ),
      Transaction(
        id: '6',
        amount: 75000,
        date: DateTime.now().subtract(const Duration(days: 7)),
        merchant: 'Restaurant Le Délice',
        type: TransactionType.payment,
        reference: 'PAY-002',
      ),
      Transaction(
        id: '7',
        amount: 100000,
        date: DateTime.now().subtract(const Duration(days: 10)),
        merchant: 'Virement reçu',
        type: TransactionType.transfer,
        reference: 'VIR-001',
      ),
    ];
  }

  Future<List<Transaction>> getTransactionsByType(TransactionType type) async {
    final all = await getTransactions();
    return all.where((t) => t.type == type).toList();
  }

  Future<List<Transaction>> getRecentTransactions({int limit = 5}) async {
    final all = await getTransactions();
    return all.take(limit).toList();
  }

  // ==================== TONTINES ====================
  
  Future<List<Tontine>> getTontines() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return mockTontines;
  }

  Future<Tontine> getTontineById(String id) async {
    final tontines = await getTontines();
    return tontines.firstWhere((t) => t.id == id);
  }

  Future<void> contributeToTontine(String tontineId, double amount) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!hasSufficientFunds(amount)) {
      throw Exception('Fonds insuffisants pour la contribution');
    }
    
    _balance -= amount;
  }

  Future<void> createTontine(Map<String, dynamic> tontineData) async {
    await Future.delayed(const Duration(seconds: 1));
    // Logique de création
  }

  // ==================== STATISTIQUES ====================
  
  Future<Map<String, double>> getMonthlyStats() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return {
      'income': 1250000,
      'expenses': 450000,
      'savings': 800000,
    };
  }

  Future<Map<String, double>> getYearlyStats() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return {
      'income': 15000000,
      'expenses': 5200000,
      'savings': 9800000,
    };
  }

  // ==================== AI ADVICE ====================
  
  Future<String> getAiAdvice() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final monthlyStats = await getMonthlyStats();
    final savingsPotential = monthlyStats['income']! - monthlyStats['expenses']!;
    
    if (savingsPotential > 200000) {
      return 'Vous pouvez épargner ${savingsPotential.toStringAsFixed(0)} FCFA ce mois. Excellente capacité d\'épargne !';
    } else if (savingsPotential > 100000) {
      return 'Vous pouvez épargner ${savingsPotential.toStringAsFixed(0)} FCFA ce mois. Essayez d\'augmenter votre épargne.';
    } else {
      return 'Votre capacité d\'épargne est limitée ce mois. Examinez vos dépenses.';
    }
  }

  // ==================== RESET (pour test) ====================
  
  void resetForTesting() {
    _balance = 12500000;
    _savingsBalance = 2500000;
    _investmentBalance = 1250000;
  }
}

// Exception pour fonds insuffisants
class InsufficientFundsException implements Exception {
  final double available;
  final double required;
  final String message;

  InsufficientFundsException({
    required this.available,
    required this.required,
    this.message = 'Fonds insuffisants',
  });

  @override
  String toString() => '$message: $required FCFA requis, $available FCFA disponible';
}
