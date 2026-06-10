// lib/presentation/thix_reservation/pages/reservation_bus.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/bus_service.dart';
import 'bus_liste.dart';

class ReservationBusPage extends StatefulWidget {
  const ReservationBusPage({super.key});

  @override
  State<ReservationBusPage> createState() => _ReservationBusPageState();
}

class _ReservationBusPageState extends State<ReservationBusPage> {
  final BusService _busService = BusService();
  bool _isLoading = false;
  String _depart = 'Abidjan';
  String _arrivee = 'Yamoussoukro';
  DateTime _date = DateTime.now().add(const Duration(days: 7));
  int _passagers = 1;

  Future<void> _rechercherBus() async {
    setState(() => _isLoading = true);
    final bus = await _busService.rechercherBus(
      depart: _depart,
      arrivee: _arrivee,
      date: _date,
      passagers: _passagers,
    );
    setState(() => _isLoading = false);
    if (context.mounted) {
      context.push('/reservation/bus/liste', extra: bus);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Réserver un bus'),
        backgroundColor: const Color(0xFF0B1B3D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Formulaires
            _buildLocationField('Départ', _depart, (val) => setState(() => _depart = val),
                ['Abidjan', 'Yamoussoukro', 'Bouaké', 'Korhogo', 'San Pedro']),
            const SizedBox(height: 16),
            _buildLocationField('Arrivée', _arrivee, (val) => setState(() => _arrivee = val),
                ['Yamoussoukro', 'Abidjan', 'Bouaké', 'Korhogo', 'San Pedro']),
            const SizedBox(height: 16),
            _buildDateField(),
            const SizedBox(height: 16),
            _buildPassagers(),
            const SizedBox(height: 24),

            // Bouton rechercher
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _rechercherBus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: const Color(0xFF0B1B3D),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Rechercher un bus', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 24),

            // Routes populaires
            const Text('Routes populaires', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildRoutesPopulaires(),
            const SizedBox(height: 24),

            // Nos bus pour votre confort
            const Text('Nos bus pour votre confort', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildConfortFeatures(),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationField(String label, String value, Function(String) onChanged, List<String> options) {
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
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: value,
            decoration: const InputDecoration(border: InputBorder.none),
            items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
            onChanged: (val) => onChanged(val!),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField() {
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
          const Text('Date de départ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) setState(() => _date = picked);
            },
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Color(0xFFD4AF37)),
                const SizedBox(width: 8),
                Text('${_date.day}/${_date.month}/${_date.year}', style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassagers() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Nombre de passagers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove, size: 18),
                onPressed: _passagers > 1 ? () => setState(() => _passagers--) : null,
              ),
              Text('$_passagers', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              IconButton(
                icon: const Icon(Icons.add, size: 18),
                onPressed: _passagers < 10 ? () => setState(() => _passagers++) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoutesPopulaires() {
    final routes = [
      {'route': 'Abidjan → Yamoussoukro', 'heure': '08:00', 'prix': '5.000 FCFA'},
      {'route': 'Abidjan → Bouaké', 'heure': '09:00', 'prix': '6.000 FCFA'},
      {'route': 'Abidjan → Korhogo', 'heure': '10:00', 'prix': '7.000 FCFA'},
      {'route': 'Yamoussoukro → Abidjan', 'heure': '14:00', 'prix': '5.000 FCFA'},
    ];
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: routes.length,
      itemBuilder: (context, index) {
        final route = routes[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(route['route']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(route['heure']!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              Text(route['prix']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConfortFeatures() {
    final features = [
      {'icon': Icons.event_seat, 'label': 'Sièges confortables'},
      {'icon': Icons.wifi, 'label': 'Wi-Fi gratuit'},
      {'icon': Icons.ac_unit, 'label': 'Climatisation'},
      {'icon': Icons.luggage, 'label': 'Bagages autorisés'},
      {'icon': Icons.security, 'label': 'Sécurité garantie'},
    ];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: features.map((feature) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4)],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(feature['icon'] as IconData, size: 16, color: const Color(0xFFD4AF37)),
              const SizedBox(width: 8),
              Text(feature['label'] as String, style: const TextStyle(fontSize: 12)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
