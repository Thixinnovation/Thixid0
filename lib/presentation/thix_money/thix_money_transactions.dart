// lib/presentation/thix_money/thix_money_transactions.dart
import 'package:flutter/material.dart';
import 'package:thix_id/presentation/thix_money/widgets/transaction_item.dart';
import 'package:thix_id/presentation/thix_money/widgets/empty_state.dart';
import 'package:thix_id/presentation/thix_money/widgets/loading_shimmer.dart';
import 'package:thix_id/services/wallet_service.dart';
import 'package:thix_id/models/transaction.dart';

class ThixMoneyTransactions extends StatefulWidget {
  const ThixMoneyTransactions({super.key});

  @override
  State<ThixMoneyTransactions> createState() => _ThixMoneyTransactionsState();
}

class _ThixMoneyTransactionsState extends State<ThixMoneyTransactions> {
  final WalletService _walletService = WalletService();
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  String _selectedFilter = 'Tous';

  final List<String> _filters = ['Tous', 'Paiements', 'Virements', 'Crédits', 'Cashback'];

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

  List<Transaction> _getFilteredTransactions() {
    if (_selectedFilter == 'Tous') return _transactions;
    
    return _transactions.where((t) {
      switch (_selectedFilter) {
        case 'Paiements':
          return t.type == TransactionType.payment;
        case 'Virements':
          return t.type == TransactionType.transfer;
        case 'Crédits':
          return t.type == TransactionType.credit;
        case 'Cashback':
          return t.type == TransactionType.cashback;
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = _getFilteredTransactions();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: const Color(0xFF0B1B3D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const LoadingShimmer()
          : Column(
              children: [
                // Filtres
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filters.length,
                    itemBuilder: (context, index) {
                      final filter = _filters[index];
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: FilterChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() => _selectedFilter = filter);
                          },
                          selectedColor: const Color(0xFFD4AF37),
                          showCheckmark: false,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Liste des transactions
                Expanded(
                  child: filteredTransactions.isEmpty
                      ? const EmptyState(
                          icon: Icons.receipt_long,
                          message: 'Aucune transaction',
                          subtitle: 'Vos transactions apparaîtront ici',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredTransactions.length,
                          itemBuilder: (context, index) {
                            final transaction = filteredTransactions[index];
                            return TransactionItem(
                              transaction: transaction,
                              onTap: () {
                                // Voir détails de la transaction
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
