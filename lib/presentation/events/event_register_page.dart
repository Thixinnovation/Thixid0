import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/event_item.dart';
import '../../services/event_service.dart';

class EventRegisterPage extends StatefulWidget {
  final String eventId;  // ← CHANGÉ : eventId au lieu de event

  const EventRegisterPage({
    super.key,
    required this.eventId,  // ← CHANGÉ
  });

  @override
  State<EventRegisterPage> createState() => _EventRegisterPageState();
}

class _EventRegisterPageState extends State<EventRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _thixIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _noteController = TextEditingController();

  bool _loading = false;
  bool _loadingEvent = true;
  int _tickets = 1;
  EventItem? _event;

  late final EventService _eventService = EventService();

  @override
  void initState() {
    super.initState();
    _loadEvent();
  }

  Future<void> _loadEvent() async {
    setState(() => _loadingEvent = true);
    try {
      final event = await _fetchEventById(widget.eventId);
      setState(() => _event = event);
    } catch (e) {
      debugPrint('Error loading event: $e');
    } finally {
      setState(() => _loadingEvent = false);
    }
  }

  Future<EventItem?> _fetchEventById(String eventId) async {
    try {
      final response = await Supabase.instance.client
          .from('events')
          .select()
          .eq('id', eventId)
          .single();
      
      return EventItem(
        id: response['id'],
        title: response['title'],
        description: response['description'] ?? '',
        category: response['category'] ?? 'Autre',
        location: response['location'] ?? '',
        startsAt: DateTime.parse(response['starts_at']),
        endsAt: DateTime.parse(response['ends_at']),
        price: (response['price'] as num?)?.toDouble() ?? 0,
        isRecommended: response['is_recommended'] ?? false,
        isPublished: response['is_published'] ?? true,
        maxParticipants: response['max_participants'] ?? 0,
        registeredParticipants: response['registered_participants'] ?? 0,
        createdAt: DateTime.parse(response['created_at']),
      );
    } catch (e) {
      debugPrint('Error fetching event: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _thixIdController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  double get _totalPrice => (_event?.price ?? 0) * _tickets;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_event == null) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez vous connecter')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final success = await _eventService.registerForEvent(
        userId: user.id,
        eventId: widget.eventId,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Réservation réussie !'), backgroundColor: Colors.green),
        );
        context.go('/events/me');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingEvent) {
      return const Scaffold(
        appBar: AppBar(title: Text('Réservation')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_event == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Réservation')),
        body: const Center(child: Text('Événement non trouvé')),
      );
    }

    final event = _event!;

    return Scaffold(
      appBar: AppBar(title: const Text('Réservation')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(event.location),
                      Text(event.priceLabel, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // ... (reste de ton formulaire)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
