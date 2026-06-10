// lib/presentation/thix_money/thix_money_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:thix_id/presentation/thix_money/thix_money_scanner.dart';
import 'package:thix_id/presentation/thix_money/thix_money_credit.dart';
import 'package:thix_id/presentation/thix_money/thix_money_transactions.dart';
import 'package:thix_id/presentation/thix_money/thix_money_services.dart';
import 'package:thix_id/presentation/thix_money/thix_money_profile.dart';
import 'package:thix_id/presentation/thix_money/thix_money_transfer.dart';
import 'package:thix_id/presentation/thix_money/thix_money_deposit.dart';
import 'package:thix_id/presentation/thix_money/thix_money_withdraw.dart';
import 'package:thix_id/presentation/thix_money/thix_money_notifications.dart';
import 'package:thix_id/presentation/thix_money/thix_money_savings.dart';
import 'package:thix_id/presentation/thix_money/thix_money_tontine.dart';
import 'package:thix_id/presentation/thix_money/thix_money_investment.dart';
import 'package:thix_id/presentation/thix_money/thix_money_insurance.dart';
import 'package:thix_id/presentation/thix_money/thix_money_cards.dart';
import 'package:thix_id/presentation/thix_money/thix_money_international_transfer.dart';
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

  // ==================== NAVIGATIONS ====================
  
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

  void _openSavings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ThixMoneySavings()),
    );
  }

  void _openTontine() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ThixMoneyTontine()),
    );
  }

  void _openInvestment() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ThixMoneyInvestment()),
    );
  }

  void _openInsurance() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ThixMoneyInsurance()),
    );
  }

  void _openCards() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ThixMoneyCards()),
    );
  }

  void _openInternationalTransfer() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ThixMoneyInternationalTransfer()),
    );
  }

  void _openAiAdviceDetails() {
    // Naviguer vers les détails des conseils AI
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Plus de conseils AI bientôt disponible')),
    );
  }

  void _openCashback() {
    // Naviguer vers les offres cashback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Offres cashback bientôt disponibles')),
    );
  }

  void _openPromo() {
    // Naviguer vers les promotions
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Promotions bientôt disponibles')),
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
                height: screenHeight - 50,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      MoneyHeader(
                        onMenuTap: () {},
                        onNotificationsTap: _openNotifications,
                        userName: 'Jean Dupont',
                      ),
                      const SizedBox(height: 12),
                      
                      // Balance Card
                      MoneyBalanceCard(
                        balance: _balance,
                        savingsBalance: _savingsBalance,
                        investmentBalance: _investmentBalance,
                      ),
                      const SizedBox(height: 12),
                      
                      // Quick Actions
                      QuickActions(
                        onSendTap: _openTransfer,
                        onDepositTap: _openDeposit,
                        onScannerTap: _openScanner,
                        onWithdrawTap: _openWithdraw,
                      ),
                      const SizedBox(height: 16),
                      
                      // Services Grid (connecté)
                      ServicesGrid(
                        onCreditTap: _openCredit,
                        onSavingsTap: _openSavings,
                        onTontineTap: _openTontine,
                        onInvestmentTap: _openInvestment,
                        onInsuranceTap: _openInsurance,
                        onCardsTap: _openCards,
                        onInternationalTap: _openInternationalTransfer,
                      ),
                      const SizedBox(height: 16),
                      
                      // Credit Card
                      CreditCard(
                        onTap: _openCredit,
                        maxAmount: 5000000,
                      ),
                      const SizedBox(height: 12),
                      
                      // AI Advice (connecté)
                      AiAdviceCard(
                        advice: _aiAdvice,
                        onSeeMore: _openAiAdviceDetails,
                      ),
                      const SizedBox(height: 12),
                      
                      // Cashback (connecté)
                      GestureDetector(
                        onTap: _openCashback,
                        child: const CashbackCard(),
                      ),
                      const SizedBox(height: 12),
                      
                      // Tontines (connecté)
                      if (_tontines.isNotEmpty) ...[
                        const SectionTitle(title: 'Mes tontines'),
                        const SizedBox(height: 8),
                        TontineList(
                          tontines: _tontines.take(2).toList(),
                          onTontineTap: (id) => _openTontine(),
                        ),
                        const SizedBox(height: 12),
                      ],
                      
                      // Virtual Card (connecté)
                      GestureDetector(
                        onTap: _openCards,
                        child: const VirtualCardWidget(),
                      ),
                      const SizedBox(height: 12),
                      
                      // Promo Banner (connecté)
                      GestureDetector(
                        onTap: _openPromo,
                        child: const PromoBanner(),
                      ),
                      const SizedBox(height: 16),
                      
                      // Recent Transactions
                      const SectionTitle(title: 'Transactions récentes'),
                      const SizedBox(height: 8),
                      const RecentTransactions(limit: 2),
                      const SizedBox(height: 30),
                    ],
                  ),
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
