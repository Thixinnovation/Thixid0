// lib/presentation/thix_reservation/pages/bus_reservation.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BusReservationPage extends StatefulWidget {
  const BusReservationPage({super.key});

  @override
  State<BusReservationPage> createState() => _BusReservationPageState();
}

class _BusReservationPageState extends State<BusReservationPage> {
  int _selectedSiege = -1;
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Réservation bus'),
        backgroundColor: const Color(0xFF0B1B3D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTripSummary(),
            const SizedBox(height: 20),
            _buildSiegeSelection(),
            const SizedBox(height: 20),
            _buildPassengerInfo(),
            const SizedBox(height: 20),
            _buildPriceSummary(),
            const SizedBox(height: 24),
            _buildReserveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTripSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.directions_bus, size: 40, color: Color(0xFFD4AF37)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Rapide Bus', style: TextStyle(fontWeight: FontWeight.bold)),
                const Text('Abidjan → Yamoussoukro', style: TextStyle(fontSize: 12)),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 12, color: Colors.grey),
                    const Text(' 08:00 - 12:00', style: TextStyle(fontSize: 11)),
                    const SizedBox(width: 12),
                    const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                    Text(' ${DateTime.now().add(const Duration(days: 7)).day}/${DateTime.now().add(const Duration(days: 7)).month}/2025', style: const TextStyle(fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSiegeSelection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Choisissez votre siège', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 20,
            itemBuilder: (context, index) {
              final isSelected = _selectedSiege == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedSiege = index),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFD4AF37) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isSelected ? const Color(0xFFD4AF37) : Colors.grey.shade300),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Informations passager', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _nomController,
            decoration: InputDecoration(
              labelText: 'Nom complet',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _telephoneController,
            decoration: InputDecoration(
              labelText: 'Téléphone',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Total à payer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Text('5.000 FCFA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFD4AF37))),
        ],
      ),
    );
  }

  Widget _buildReserveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Réservation confirmée !'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD4AF37),
          foregroundColor: const Color(0xFF0B1B3D),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: const Text('Confirmer la réservation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
