// lib/presentation/thix_reservation/widgets/flight_filter_chips.dart
import 'package:flutter/material.dart';

class FlightFilterChips extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterSelected;

  const FlightFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      {'label': 'Meilleur choix', 'value': 'best'},
      {'label': 'Prix croissant', 'value': 'price_asc'},
      {'label': 'Prix décroissant', 'value': 'price_desc'},
      {'label': 'Durée', 'value': 'duration'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: filters.map((filter) {
          return FilterChip(
            label: Text(filter['label']!, style: const TextStyle(fontSize: 12)),
            selected: selectedFilter == filter['value'],
            onSelected: (_) => onFilterSelected(filter['value']!),
            selectedColor: const Color(0xFFD4AF37).withOpacity(0.2),
          );
        }).toList(),
      ),
    );
  }
}
