// lib/presentation/thix_money/widgets/recent_transactions.dart
import 'package:flutter/material.dart';
import 'package:thix_id/presentation/thix_money/widgets/transaction_item.dart';
import 'package:thix_id/services/wallet_service.dart';
import 'package:thix_id/models/transaction.dart';

class RecentTransactions extends StatefulWidget {
  final int? limit;

  const RecentTransactions({super.key, this.limit});

  @override
  State<RecentTransactions> createState() => _RecentTransactionsState();
}

class _RecentTransactionsState extends State<RecentTransactions> {
  final WalletService _walletService = WalletService();
  List<Transaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final transactions = await _walletService.getTransactions();
    setState(() {
      if (widget.limit != null && transactions.length > widget.limit!) {
        _transactions = transactions.take(widget.limit!).toList();
      } else {
        _transactions = transactions;
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink();
    }
    
    if (_transactions.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: _transactions.map((transaction) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: TransactionItem(transaction: transaction),
          );
        }).toList(),
      ),
    );
  }
}
