// lib/presentation/thix_reservation/pages/reservation_restaurant.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ReservationRestaurantPage extends StatefulWidget {
  const ReservationRestaurantPage({super.key});

  @override
  State<ReservationRestaurantPage> createState() => _ReservationRestaurantPageState();
}

class _ReservationRestaurantPageState extends State<ReservationRestaurantPage> {
  String _selectedCategory = 'Tous';
  String _searchQuery = '';
  List<Map<String, dynamic>> _restaurants = [];

  final List<String> _categories = [
    'Tous', 'Africaine', 'Fast Food', 'Italienne', 'Japonaise', 'Francaise', 'Asiatique'
  ];

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  void _loadRestaurants() {
    _restaurants = [
      {'id': '1', 'nom': 'Le Gout Ici', 'type': 'Africaine', 'note': '4.6', 'prix': 'Moyen', 'distance': '1.2 km', 'time': '20-30 min', 'image': '🍲'},
      {'id': '2', 'nom': 'Fast Good', 'type': 'Fast Food', 'note': '4.8', 'prix': 'Moyen', 'distance': '0.8 km', 'time': '15-25 min', 'image': '🍔'},
      {'id': '3', 'nom': 'Pizza Time', 'type': 'Italienne', 'note': '4.5', 'prix': 'Moyen', 'distance': '2.1 km', 'time': '20-30 min', 'image': '🍕'},
      {'id': '4', 'nom': 'Sushi House', 'type': 'Japonaise', 'note': '4.7', 'prix': 'Eleve', 'distance': '3.0 km', 'time': '25-35 min', 'image': '🍣'},
      {'id': '5', 'nom': 'Chez Maman', 'type': 'Africaine', 'note': '4.9', 'prix': 'Moyen', 'distance': '0.5 km', 'time': '10-20 min', 'image': '🍛'},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Restaurants pres de vous'),
        backgroundColor: const Color(0xFF0B1B3D),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilters(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategories(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _restaurants.length,
              itemBuilder: (context, index) {
                final restaurant = _restaurants[index];
                return _buildRestaurantCard(restaurant);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD4AF37),
        onPressed: () {},
        child: const Icon(Icons.my_location, color: Color(0xFF0B1B3D)),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Rechercher un restaurant...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _searchQuery = ''))
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(cat),
              selected: _selectedCategory == cat,
              onSelected: (_) => setState(() => _selectedCategory = cat),
              selectedColor: const Color(0xFFD4AF37),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRestaurantCard(Map<String, dynamic> restaurant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4)],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(restaurant['image'], style: const TextStyle(fontSize: 35))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(restaurant['nom'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, size: 10, color: Colors.amber),
                          Text(' ${restaurant['note']}', style: const TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(restaurant['type'], style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 12, color: Colors.grey.shade400),
                    Text(restaurant['distance'], style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                    const SizedBox(width: 12),
                    Icon(Icons.access_time, size: 12, color: Colors.grey.shade400),
                    Text(restaurant['time'], style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                    const SizedBox(width: 12),
                    Text(restaurant['prix'], style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: const Color(0xFF0B1B3D),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Reserver'),
          ),
        ],
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Filtres', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Prix', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['Bas', 'Moyen', 'Eleve'].map((prix) {
                return FilterChip(label: Text(prix), selected: false, onSelected: (_) {});
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Distance', style: TextStyle(fontWeight: FontWeight.bold)),
            Slider(value: 5, min: 0, max: 10, onChanged: (_) {}),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
              child: const Text('Appliquer'),
            ),
          ],
        ),
      ),
    );
  }
}
