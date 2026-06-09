import 'package:flutter/material.dart';
import 'thix_money_scanner.dart';
import 'thix_money_credit.dart';
import 'thix_money_transactions.dart';
import 'widgets/payment_dialog.dart';
import '../services/wallet_service.dart';

class ThixMoneyHome extends StatefulWidget {
  const ThixMoneyHome({super.key});

  @override
  State<ThixMoneyHome> createState() => _ThixMoneyHomeState();
}

class _ThixMoneyHomeState extends State<ThixMoneyHome> {
  int _selectedIndex = 0;
  final WalletService _walletService = WalletService();
  
  // État pour rafraîchir le solde
  double _balance = 0;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final balance = await _walletService.getBalance();
    setState(() {
      _balance = balance;
    });
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    switch (index) {
      case 0: // Accueil
        break;
      case 1: // Transactions
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ThixMoneyTransactions()),
        ).then((_) => _loadBalance());
        break;
      case 2: // Scanner
        _openScanner();
        break;
      case 3: // Services
        // TODO: Ouvrir services
        break;
      case 4: // Profil
        // TODO: Ouvrir profil
        break;
    }
  }

  void _openScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ThixMoneyScanner(
          onPaymentComplete: () => _loadBalance(),
        ),
      ),
    );
  }

  void _openCredit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ThixMoneyCredit(
          onCreditComplete: () => _loadBalance(),
        ),
      ),
    );
  }

  String _formatBalance(double balance) {
    return balance.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ========== HEADER ==========
              _buildHeader(),
              const SizedBox(height: 20),

              // ========== BALANCE CARD ==========
              _buildBalanceCard(),
              const SizedBox(height: 22),

              // ========== QUICK ACTIONS ==========
              _buildQuickActions(),
              const SizedBox(height: 25),

              // ========== SERVICES SECTION ==========
              _buildServicesSection(),
              const SizedBox(height: 24),

              // ========== CREDIT BANNER ==========
              _buildCreditBanner(),
              const SizedBox(height: 18),

              // ========== THIX AI ==========
              _buildThixAiCard(),
              const SizedBox(height: 18),

              // ========== TONTINES ==========
              _buildTontinesSection(),
              const SizedBox(height: 24),

              // ========== VIRTUAL CARD ==========
              _buildVirtualCard(),
              const SizedBox(height: 20),

              // ========== INTERNATIONAL TRANSFER ==========
              _buildInternationalTransfer(),
              const SizedBox(height: 24),

              // ========== INVESTMENTS ==========
              _buildInvestmentsSection(),
              const SizedBox(height: 24),

              // ========== RECENT TRANSACTIONS ==========
              _buildRecentTransactions(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.menu, color: Color(0xFF0B1B3D)),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "THIX MONEY",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B1B3D),
                ),
              ),
              Text(
                "Votre argent, votre liberté",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.notifications_none, color: Color(0xFF0B1B3D)),
        ),
        const SizedBox(width: 10),
        const CircleAvatar(
          radius: 22,
          backgroundImage: NetworkImage("https://i.pravatar.cc/150"),
        ),
      ],
    );
  }

  // ==================== BALANCE CARD ====================
  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B1B3D), Color(0xFF1A3A6B)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Solde disponible",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Text(
            "${_formatBalance(_balance)} FCFA",
            style: const TextStyle(
              fontSize: 34,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "≈ ${_formatBalance(_balance / 610)} USD",
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildInfoChip(Icons.savings, "Épargne", "2.5M"),
              const SizedBox(width: 10),
              _buildInfoChip(Icons.trending_up, "Invest.", "750K"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== QUICK ACTIONS ====================
  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildQuickAction(Icons.send, "Envoyer", Colors.blue, () {
          _openScanner();
        }),
        _buildQuickAction(Icons.add_card, "Recharger", Colors.green, () {
          // TODO: Rechargement
        }),
        _buildQuickAction(Icons.qr_code_scanner, "Scanner", Colors.deepPurple, () {
          _openScanner();
        }),
        _buildQuickAction(Icons.account_balance_wallet, "Retrait", Colors.orange, () {
          // TODO: Retrait
        }),
      ],
    );
  }

  Widget _buildQuickAction(IconData icon, String title, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ==================== SERVICES GRID ====================
  Widget _buildServicesSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Services financiers",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0B1B3D)),
            ),
            TextButton(
              onPressed: () {},
              child: const Text("Voir tout", style: TextStyle(color: Color(0xFFD4AF37))),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.92,
          children: const [
            ServiceCard(icon: Icons.flash_on, title: "Crédit", color: Color(0xFFD4AF37)),
            ServiceCard(icon: Icons.shield, title: "Assurance", color: Colors.blue),
            ServiceCard(icon: Icons.savings, title: "Épargne", color: Colors.green),
            ServiceCard(icon: Icons.currency_exchange, title: "Change", color: Colors.orange),
            ServiceCard(icon: Icons.store, title: "Marchand", color: Colors.purple),
            ServiceCard(icon: Icons.favorite, title: "Don", color: Colors.red),
            ServiceCard(icon: Icons.groups, title: "Tontine", color: Colors.teal),
            ServiceCard(icon: Icons.school, title: "Éducation", color: Colors.indigo),
            ServiceCard(icon: Icons.public, title: "Virement", color: Colors.cyan),
            ServiceCard(icon: Icons.account_balance, title: "Microfinance", color: Colors.brown),
            ServiceCard(icon: Icons.show_chart, title: "Investir", color: Colors.lime),
            ServiceCard(icon: Icons.analytics, title: "Planifier", color: Colors.deepPurple),
          ],
        ),
      ],
    );
  }

  // ==================== CREDIT BANNER ====================
  Widget _buildCreditBanner() {
    return GestureDetector(
      onTap: _openCredit,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1B3D),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            const Icon(Icons.flash_on, color: Color(0xFFD4AF37), size: 40),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                "Crédit instantané jusqu'à 5 000 000 FCFA",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Color(0xFFD4AF37), shape: BoxShape.circle),
              child: const Icon(Icons.arrow_forward, color: Color(0xFF0B1B3D), size: 18),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== THIX AI ====================
  Widget _buildThixAiCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37).withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.auto_awesome, size: 42, color: Color(0xFFD4AF37)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "THIX AI : Vous pouvez économiser 150 000 FCFA ce mois.",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== TONTINES ====================
  Widget _buildTontinesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Mes tontines",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF0B1B3D)),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildTontineCard("Tontine Business", "78", 7, 10),
              _buildTontineCard("Projet Maison", "52", 5, 10),
              _buildTontineCard("Tontine Famille", "33", 4, 10),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTontineCard(String title, String progress, int current, int max) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Spacer(),
          Text("$progress%", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
          Text("$current/$max membres", style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: double.parse(progress) / 100,
              backgroundColor: Colors.grey.shade200,
              color: const Color(0xFFD4AF37),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== VIRTUAL CARD ====================
  Widget _buildVirtualCard() {
    return Container(
      height: 200,
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF111827), Color(0xFF1F2937)],
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "THIX VIRTUAL CARD",
            style: TextStyle(color: Color(0xFFD4AF37), fontSize: 12, letterSpacing: 1),
          ),
          Spacer(),
          Text(
            "**** **** **** 4587",
            style: TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 3, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("VALID THRU 12/29", style: TextStyle(color: Colors.white70, fontSize: 12)),
              Icon(Icons.credit_card, color: Color(0xFFD4AF37)),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== INTERNATIONAL TRANSFER ====================
  Widget _buildInternationalTransfer() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0E3A8A),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        children: [
          Icon(Icons.public, color: Colors.white, size: 40),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Envoyez de l'argent dans plus de 120 pays.",
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          Icon(Icons.arrow_forward, color: Colors.white),
        ],
      ),
    );
  }

  // ==================== INVESTMENTS ====================
  Widget _buildInvestmentsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Investissements",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0B1B3D)),
          ),
          SizedBox(height: 16),
          InvestmentTile(icon: Icons.home_work, title: "Immobilier", returnRate: "+9%"),
          Divider(),
          InvestmentTile(icon: Icons.agriculture, title: "Agriculture", returnRate: "+12%"),
          Divider(),
          InvestmentTile(icon: Icons.rocket_launch, title: "Startup", returnRate: "+17%"),
        ],
      ),
    );
  }

  // ==================== RECENT TRANSACTIONS ====================
  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Transactions récentes",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0B1B3D)),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ThixMoneyTransactions()));
              },
              child: const Text("Voir tout", style: TextStyle(color: Color(0xFFD4AF37))),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            children: const [
              TransactionTile(
                icon: Icons.arrow_downward,
                iconColor: Colors.green,
                title: "Orange Money",
                subtitle: "Aujourd'hui",
                amount: "+250 000 FCFA",
                isPositive: true,
              ),
              Divider(),
              TransactionTile(
                icon: Icons.shopping_bag,
                iconColor: Colors.red,
                title: "Paiement marchand",
                subtitle: "Hier",
                amount: "-35 000 FCFA",
                isPositive: false,
              ),
              Divider(),
              TransactionTile(
                icon: Icons.bolt,
                iconColor: Color(0xFFD4AF37),
                title: "Crédit reçu",
                subtitle: "Il y a 3 jours",
                amount: "+500 000 FCFA",
                isPositive: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== BOTTOM NAVIGATION ====================
  Widget _buildBottomNavBar() {
    return NavigationBar(
      elevation: 0,
      backgroundColor: Colors.white,
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onBottomNavTap,
      indicatorColor: const Color(0xFFD4AF37).withOpacity(0.2),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: "Accueil"),
        NavigationDestination(icon: Icon(Icons.receipt_long), label: "Transactions"),
        NavigationDestination(icon: Icon(Icons.qr_code_scanner), label: "Scanner"),
        NavigationDestination(icon: Icon(Icons.grid_view), label: "Services"),
        NavigationDestination(icon: Icon(Icons.person_outline), label: "Profil"),
      ],
    );
  }
}

// ==================== SERVICE CARD ====================
class ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const ServiceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 28, color: color),
          ),
          const SizedBox(height: 10),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ==================== INVESTMENT TILE ====================
class InvestmentTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String returnRate;

  const InvestmentTile({
    super.key,
    required this.icon,
    required this.title,
    required this.returnRate,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFD4AF37).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFFD4AF37)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Text(
        returnRate,
        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ==================== TRANSACTION TILE ====================
class TransactionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String amount;
  final bool isPositive;

  const TransactionTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconColor.withOpacity(0.1),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: Text(
        amount,
        style: TextStyle(
          color: isPositive ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
