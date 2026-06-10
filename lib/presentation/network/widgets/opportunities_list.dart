import 'package:flutter/material.dart';
import 'package:thix_id/models/opportunity.dart';

class OpportunitiesList extends StatelessWidget {
  final List<Opportunity> opportunities;
  final void Function(String) onOpportunityTap;
  final void Function(String) onApplyTap;

  const OpportunitiesList({
    super.key,
    required this.opportunities,
    required this.onOpportunityTap,
    required this.onApplyTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: opportunities.map((opp) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 2)],
          ),
          child: Row(
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.work_outline, color: Colors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(opp.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(opp.company, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => onApplyTap(opp.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: const Color(0xFF0B1B3D),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  minimumSize: const Size(80, 30),
                ),
                child: const Text('Postuler', style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
