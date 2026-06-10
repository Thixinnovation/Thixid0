import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../services/market_service.dart';
import '../../../services/cart_service.dart';
import '../../../models/product.dart';
import 'product_detail_page.dart';
import 'widgets/products_grid.dart';
import 'package:thix_id/auth/auth_controller.dart';
import 'widgets/product_card.dart';
import 'package:thix_id/presentation/common/banner_carousel.dart';
import 'package:thix_id/services/banner_service.dart';
import 'package:thix_id/models/banner.dart';

class ThixMarketPage extends StatefulWidget {
  const ThixMarketPage({super.key});

  @override
  State<ThixMarketPage> createState() => _ThixMarketPageState();
}

class _ThixMarketPageState extends State<ThixMarketPage> {
  late MarketService _marketService;
  late BannerService _bannerService;
  List<Product> _flashSales = [];
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  List<BannerAd> _banners = [];
  List<Product> _carouselProducts = [];
  bool _loading = true;
  String _selectedCategory = 'Tous';
  final TextEditingController _searchController = TextEditingController();

  String _sortBy = 'newest';
  RangeValues _priceRange = const RangeValues(0, 5000000);
  double _minRating = 0;
  String _selectedCity = 'Toutes';

  final List<String> _categories = [
    'Tous', 'Électronique', 'Mode & Fashion', 'Maison & Déco', 
    'Beauté & Santé', 'Sports & Loisirs', 'Alimentation', 'Automobile'
  ];

  final List<String> _cities = [
    'Toutes', 'Kinshasa', 'Lubumbashi', 'Mbuji-Mayi', 'Kisangani', 
    'Bukavu', 'Goma', 'Kananga', 'Matadi', 'Kikwit'
  ];

  @override
  void initState() {
    super.initState();
    _marketService = MarketService(Supabase.instance.client);
    _bannerService = BannerService(Supabase.instance.client);
    _loadData();
    _loadBanners();
    _generateMockData();
  }

  void _generateMockData() {
    _allProducts = [];
    
    for (final city in _cities.where((c) => c != 'Toutes')) {
      for (final category in _categories.where((c) => c != 'Tous')) {
        for (int i = 1; i <= 4; i++) {
          _allProducts.add(Product(
            id: '${city}_${category}_$i',
            title: _getProductName(category, i),
            description: 'Description du produit $i dans la catégorie $category à $city',
            price: _getRandomPrice(category),
            category: category,
            city: city,
            rating: 3.5 + (i * 0.3),
            reviewsCount: 50 + (i * 10),
            imageUrl: 'https://picsum.photos/400/400?random=${city.hashCode + i}',
            seller: 'Vendeur de $city',
            sellerId: 'seller_$city',
            sellerAvatar: 'https://picsum.photos/50/50?random=${city.hashCode}',
            country: 'RDC',
            inStock: true,
            stock: 10 + i,
            createdAt: DateTime.now().subtract(Duration(days: i)),
          ));
        }
      }
    }
    
    // Produits flash avec countdown 72h
    _flashSales = [];
    final flashCities = ['Kinshasa', 'Lubumbashi', 'Mbuji-Mayi', 'Kisangani'];
    final flashCategories = ['Électronique', 'Mode & Fashion', 'Maison & Déco', 'Beauté & Santé'];
    
    for (int i = 0; i < 8; i++) {
      final city = flashCities[i % flashCities.length];
      final category = flashCategories[i % flashCategories.length];
      _flashSales.add(Product(
        id: 'flash_$i',
        title: 'Flash ${_getProductName(category, i + 1)}',
        description: 'Offre flash - 72h seulement !',
        price: _getFlashPrice(category),
        category: category,
        city: city,
        rating: 4.5 + (i * 0.1),
        reviewsCount: 200 + (i * 15),
        imageUrl: 'https://picsum.photos/400/400?random=flash$i',
        seller: 'Flash Vendeur',
        sellerId: 'flash_seller_$i',
        sellerAvatar: 'https://picsum.photos/50/50?random=flash$i',
        country: 'RDC',
        inStock: true,
        stock: 5,
        createdAt: DateTime.now(),
      ));
    }
    
    // Produits pour le carrousel défilant
    _carouselProducts = _flashSales.take(4).toList();
    
    _filteredProducts = List.from(_allProducts);
  }

  String _getProductName(String category, int index) {
    final names = {
      'Électronique': ['Smartphone Pro', 'Tablette Ultra', 'Ordinateur Portable', 'Casque Audio'],
      'Mode & Fashion': ['T-shirt Premium', 'Jean Slim', 'Robe Élégante', 'Chaussures Sport'],
      'Maison & Déco': ['Canapé Moderne', 'Table à Manger', 'Lampe Design', 'Tapis Art'],
      'Beauté & Santé': ['Crème Hydratante', 'Parfum Luxe', 'Masque Visage', 'Huile Essentielle'],
      'Sports & Loisirs': ['Vélo Montagne', 'Tapis Course', 'Ballon Football', 'Raquette Tennis'],
      'Alimentation': ['Café Premium', 'Chocolat Belge', 'Miel Bio', 'Thé Vert'],
      'Automobile': ['Huile Moteur', 'Pneus Hiver', 'Accessoires Auto', 'Batterie Voiture'],
    };
    final list = names[category] ?? ['Produit $index'];
    return list[index % list.length];
  }

