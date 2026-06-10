// lib/presentation/thix_reservation/widgets/floating_reserve_button.dart
import 'package:flutter/material.dart';

class FloatingReserveButton extends StatelessWidget {
  final VoidCallback? onTap;

  const FloatingReserveButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      width: 54,
      margin: const EdgeInsets.only(top: 10),
      child: FloatingActionButton(
        backgroundColor: const Color(0xFF1A73E8),
        elevation: 3,
        shape: const CircleBorder(),
        onPressed: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.calendar_month, color: Colors.white, size: 18),
            SizedBox(height: 1),
            Text(
              "Réserver",
              style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
