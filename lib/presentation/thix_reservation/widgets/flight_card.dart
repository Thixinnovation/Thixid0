// lib/presentation/thix_reservation/widgets/flight_card.dart
import 'package:flutter/material.dart';
import '../../models/vol.dart';

class FlightCard extends StatelessWidget {
  final Vol vol;
  final VoidCallback onTap;

  const FlightCard({
    super.key,
    required this.vol,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
