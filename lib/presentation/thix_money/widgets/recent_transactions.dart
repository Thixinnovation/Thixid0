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
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_transactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          children: [
            Icon(Icons.receipt_long, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text('Aucune transaction récente'),
          ],
        ),
      );
    }
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: _transactions.map((transaction) {
          return Column(
            children: [
              TransactionItem(transaction: transaction),
              if (transaction != _transactions.last)
                const Divider(height: 1, indent: 60),
            ],
          );
        }).toList(),
      ),
    );
  }
}
