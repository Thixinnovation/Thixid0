// lib/presentation/thix_reservation/widgets/flight_search_bar.dart
import 'package:flutter/material.dart';

class FlightSearchBar extends StatelessWidget {
  final String origine;
  final String destination;
  final DateTime depart;
  final DateTime? retour;
  final int passagers;
  final String classe;
  final Function(String) onOrigineChanged;
  final Function(String) onDestinationChanged;
  final Function(DateTime) onDepartChanged;
  final Function(DateTime) onRetourChanged;
  final Function(int) onPassagersChanged;
  final Function(String) onClasseChanged;

  const FlightSearchBar({
    super.key,
    required this.origine,
    required this.destination,
    required this.depart,
    this.retour,
    required this.passagers,
    required this.classe,
    required this.onOrigineChanged,
    required this.onDestinationChanged,
    required this.onDepartChanged,
    required this.onRetourChanged,
    required this.onPassagersChanged,
    required this.onClasseChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4)],
      ),
      child: Column(
        children: [
          _buildLocationField("De", origine, onOrigineChanged, Icons.flight_takeoff),
          const SizedBox(height: 12),
          _buildLocationField("À", destination, onDestinationChanged, Icons.flight_land),
          const SizedBox(height: 12),
          _buildDateField("Départ", depart, onDepartChanged),
          if (retour != null) ...[
            const SizedBox(height: 12),
            _buildDateField("Retour", retour!, onRetourChanged),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPassagersField(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildClasseField(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationField(String label, String value, Function(String) onChanged, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFFD4AF37)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: label,
                border: InputBorder.none,
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(String label, DateTime date, Function(DateTime) onSelected) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: navigatorKey.currentContext!,
          initialDate: date,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) onSelected(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 18, color: Color(0xFFD4AF37)),
            const SizedBox(width: 8),
            Text('${date.day}/${date.month}/${date.year}'),
          ],
        ),
      ),
    );
  }

  Widget _buildPassagersField() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.people, size: 18, color: Color(0xFFD4AF37)),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 16),
                  onPressed: () => onPassagersChanged(passagers - 1),
                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                ),
                Text('$passagers', style: const TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add, size: 16),
                  onPressed: () => onPassagersChanged(passagers + 1),
                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClasseField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: classe,
          items: ['Économique', 'Économique Flex', 'Business']
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (val) => onClasseChanged(val!),
          isExpanded: true,
        ),
      ),
    );
  }
}

// Pour utiliser showDatePicker, on a besoin d'un GlobalKey<NavigatorState>
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
