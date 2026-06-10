// lib/presentation/thix_reservation/widgets/services_grid.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ServicesGrid extends StatelessWidget {
  final Function(String)? onServiceTap;

  const ServicesGrid({super.key, this.onServiceTap});

  @override
  Widget build(BuildContext context) {
    final services = [
      {'icon': Icons.directions_bus, 'label': 'Bus', 'color': const Color(0xFF1A73E8), 'route': '/reservation/bus'},
      {'icon': Icons.flight, 'label': 'Vol', 'color': Colors.indigo, 'route': '/reservation/vols'},
      {'icon': Icons.hotel, 'label': 'Hôtel', 'color': Colors.orange, 'route': '/reservation/hotels'},
      {'icon': Icons.local_taxi, 'label': 'Taxi', 'color': Colors.amber, 'route': '/reservation/taxi'},
      {'icon': Icons.delivery_dining, 'label': 'Livraison', 'color': Colors.green, 'route': '/reservation/colis'},
      {'icon': Icons.restaurant, 'label': 'Restaurant', 'color': Colors.red, 'route': '/reservation/restaurants'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: services.map((service) {
        return GestureDetector(
          onTap: () {
            if (onServiceTap != null) {
              onServiceTap!(service['route'] as String);
            } else {
              context.push(service['route'] as String);
            }
          },
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  service['icon'] as IconData,
                  color: service['color'] as Color,
                  size: 22,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                service['label'] as String,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
