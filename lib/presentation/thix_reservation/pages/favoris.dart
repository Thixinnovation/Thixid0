// lib/presentation/thix_reservation/pages/favoris.dart
import 'package:flutter/material.dart';

class FavorisPage extends StatefulWidget {
  const FavorisPage({super.key});

  @override
  State<FavorisPage> createState() => _FavorisPageState();
}

class _FavorisPageState extends State<FavorisPage> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Mes favoris'),
        backgroundColor: const Color(0xFF0B1B3D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildTabs(),
          Expanded(
            child: IndexedStack(
              index: _selectedTab,
              children: const [
                _DestinationsFav(),
                _ChauffeursFav(),
                _AdressesFav(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    final tabs = ['Destinations', 'Chauffeurs', 'Adresses'];
    return Container(
      color: Colors.white,
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final int index = entry.key;
          final String label = entry.value;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _selectedTab == index ? const Color(0xFFD4AF37) : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _selectedTab == index ? const Color(0xFFD4AF37) : Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DestinationsFav extends StatelessWidget {
  const _DestinationsFav();

  @override
  Widget build(BuildContext context) {
    final destinations = [
      {'ville': 'Paris', 'pays': 'France', 'prix': '650 USD'},
      {'ville': 'Dubai', 'pays': 'UAE', 'prix': '580 USD'},
      {'ville': 'Casablanca', 'pays': 'Maroc', 'prix': '420 USD'},
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: destinations.length,
      itemBuilder: (context, index) {
        final dest = destinations[index];
        final String ville = dest['ville'] as String;
        final String pays = dest['pays'] as String;
        final String prix = dest['prix'] as String;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.location_city, color: Color(0xFFD4AF37)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ville, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(pays, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              Text(prix, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
              IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: () {},
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChauffeursFav extends StatelessWidget {
  const _ChauffeursFav();

  @override
  Widget build(BuildContext context) {
    final chauffeurs = [
      {'nom': 'Jean K.', 'note': '4.9', 'trajets': 245, 'photo': 'JK'},
      {'nom': 'Marie L.', 'note': '4.8', 'trajets': 189, 'photo': 'ML'},
      {'nom': 'Paul D.', 'note': '4.7', 'trajets': 156, 'photo': 'PD'},
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: chauffeurs.length,
      itemBuilder: (context, index) {
        final chauffeur = chauffeurs[index];
        final String nom = chauffeur['nom'] as String;
        final String note = chauffeur['note'] as String;
        final int trajets = chauffeur['trajets'] as int;
        final String photo = chauffeur['photo'] as String;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFD4AF37).withOpacity(0.1),
                child: Text(photo),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nom, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 12, color: Colors.amber),
                        Text(' $note • $trajets trajets', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: () {},
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AdressesFav extends StatelessWidget {
  const _AdressesFav();

  @override
  Widget build(BuildContext context) {
    final adresses = [
      {'label': 'Maison', 'adresse': 'Abidjan, Cocody', 'icon': Icons.home},
      {'label': 'Travail', 'adresse': 'Abidjan, Plateau', 'icon': Icons.work},
      {'label': 'Aeroport', 'adresse': 'Abidjan, Aeroport FHB', 'icon': Icons.flight},
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: adresses.length,
      itemBuilder: (context, index) {
        final adresse = adresses[index];
        final String label = adresse['label'] as String;
        final String adr = adresse['adresse'] as String;
        final IconData icon = adresse['icon'] as IconData;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFFD4AF37)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(adr, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: () {},
              ),
            ],
          ),
        );
      },
    );
  }
}
