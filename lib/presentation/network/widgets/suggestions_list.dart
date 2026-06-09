import 'package:flutter/material.dart';
import 'package:thix_id/models/network_connection.dart';

class SuggestionsList extends StatelessWidget {
  final List<NetworkConnection> suggestions;
  final Function(String) onConnect;

  const SuggestionsList({
    super.key,
    required this.suggestions,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final connection = suggestions[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: connection.avatar != null
                    ? NetworkImage(connection.avatar!)
                    : null,
                child: connection.avatar == null
                    ? const Icon(Icons.person, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      connection.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      connection.title,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '${connection.mutualConnections} connexions communes',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () => onConnect(connection.id),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFD4AF37)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Se connecter',
                  style: TextStyle(fontSize: 11, color: Color(0xFFD4AF37)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
