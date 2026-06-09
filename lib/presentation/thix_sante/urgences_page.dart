import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UrgencesPage extends StatelessWidget {
  UrgencesPage({super.key});

  final List<Map<String, dynamic>> _emergencyNumbers = [
    {'name': 'SAMU', 'number': '15', 'icon': Icons.local_hospital, 'color': Colors.red},
    {'name': 'Police', 'number': '17', 'icon': Icons.local_police, 'color': Colors.blue},
    {'name': 'Pompiers', 'number': '18', 'icon': Icons.fire_extinguisher, 'color': Colors.orange},
    {'name': 'Centre Anti-Poison', 'number': '1234', 'icon': Icons.medical_services, 'color': Colors.purple},
  ];

  final List<Map<String, dynamic>> _emergencyServices = [
    {'name': 'Clinique Ngaliema', 'address': 'Kinshasa, Gombe', 'phone': '+243 123 456 789', 'distance': '2.3 km', 'waiting_time': '15 min'},
    {'name': 'Hôpital du Cinquantenaire', 'address': 'Kinshasa, Limete', 'phone': '+243 123 456 790', 'distance': '5.1 km', 'waiting_time': '25 min'},
    {'name': 'Clinique Kinoise', 'address': 'Kinshasa, Ngaliema', 'phone': '+243 123 456 791', 'distance': '3.5 km', 'waiting_time': '20 min'},
  ];

  Future<void> _makeCall(String number) async {
    final url = Uri.parse('tel:$number');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Urgences', style: TextStyle(color: Color(0xFF0B1B3D), fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Numéros d\'urgence', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _emergencyNumbers.length,
              itemBuilder: (context, index) => _buildEmergencyNumberCard(_emergencyNumbers[index]),
            ),
            const SizedBox(height: 24),
            const Text('Services d\'urgence à proximité', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _emergencyServices.length,
              itemBuilder: (context, index) => _buildEmergencyServiceCard(_emergencyServices[index]),
            ),
            const SizedBox(height: 16),
            _buildFirstAidTips(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyNumberCard(Map<String, dynamic> number) {
    final icon = number['icon'] as IconData? ?? Icons.phone;
    final color = number['color'] as Color? ?? Colors.grey;
    final name = number['name']?.toString() ?? 'Urgence';
    final numberValue = number['number']?.toString() ?? '';

    return GestureDetector(
      onTap: () => _makeCall(numberValue),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(numberValue, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyServiceCard(Map<String, dynamic> service) {
    final name = service['name']?.toString() ?? 'Service';
    final address = service['address']?.toString() ?? '';
    final phone = service['phone']?.toString() ?? '';
    final distance = service['distance']?.toString() ?? '';
    final waitingTime = service['waiting_time']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.local_hospital, color: Colors.red),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(address, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(20)),
                child: Text('$waitingTime attente', style: const TextStyle(fontSize: 10, color: Colors.orange)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.phone, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(child: Text(phone)),
              const SizedBox(width: 16),
              const Icon(Icons.location_on, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(distance),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _makeCall(phone),
                  icon: const Icon(Icons.phone),
                  label: const Text('Appeler'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.directions),
                  label: const Text('Itinéraire'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.blue),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFirstAidTips() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue),
              SizedBox(width: 8),
              Text('Gestes qui sauvent', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          const Text('• En cas d\'arrêt cardiaque : massez immédiatement'),
          const Text('• En cas d\'étouffement : pratiquez la méthode Heimlich'),
          const Text('• En cas de brûlure : refroidissez à l\'eau pendant 15 min'),
          const Text('• En cas de saignement : comprimez la plaie'),
        ],
      ),
    );
  }
}