  double _getRandomPrice(String category) {
    final basePrices = {
      'Électronique': 500000.0,
      'Mode & Fashion': 150000.0,
      'Maison & Déco': 300000.0,
      'Beauté & Santé': 75000.0,
      'Sports & Loisirs': 200000.0,
      'Alimentation': 25000.0,
      'Automobile': 450000.0,
    };
    return basePrices[category] ?? 100000.0;
  }

  double _getFlashPrice(String category) {
    final basePrices = {
      'Électronique': 350000.0,
      'Mode & Fashion': 99000.0,
      'Maison & Déco': 199000.0,
      'Beauté & Santé': 49000.0,
    };
    return basePrices[category] ?? 100000.0;
  }

  Future<void> _loadBanners() async {
    try {
      final banners = await _bannerService.getActiveBanners();
      setState(() => _banners = banners);
    } catch (e) {
      debugPrint('Error loading banners: $e');
    }
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final flash = await _marketService.getFlashSales();
      if (flash.isNotEmpty) setState(() => _flashSales = flash);
      final all = await _marketService.getFeaturedProducts();
      if (all.isNotEmpty) setState(() => _allProducts = all);
      _applyFiltersAndSort();
    } catch (e) {
      debugPrint('Error loading market data: $e');
      _generateMockData();
    } finally {
      setState(() => _loading = false);
    }
  }

  void _applyFiltersAndSort() {
    setState(() {
      var filtered = _allProducts.where((p) {
        if (_selectedCategory != 'Tous' && p.category != _selectedCategory) return false;
        if (p.price < _priceRange.start || p.price > _priceRange.end) return false;
        if (p.rating < _minRating) return false;
        if (_selectedCity != 'Toutes' && p.city != _selectedCity) return false;
        return true;
      }).toList();
      
      switch (_sortBy) {
        case 'price_asc': filtered.sort((a, b) => a.price.compareTo(b.price)); break;
        case 'price_desc': filtered.sort((a, b) => b.price.compareTo(a.price)); break;
        case 'rating': filtered.sort((a, b) => b.rating.compareTo(a.rating)); break;
        case 'popularity': filtered.sort((a, b) => b.reviewsCount.compareTo(a.reviewsCount)); break;
        default: filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
      
      _filteredProducts = filtered;
    });
  }

  void _filterByCategory(String category) {
    _selectedCategory = category;
    _applyFiltersAndSort();
  }

  void _searchProducts(String query) {
    if (query.isEmpty) {
      _applyFiltersAndSort();
      return;
    }
    setState(() {
      _filteredProducts = _allProducts.where((p) =>
        p.title.toLowerCase().contains(query.toLowerCase()) ||
        p.category.toLowerCase().contains(query.toLowerCase()) ||
        p.city.toLowerCase().contains(query.toLowerCase())
      ).toList();
    });
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('Filtres', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text('Prix (CDF)', style: TextStyle(fontWeight: FontWeight.bold)),
                RangeSlider(
                  values: _priceRange, min: 0, max: 5000000, divisions: 10,
                  labels: RangeLabels('${_priceRange.start.round()} CDF', '${_priceRange.end.round()} CDF'),
                  onChanged: (values) => setModalState(() => _priceRange = values),
                ),
                const SizedBox(height: 16),
                const Text('Note minimum', style: TextStyle(fontWeight: FontWeight.bold)),
                Slider(
                  value: _minRating, min: 0, max: 5, divisions: 10,
                  label: _minRating.toStringAsFixed(1),
                  onChanged: (v) => setModalState(() => _minRating = v),
                ),
                const SizedBox(height: 16),
                const Text('Ville', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _cities.map((city) => FilterChip(
                    label: Text(city),
                    selected: _selectedCity == city,
                    onSelected: (_) => setModalState(() => _selectedCity = city),
                    selectedColor: const Color(0xFFD4AF37),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                const Text('Trier par', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildSortChip('Plus récents', 'newest', setModalState),
                    _buildSortChip('Prix croissant', 'price_asc', setModalState),
                    _buildSortChip('Prix décroissant', 'price_desc', setModalState),
                    _buildSortChip('Meilleures notes', 'rating', setModalState),
                    _buildSortChip('Plus populaires', 'popularity', setModalState),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: OutlinedButton(onPressed: () {
                      setModalState(() {
                        _priceRange = const RangeValues(0, 5000000);
                        _minRating = 0;
                        _selectedCity = 'Toutes';
                        _sortBy = 'newest';
                      });
                    }, child: const Text('Tout effacer'))),
                    const SizedBox(width: 12),
                    Expanded(child: ElevatedButton(
                      onPressed: () { _applyFiltersAndSort(); Navigator.pop(context); },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: const Color(0xFF0B1B3D)),
                      child: const Text('Appliquer'),
                    )),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSortChip(String label, String value, void Function(void Function()) setModalState) {
    return FilterChip(
      label: Text(label),
      selected: _sortBy == value,
      onSelected: (_) => setModalState(() => _sortBy = value),
      selectedColor: const Color(0xFFD4AF37),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context);
    final auth = Provider.of<AuthController>(context);
    final userName = auth.currentUser?.displayName ?? 'Invité';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1B3D),
        elevation: 0,
        title: const Text('THIX MARKET', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list, color: Colors.white), onPressed: _showFilters),
          Stack(
            children: [
              IconButton(icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white), onPressed: () => context.push('/market/cart')),
              if (cartService.itemCount > 0)
                Positioned(
                  right: 4, top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text('${cartService.itemCount}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(userName),
              const SizedBox(height: 16),
              if (_banners.isNotEmpty) ...[
                BannerCarousel(banners: _banners),
                const SizedBox(height: 16),
              ],
              _buildFeatures(),
              const SizedBox(height: 16),
              _buildSearchBar(),
              const SizedBox(height: 12),
              _buildCategories(),
              const SizedBox(height: 12),
              _buildCityFilter(),
              const SizedBox(height: 16),
              if (_flashSales.isNotEmpty) _buildFlashSales(),
              const SizedBox(height: 20),
              _buildCarouselProducts(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_selectedCategory == 'Tous' ? 'Tous les produits' : 'Produits - $_selectedCategory',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('${_filteredProducts.length} produits', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
              const SizedBox(height: 12),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ProductsGrid(
                      products: _filteredProducts,
                      onProductTap: (product) => _showProductDetail(context, product),
                      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                    ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildHeader(String userName) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0B1B3D), Color(0xFF1A2D56)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text('Bonjour, $userName 🎉', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Votre marketplace premium et sécurisée', style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: const Color(0xFF0B1B3D),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Explorer le marché', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures() {
    final features = [
      ('🔒', 'Paiement sécurisé'), ('✅', 'Vendeurs vérifiés'),
      ('🚚', 'Livraison fiable'), ('💬', 'Support 24/7'),
    ];
    return Row(
      children: features.map((f) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
          child: Column(
            children: [
              Text(f.$1, style: const TextStyle(fontSize: 20)),
              Text(f.$2, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: _searchProducts,
      decoration: InputDecoration(
        hintText: 'Rechercher...',
        hintStyle: const TextStyle(fontSize: 13),
        prefixIcon: const Icon(Icons.search, size: 18),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(icon: const Icon(Icons.clear, size: 16), onPressed: () { _searchController.clear(); _searchProducts(''); })
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      style: const TextStyle(fontSize: 14),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(cat, style: const TextStyle(fontSize: 12)),
              selected: _selectedCategory == cat,
              onSelected: (_) => _filterByCategory(cat),
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFFD4AF37),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCityFilter() {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _cities.length,
        itemBuilder: (context, index) {
          final city = _cities[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(city, style: const TextStyle(fontSize: 11)),
              selected: _selectedCity == city,
              onSelected: (_) {
                setState(() => _selectedCity = city);
                _applyFiltersAndSort();
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFFD4AF37),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFlashSales() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('⚡ Offres flash - 72h', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(onPressed: () {}, child: const Text('Voir tout >')),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _flashSales.length,
            itemBuilder: (context, index) => SizedBox(
              width: 160,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ProductCard(
                  product: _flashSales[index],
                  onTap: () => _showProductDetail(context, _flashSales[index]),
                  showLocation: true,
                  showStock: true,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCarouselProducts() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('📢 À ne pas manquer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextButton(onPressed: () {}, child: const Text('Voir tout >')),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _carouselProducts.length,
            itemBuilder: (context, index) {
              final product = _carouselProducts[index];
              // Calculer un prix original fictif pour l'affichage (30% de plus)
              final displayOriginalPrice = product.price * 1.3;
              final discount = 30; // 30% de réduction
              return Container(
                width: MediaQuery.of(context).size.width * 0.7,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                      child: Image.network(
                        product.imageUrl,
                        width: 120,
                        height: 220,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(width: 120, color: Colors.grey.shade200, child: const Icon(Icons.image)),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(product.title, maxLines: 2, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(product.city, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text('${product.price.round()} FCFA', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
                                const SizedBox(width: 6),
                                Text('${displayOriginalPrice.round()} FCFA', style: const TextStyle(decoration: TextDecoration.lineThrough, fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                              child: Text('-$discount%', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      height: 55,
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_outlined, 'Accueil', true, () => context.go('/')),
          _navItem(Icons.category_outlined, 'Catégories', false, () => _filterByCategory('Tous')),
          _navItem(Icons.shopping_bag_outlined, 'Commandes', false, () => context.push('/market/orders')),
          _navItem(Icons.person_outline, 'Profil', false, () => context.go('/user-dashboard')),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: active ? const Color(0xFFD4AF37) : Colors.grey, size: 20),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: active ? const Color(0xFFD4AF37) : Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }

  void _showProductDetail(BuildContext context, Product product) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)));
  }
}
