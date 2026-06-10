// lib/presentation/thix_reservation/pages/mes_reservations.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MesReservationsPage extends StatefulWidget {
  const MesReservationsPage({super.key});

  @override
  State<MesReservationsPage> createState() => _MesReservationsPageState();
}

class _MesReservationsPageState extends State<MesReservationsPage> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Mes réservations'),
        backgroundColor: const Color(0xFF0B1B3D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildTabs(),
          Expanded(
            child: IndexedStack(
              index: _selectedTab,
              children: const [
                _VolsList(),
                _HotelsList(),
                _BusList(),
                _TaxiList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    final tabs = ['Vols', 'Hôtels', 'Bus', 'Taxis'];
    return Container(
      color: Colors.white,
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _selectedTab == index ? const Color(0xFFD4AF37) : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _selectedTab == index ? const Color(0xFFD4AF37) : Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _VolsList extends StatelessWidget {
  const _VolsList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 2,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Ethiopian Airlines', style: TextStyle(fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Confirmé', style: TextStyle(color: Colors.green, fontSize: 10)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text('23:45', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const Text('Kinshasa', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  const Expanded(
                    child: Column(
                      children: [
                        Icon(Icons.flight, color: Color(0xFFD4AF37)),
                        Text('10h25', style: TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Text('06:10', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const Text('Paris', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('25 Mai 2025', style: TextStyle(color: Colors.grey)),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: const Color(0xFF0B1B3D),
                    ),
                    child: const Text('Voir détails'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HotelsList extends StatelessWidget {
  const _HotelsList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 1,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.hotel, color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Azalai Hôtel Abidjan', style: TextStyle(fontWeight: FontWeight.bold)),
                        const Text('Abidjan, Côte d\'Ivoire', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Row(
                          children: [
                            ...List.generate(5, (i) => Icon(Icons.star, size: 12, color: i < 4 ? Colors.amber : Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Confirmé', style: TextStyle(color: Colors.green, fontSize: 10)),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('20-22 Mai 2025', style: TextStyle(color: Colors.grey)),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: const Color(0xFF0B1B3D),
                    ),
                    child: const Text('Voir détails'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BusList extends StatelessWidget {
  const _BusList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 1,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Rapide Bus', style: TextStyle(fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Confirmé', style: TextStyle(color: Colors.green, fontSize: 10)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text('08:00', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const Text('Abidjan', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  const Expanded(
                    child: Column(
                      children: [
                        Icon(Icons.directions_bus, color: Color(0xFFD4AF37)),
                        Text('4h', style: TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Text('12:00', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const Text('Yamoussoukro', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('25 Mai 2025', style: TextStyle(color: Colors.grey)),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: const Color(0xFF0B1B3D),
                    ),
                    child: const Text('Voir détails'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TaxiList extends StatelessWidget {
  const _TaxiList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 2,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Trajet Standard', style: TextStyle(fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Terminé', style: TextStyle(color: Colors.green, fontSize: 10)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Color(0xFFD4AF37)),
                        const Text('Abidjan', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward, color: Colors.grey),
                  Expanded(
                    child: Column(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.red),
                        const Text('Yamoussoukro', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('25 Mai 2025 - 08:00', style: TextStyle(color: Colors.grey)),
                  Text('25.000 FCFA', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
