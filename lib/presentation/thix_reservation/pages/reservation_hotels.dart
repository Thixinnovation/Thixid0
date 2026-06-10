// lib/presentation/thix_reservation/pages/reservation_hotels.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ReservationHotelsPage extends StatefulWidget {
  const ReservationHotelsPage({super.key});

  @override
  State<ReservationHotelsPage> createState() => _ReservationHotelsPageState();
}

class _ReservationHotelsPageState extends State<ReservationHotelsPage> {
  bool _isLoading = false;
  String _destination = 'Abidjan, Cote d\'Ivoire';
  DateTime _arrivee = DateTime.now().add(const Duration(days: 7));
  DateTime _depart = DateTime.now().add(const Duration(days: 9));
  int _chambres = 1;
  int _adultes = 2;

  Future<void> _rechercherHotels() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock data pour les hôtels
    final hotels = [
      {'id': '1', 'nom': 'Azalai Hotel Abidjan', 'ville': 'Abidjan', 'prix': 68000, 'prixOriginal': 85600, 'note': 4.5, 'image': ''},
      {'id': '2', 'nom': 'Onomo Hotel Dakar', 'ville': 'Dakar', 'prix': 63750, 'prixOriginal': 75000, 'note': 4.2, 'image': ''},
      {'id': '3', 'nom': 'Pullman Hotel Paris', 'ville': 'Paris', 'prix': 198, 'prixOriginal': 220, 'note': 4.6, 'image': ''},
    ];
    
    setState(() => _isLoading = false);
    if (mounted) {
      context.push('/reservation/hotels/liste', extra: hotels);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Reserver un hotel'),
        backgroundColor: const Color(0xFF0B1B3D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDestinationField(),
            const SizedBox(height: 16),
            _buildDateRow(),
            const SizedBox(height: 16),
            _buildChambresAdultes(),
            const SizedBox(height: 24),
            _buildSearchButton(),
            const SizedBox(height: 24),
            _buildCategoriesPopulaires(),
            const SizedBox(height: 24),
            _buildOffresMoment(),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Destination', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _destination,
            decoration: const InputDecoration(border: InputBorder.none),
            items: ['Abidjan, Cote d\'Ivoire', 'Dakar, Senegal', 'Paris, France', 'Dubai, UAE']
                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                .toList(),
            onChanged: (val) => setState(() => _destination = val!),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow() {
    return Row(
      children: [
        Expanded(child: _buildDateField('Arrivee', _arrivee, (date) => setState(() => _arrivee = date))),
        const SizedBox(width: 12),
        Expanded(child: _buildDateField('Depart', _depart, (date) => setState(() => _depart = date))),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime date, Function(DateTime) onSelected) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: date,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) onSelected(picked);
            },
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Color(0xFFD4AF37)),
                const SizedBox(width: 8),
                Text('${date.day}/${date.month}/${date.year}', style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChambresAdultes() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Chambres & voyageurs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildCounter('Chambres', _chambres, (val) => setState(() => _chambres = val), 1, 10)),
              const SizedBox(width: 16),
              Expanded(child: _buildCounter('Adultes', _adultes, (val) => setState(() => _adultes = val), 1, 20)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounter(String label, int value, Function(int) onChanged, int min, int max) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove, size: 18),
              onPressed: value > min ? () => onChanged(value - 1) : null,
            ),
            Text('$value', style: const TextStyle(fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.add, size: 18),
              onPressed: value < max ? () => onChanged(value + 1) : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _rechercherHotels,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD4AF37),
          foregroundColor: const Color(0xFF0B1B3D),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: _isLoading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : const Text('Rechercher', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Widget _buildCategoriesPopulaires() {
    final categories = [
      {'icon': '🏨', 'label': 'Hotels de luxe'},
      {'icon': '💰', 'label': 'Hotels pas chers'},
      {'icon': '🏖️', 'label': 'Bord de mer'},
      {'icon': '💼', 'label': 'Hotels d\'affaires'},
      {'icon': '❤️', 'label': 'Hotels romantiques'},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Categories populaires', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4)],
                ),
                child: Row(
                  children: [
                    Text(cat['icon']!, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(cat['label']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOffresMoment() {
    final offres = [
      {'nom': 'Azalai Hotel Abidjan', 'prixOriginal': '85.600', 'prixPromo': '68.000', 'note': '4.5', 'ville': 'Abidjan'},
      {'nom': 'Onomo Hotel Dakar', 'prixOriginal': '75.000', 'prixPromo': '63.750', 'note': '4.2', 'ville': 'Dakar'},
      {'nom': 'Pullman Hotel Paris', 'prixOriginal': '220', 'prixPromo': '198', 'note': '4.6', 'ville': 'Paris', 'devise': '€'},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Offres du moment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: offres.length,
            itemBuilder: (context, index) {
              final offre = offres[index];
              return Container(
                width: 250,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 8, left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                              child: const Text('-20%', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          Positioned(
                            top: 8, right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                children: [
                                  const Icon(Icons.star, size: 10, color: Colors.amber),
                                  Text(offre['note']!, style: const TextStyle(fontSize: 10)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(offre['nom']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(offre['ville']!, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text('${offre['prixOriginal']!} ${offre['devise'] ?? 'FCFA'}', style: const TextStyle(decoration: TextDecoration.lineThrough, fontSize: 10, color: Colors.grey)),
                              const SizedBox(width: 8),
                              Text('${offre['prixPromo']!} ${offre['devise'] ?? 'FCFA'}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD4AF37), fontSize: 12)),
                            ],
                          ),
                        ],
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
}
