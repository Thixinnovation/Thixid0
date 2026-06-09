import 'package:flutter/material.dart';

class HealthVaccineCard extends StatelessWidget {
  final String name;
  final DateTime dateAdministered;
  final String? location;
  final DateTime? nextDueDate;
  final VoidCallback? onTap;

  const HealthVaccineCard({
    super.key,
    required this.name,
    required this.dateAdministered,
    this.location,
    this.nextDueDate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasNext = nextDueDate != null;
    final daysLeft = hasNext ? nextDueDate!.difference(DateTime.now()).inDays : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.vaccines, color: Colors.green),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Administré le ${dateAdministered.day}/${dateAdministered.month}/${dateAdministered.year}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  if (location != null)
                    Text(
                      location!,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
            ),
            if (hasNext)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: daysLeft! <= 30 ? Colors.orange.shade50 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  daysLeft <= 30 ? 'Prochain dans $daysLeft j' : 'À jour',
                  style: TextStyle(
                    fontSize: 10,
                    color: daysLeft <= 30 ? Colors.orange : Colors.grey,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
