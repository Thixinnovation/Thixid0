// lib/presentation/thix_money/thix_money_history.dart
import 'package:flutter/material.dart';
import 'package:thix_id/presentation/thix_money/widgets/transaction_item.dart';
import 'package:thix_id/presentation/thix_money/widgets/empty_state.dart';
import 'package:thix_id/presentation/thix_money/widgets/loading_shimmer.dart';
import 'package:thix_id/services/wallet_service.dart';
import 'package:thix_id/models/transaction.dart';

class ThixMoneyHistory extends StatefulWidget {
  const ThixMoneyHistory({super.key});

  @override
  State<ThixMoneyHistory> createState() => _ThixMoneyHistoryState();
}

class _ThixMoneyHistoryState extends State<ThixMoneyHistory> {
  final WalletService _walletService = WalletService();
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  String _selectedPeriod = 'Ce mois';
  
  final List<String> _periods = ['Aujourd\'hui', 'Cette semaine', 'Ce mois', 'Cette année', 'Tout'];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    final transactions = await _walletService.getTransactions();
    setState(() {
      _transactions = transactions;
      _isLoading = false;
    });
  }

  double _getTotalByType(TransactionType type) {
    return _transactions
        .where((t) => t.type == type)
        .fold(0.0, (sum, t) => sum + t.amount.abs());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Historique complet'),
        backgroundColor: const Color(0xFF0B1B3D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const LoadingShimmer()
          : Column(
              children: [
                // Période
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _periods.length,
                    itemBuilder: (context, index) {
                      final period = _periods[index];
                      final isSelected = _selectedPeriod == period;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: FilterChip(
                          label: Text(period),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _selectedPeriod = period),
                          selectedColor: const Color(0xFFD4AF37),
                          showCheckmark: false,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                
                // Statistiques
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const Text('Total entrées', style: TextStyle(color: Colors.green)),
                            const SizedBox(height: 4),
                            Text(
                              '+${_getTotalByType(TransactionType.payment).toStringAsFixed(0)} FCFA',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Container(height: 40, width: 1, color: Colors.grey.shade300),
                      Expanded(
                        child: Column(
                          children: [
                            const Text('Total sorties', style: TextStyle(color: Colors.red)),
                            const SizedBox(height: 4),
                            Text(
                              '-${_getTotalByType(TransactionType.transfer).toStringAsFixed(0)} FCFA',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Container(height: 40, width: 1, color: Colors.grey.shade300),
                      Expanded(
                        child: Column(
                          children: [
                            const Text('Solde final', style: TextStyle(color: Color(0xFFD4AF37))),
                            const SizedBox(height: 4),
                            Text(
                              '${(_getTotalByType(TransactionType.payment) - _getTotalByType(TransactionType.transfer)).toStringAsFixed(0)} FCFA',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD4AF37)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Liste
                Expanded(
                  child: _transactions.isEmpty
                      ? const EmptyState(
                          icon: Icons.history,
                          message: 'Aucune transaction',
                          subtitle: 'Vos transactions apparaîtront ici',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _transactions.length,
                          itemBuilder: (context, index) {
                            final transaction = _transactions[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: TransactionItem(
                                transaction: transaction,
                                onTap: () {
                                  // Détails de la transaction
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
