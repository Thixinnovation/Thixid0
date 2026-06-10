// lib/presentation/thix_reservation/pages/bus_recherche.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BusRecherchePage extends StatefulWidget {
  const BusRecherchePage({super.key});

  @override
  State<BusRecherchePage> createState() => _BusRecherchePageState();
}

class _BusRecherchePageState extends State<BusRecherchePage> {
  String _depart = 'Abidjan';
  String _arrivee = 'Yamoussoukro';
  DateTime _date = DateTime.now().add(const Duration(days: 7));
  int _passagers = 1;

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
            _buildSearchButton(),
            const SizedBox(height: 24),
            _buildRoutesPopulaires(),
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
            items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
            onChanged: (val) => onChanged(val!),
            decoration: const InputDecoration(border: InputBorder.none),
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

  Widget _buildSearchButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () => context.push('/reservation/bus/liste'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD4AF37),
          foregroundColor: const Color(0xFF0B1B3D),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: const Text('Rechercher un bus', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Routes populaires', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...routes.map((route) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
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
        )),
      ],
    );
  }
}
