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
import 'package:thix_id/services/notification_service.dart';
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
  final NotificationService _notificationService = NotificationService();
  
  double _balance = 0;
  double _savingsBalance = 0;
  double _investmentBalance = 0;
  String _aiAdvice = '';
  List<Tontine> _tontines = [];
  List<Transaction> _recentTransactions = [];
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
      _loadRecentTransactions(),
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

  Future<void> _loadRecentTransactions() async {
    final transactions = await _walletService.getRecentTransactions(limit: 3);
    setState(() => _recentTransactions = transactions);
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
    ).then((_) => _loadRecentTransactions());
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
          onPaymentComplete: () {
            _loadBalance();
            _loadRecentTransactions();
          },
        ),
      ),
    );
  }

  void _openCredit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ThixMoneyCredit(
          onCreditComplete: () {
            _loadBalance();
            _loadRecentTransactions();
          },
        ),
      ),
    );
  }

  void _openTransfer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ThixMoneyTransfer(
          onTransferComplete: () {
            _loadBalance();
            _loadRecentTransactions();
          },
        ),
      ),
    );
  }

  void _openDeposit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ThixMoneyDeposit(
          onDepositComplete: () {
            _loadBalance();
            _loadRecentTransactions();
          },
        ),
      ),
    );
  }

  void _openWithdraw() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ThixMoneyWithdraw(
          onWithdrawComplete: () {
            _loadBalance();
            _loadRecentTransactions();
          },
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

  void _openMenu() {
    // Ouvrir le menu latéral
    Scaffold.of(context).openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      drawer: _buildDrawer(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadAllData,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header avec notifications
                      MoneyHeader(
                        onMenuTap: _openMenu,
                        onNotificationsTap: _openNotifications,
                        userName: 'Jean Dupont',
                      ),
                      const SizedBox(height: 20),

                      // Solde
                      MoneyBalanceCard(
                        balance: _balance,
                        savingsBalance: _savingsBalance,
                        investmentBalance: _investmentBalance,
                      ),
                      const SizedBox(height: 22),

                      // Actions rapides
                      QuickActions(
                        onSendTap: _openTransfer,
                        onDepositTap: _openDeposit,
                        onScannerTap: _openScanner,
                        onWithdrawTap: _openWithdraw,
                      ),
                      const SizedBox(height: 25),

                      // Services
                      const SectionTitle(title: 'Services financiers'),
                      const SizedBox(height: 12),
                      const ServicesGrid(),
                      const SizedBox(height: 24),

                      // Crédit
                      CreditCard(
                        onTap: _openCredit,
                        maxAmount: 5000000,
                      ),
                      const SizedBox(height: 18),

                      // AI Advice
                      AiAdviceCard(
                        advice: _aiAdvice,
                        onSeeMore: () {
                          // Voir plus de conseils AI
                        },
                      ),
                      const SizedBox(height: 18),

                      // Cashback
                      const CashbackCard(
                        onUse: null,
                        cashbackPercentage: 10,
                      ),
                      const SizedBox(height: 18),

                      // Tontines
                      if (_tontines.isNotEmpty) ...[
                        const SectionTitle(
                          title: 'Mes tontines',
                          seeAllText: 'Voir tout',
                        ),
                        const SizedBox(height: 12),
                        TontineList(
                          tontines: _tontines.take(3).toList(),
                          onTontineTap: (id) {
                            // Naviguer vers détails tontine
                          },
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Carte virtuelle
                      const VirtualCardWidget(),
                      const SizedBox(height: 20),

                      // Promo banner
                      const PromoBanner(
                        title: 'Envoyez de l\'argent',
                        subtitle: 'dans plus de 120 pays',
                        buttonText: 'Commencer',
                      ),
                      const SizedBox(height: 24),

                      // Transactions récentes
                      if (_recentTransactions.isNotEmpty) ...[
                        const SectionTitle(
                          title: 'Transactions récentes',
                          seeAllText: 'Voir tout',
                        ),
                        const SizedBox(height: 12),
                        RecentTransactions(limit: 3),
                      ],
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

  Widget _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Profil header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: const Color(0xFF0B1B3D),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150'),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Jean Dupont',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatBalance(_balance)} FCFA',
                    style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            // Menu items
            Expanded(
              child: ListView(
                children: [
                  _buildDrawerItem(Icons.home_outlined, 'Accueil', () => Navigator.pop(context)),
                  _buildDrawerItem(Icons.receipt_long_outlined, 'Transactions', () {
                    Navigator.pop(context);
                    _navigateToTransactions();
                  }),
                  _buildDrawerItem(Icons.qr_code_scanner, 'Scanner', () {
                    Navigator.pop(context);
                    _openScanner();
                  }),
                  _buildDrawerItem(Icons.credit_card, 'Mes cartes', () {
                    Navigator.pop(context);
                    // Naviguer vers cartes
                  }),
                  _buildDrawerItem(Icons.help_outline, 'Aide', () {
                    Navigator.pop(context);
                  }),
                  const Divider(),
                  _buildDrawerItem(Icons.logout, 'Déconnexion', () {
                    Navigator.pop(context);
                    _showLogoutDialog();
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF0B1B3D)),
      title: Text(title),
      onTap: onTap,
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Logique de déconnexion
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Déconnecter'),
          ),
        ],
      ),
    );
  }

  String _formatBalance(double balance) {
    return balance.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
  }
}
