import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ConsultationMedecinPage extends StatefulWidget {
  final String? doctorId;
  const ConsultationMedecinPage({super.key, this.doctorId});

  @override
  State<ConsultationMedecinPage> createState() => _ConsultationMedecinPageState();
}

class _ConsultationMedecinPageState extends State<ConsultationMedecinPage> {
  List<Map<String, dynamic>> _doctors = [];
  bool _loading = true;
  String _selectedSpecialty = 'Tous';

  final List<String> _specialties = ['Tous', 'Généraliste', 'Pédiatre', 'Cardiologue', 'Dermatologue', 'Gynécologue', 'Psychologue'];

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() => _loading = true);
    try {
      final supabase = Supabase.instance.client;
      var query = supabase.from('profiles').select('id, display_name, avatar_url, title, specialty').eq('is_doctor', true);

      if (_selectedSpecialty != 'Tous') {
        query = query.eq('specialty', _selectedSpecialty);
      }

      final response = await query;
      setState(() {
        _doctors = (response as List).cast<Map<String, dynamic>>();
      });
    } catch (e) {
      debugPrint('Error loading doctors: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Consulter un médecin', style: TextStyle(color: Color(0xFF0B1B3D), fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildSpecialtyFilter(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _doctors.isEmpty
                    ? const Center(child: Text('Aucun médecin trouvé'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _doctors.length,
                        itemBuilder: (context, index) => _buildDoctorCard(_doctors[index]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Rechercher un médecin...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
        ),
        onChanged: (value) => _loadDoctors(),
      ),
    );
  }

  Widget _buildSpecialtyFilter() {
    return Container(
      height: 50,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _specialties.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(right: 12),
          child: FilterChip(
            label: Text(_specialties[index]),
            selected: _selectedSpecialty == _specialties[index],
            onSelected: (_) {
              setState(() => _selectedSpecialty = _specialties[index]);
              _loadDoctors();
            },
            backgroundColor: Colors.grey.shade100,
            selectedColor: const Color(0xFFD4AF37),
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: doctor['avatar_url'] != null ? NetworkImage(doctor['avatar_url']) : null,
            child: doctor['avatar_url'] == null ? const Icon(Icons.person, size: 30) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctor['display_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(doctor['specialty'] ?? doctor['title'] ?? 'Médecin généraliste', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Color(0xFFD4AF37)),
                    const SizedBox(width: 4),
                    Text('4.8', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    const Icon(Icons.people, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('125 consultations', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showBookingDialog(doctor),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: const Color(0xFF0B1B3D),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Prendre RDV'),
          ),
        ],
      ),
    );
  }

  void _showBookingDialog(Map<String, dynamic> doctor) {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Prendre rendez-vous', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Date'),
                trailing: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (date != null) setModalState(() => selectedDate = date);
                },
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Heure'),
                trailing: Text(selectedTime.format(context)),
                onTap: () async {
                  final time = await showTimePicker(context: context, initialTime: selectedTime);
                  if (time != null) setModalState(() => selectedTime = time);
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Demande envoyée au médecin'), backgroundColor: Colors.green),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), minimumSize: const Size(double.infinity, 50)),
                child: const Text('CONFIRMER'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
