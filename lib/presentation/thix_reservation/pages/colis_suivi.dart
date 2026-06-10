// lib/presentation/thix_reservation/pages/colis_suivi.dart
import 'package:flutter/material.dart';

class ColisSuiviPage extends StatefulWidget {
  const ColisSuiviPage({super.key});

  @override
  State<ColisSuiviPage> createState() => _ColisSuiviPageState();
}

class _ColisSuiviPageState extends State<ColisSuiviPage> {
  final TextEditingController _trackingController = TextEditingController();
  String _trackingNumber = '';
  int _currentStep = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Suivre mon colis'),
        backgroundColor: const Color(0xFF0B1B3D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 20),
            if (_trackingNumber.isNotEmpty) _buildTrackingInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4)],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _trackingController,
              decoration: const InputDecoration(
                hintText: 'Numero de suivi',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFFD4AF37)),
            onPressed: () => setState(() => _trackingNumber = _trackingController.text),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
                  const Text('Numero de suivi', style: TextStyle(color: Colors.grey)),
                  Text(_trackingNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Statut', style: TextStyle(color: Colors.grey)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('En cours de livraison', style: TextStyle(color: Colors.green, fontSize: 12)),
                  ),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Livraison estimee', style: TextStyle(color: Colors.grey)),
                  const Text('25 Mai 2025', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text('Historique du suivi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildTimeline(),
      ],
    );
  }

  Widget _buildTimeline() {
    final steps = [
      {'status': 'Colis enregistre', 'date': '18 Mai 2025 - 10:30', 'location': 'Abidjan', 'completed': true},
      {'status': 'Prise en charge', 'date': '18 Mai 2025 - 14:00', 'location': 'Abidjan', 'completed': true},
      {'status': 'En transit', 'date': '19 Mai 2025 - 08:00', 'location': 'En route', 'completed': true},
      {'status': 'Arrivee a destination', 'date': 'En attente', 'location': 'Yamoussoukro', 'completed': false},
      {'status': 'Livre', 'date': 'En attente', 'location': 'Yamoussoukro', 'completed': false},
    ];
    return Column(
      children: steps.asMap().entries.map((entry) {
        final step = entry.value;
        final bool completed = step['completed'] as bool;
        final String status = step['status'] as String;
        final String date = step['date'] as String;
        final String location = step['location'] as String;
        final bool isLast = entry.key == steps.length - 1;
        
        return Row(
          children: [
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: completed ? const Color(0xFFD4AF37) : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: completed
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: completed ? const Color(0xFFD4AF37) : Colors.grey.shade300,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(status, style: TextStyle(fontWeight: FontWeight.bold, color: completed ? Colors.black : Colors.grey)),
                    const SizedBox(height: 4),
                    Text(date, style: TextStyle(fontSize: 11, color: completed ? Colors.grey : Colors.grey.shade400)),
                    Text(location, style: TextStyle(fontSize: 11, color: completed ? Colors.grey : Colors.grey.shade400)),
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
