// lib/presentation/thix_money/thix_money_page.dart
import 'package:flutter/material.dart';
import 'package:thix_id/presentation/thix_money/thix_money_scanner.dart';
import 'package:thix_id/presentation/thix_money/thix_money_credit.dart';
import 'package:thix_id/presentation/thix_money/thix_money_transactions.dart';
import 'package:thix_id/presentation/thix_money/thix_money_services.dart';
import 'package:thix_id/presentation/thix_money/thix_money_profile.dart';
import 'package:thix_id/presentation/thix_money/thix_money_transfer.dart';
import 'package:thix_id/presentation/thix_money/thix_money_deposit.dart';
import 'package:thix_id/presentation/thix_money/thix_money_withdraw.dart';
import 'package:thix_id/presentation/thix_money/thix_money_notifications.dart';
import 'package:thix_id/presentation/thix_money/widgets/money_header.dart';
import 'package:thix_id/presentation/thix_money/widgets/money_balance_card.dart';
import 'package:thix_id/presentation/thix_money/widgets/quick_actions.dart';
import 'package:thix_id/presentation/thix_money/widgets/services_grid.dart';
import 'package:thix_id/presentation/thix_money/widgets/credit_card.dart';
import 'package:thix_id/presentation/thix_money/widgets/ai_advice_card.dart';
import 'package:thix_id/presentation/thix_money/widgets/cashback_card.dart';
import 'package:thix_id/presentation/thix_money/widgets/tontine_list.dart';
import 'package:thix_id/presentation/thix_money/widgets/recent_transactions.dart';
import 'package:thix_id/presentation/thix_money/widgets/virtual_card_widget.dart';
import 'package:thix_id/presentation/thix_money/widgets/promo_banner.dart';
import 'package:thix_id/presentation/thix_money/widgets/section_title.dart';
import 'package:thix_id/presentation/thix_money/widgets/bottom_nav_bar.dart';
import 'package:thix_id/services/wallet_service.dart';
import 'package:thix_id/models/transaction.dart';
import 'package:thix_id/models/tontine.dart';

class ThixMoneyPage extends StatefulWidget {
  const ThixMoneyPage({super.key});

  @override
  State<ThixMoneyPage> createState() => _ThixMoneyPageState();
}

class _ThixMoneyPageState extends State<ThixMoneyPage> {
  int _selectedIndex = 0;
  final WalletService _walletService = WalletService();
  
  double _balance = 0;
  double _savingsBalance = 0;
  double _investmentBalance = 0;
  String _aiAdvice = '';
  List<Tontine> _tontines = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    
    await Future.wait([
      _loadBalance(),
      _loadAiAdvice(),
      _loadTontines(),
    ]);
    
    setState(() => _isLoading = false);
  }

  Future<void> _loadBalance() async {
    final balances = await _walletService.getAllBalances();
    setState(() {
      _balance = balances['balance'] ?? 0;
      _savingsBalance = balances['savings'] ?? 0;
      _investmentBalance = balances['investments'] ?? 0;
    });
  }

  Future<void> _loadAiAdvice() async {
    final advice = await _walletService.getAiAdvice();
    setState(() => _aiAdvice = advice);
  }

  Future<void> _loadTontines() async {
    final tontines = await _walletService.getTontines();
    setState(() => _tontines = tontines);
  }

  void _onBottomNavTap(int index) {
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        break;
      case 1:
        _navigateToTransactions();
        break;
      case 2:
        _openScanner();
        break;
      case 3:
        _navigateToServices();
        break;
      case 4:
        _navigateToProfile();
        break;
    }
  }

  void _navigateToTransactions() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ThixMoneyTransactions()),
    );
  }

  void _navigateToServices() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ThixMoneyServices()),
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ThixMoneyProfile()),
    );
  }

  void _openScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ThixMoneyScanner(
          onPaymentComplete: _loadBalance,
        ),
      ),
    );
  }

  void _openCredit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ThixMoneyCredit(
          onCreditComplete: _loadBalance,
        ),
      ),
    );
  }

  void _openTransfer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ThixMoneyTransfer(
          onTransferComplete: _loadBalance,
        ),
      ),
    );
  }

  void _openDeposit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ThixMoneyDeposit(
          onDepositComplete: _loadBalance,
        ),
      ),
    );
  }

  void _openWithdraw() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ThixMoneyWithdraw(
          onWithdrawComplete: _loadBalance,
        ),
      ),
    );
  }

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ThixMoneyNotifications()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Container(
                height: screenHeight - 50, // Ajustement pour éviter le scroll
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header (compact)
                    MoneyHeader(
                      onMenuTap: () {},
                      onNotificationsTap: _openNotifications,
                      userName: 'Jean Dupont',
                    ),
                    const SizedBox(height: 8),
                    
                    // Balance Card (compact)
                    MoneyBalanceCard(
                      balance: _balance,
                      savingsBalance: _savingsBalance,
                      investmentBalance: _investmentBalance,
                    ),
                    const SizedBox(height: 10),
                    
                    // Quick Actions (compact)
                    QuickActions(
                      onSendTap: _openTransfer,
                      onDepositTap: _openDeposit,
                      onScannerTap: _openScanner,
                      onWithdrawTap: _openWithdraw,
                    ),
                    const SizedBox(height: 12),
                    
                    // Services Grid (compact)
                    const ServicesGrid(),
                    const SizedBox(height: 12),
                    
                    // Credit Card (compact)
                    CreditCard(
                      onTap: _openCredit,
                      maxAmount: 5000000,
                    ),
                    const SizedBox(height: 10),
                    
                    // AI Advice (compact)
                    AiAdviceCard(advice: _aiAdvice),
                    const SizedBox(height: 10),
                    
                    // Cashback (compact)
                    const CashbackCard(),
                    const SizedBox(height: 10),
                    
                    // Tontines (si disponibles)
                    if (_tontines.isNotEmpty) ...[
                      const SectionTitle(title: 'Mes tontines'),
                      const SizedBox(height: 6),
                      TontineList(
                        tontines: _tontines.take(2).toList(),
                        onTontineTap: (id) {},
                      ),
                      const SizedBox(height: 10),
                    ],
                    
                    // Virtual Card et Promo (compact)
                    const VirtualCardWidget(),
                    const SizedBox(height: 10),
                    const PromoBanner(),
                    const SizedBox(height: 10),
                    
                    // Recent Transactions (compact)
                    const SectionTitle(title: 'Transactions récentes'),
                    const SizedBox(height: 6),
                    const RecentTransactions(limit: 2),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }
}
