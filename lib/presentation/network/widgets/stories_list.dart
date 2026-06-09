import 'package:flutter/material.dart';

class StoriesList extends StatelessWidget {
  const StoriesList({super.key});

  final List<Map<String, dynamic>> _stories = const [
    {'name': 'Votre Story', 'isCurrentUser': true, 'avatar': null},
    {'name': 'Jean Kouassi', 'title': 'CEO @ PayPal Solutions', 'time': '2h', 'avatar': null},
    {'name': 'Marie Konan', 'title': 'CTO @ TechCorp', 'time': '5h', 'avatar': null},
    {'name': 'Abdoul Diallo', 'title': 'Lead Dev @ FlutterAfrica', 'time': '1j', 'avatar': null},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Stories professionnelles',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _stories.length,
            itemBuilder: (context, index) {
              final story = _stories[index];
              final isCurrentUser = story['isCurrentUser'] as bool;
              
              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 12),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: isCurrentUser
                                ? null
                                : const LinearGradient(
                                    colors: [Color(0xFFD4AF37), Colors.orange],
                                  ),
                            border: isCurrentUser
                                ? Border.all(color: Colors.grey.shade300, width: 2)
                                : null,
                          ),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.grey.shade200,
                            child: Icon(
                              isCurrentUser ? Icons.add : Icons.person,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                        if (isCurrentUser)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFFD4AF37),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit, size: 16, color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      story['name'],
                      style: const TextStyle(fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!isCurrentUser)
                      Text(
                        story['time'],
                        style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
