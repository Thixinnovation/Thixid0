// lib/presentation/thix_event/event_detail_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';  // ← AJOUTER CET IMPORT

import '../../providers/event_provider.dart';
import '../../models/event_model.dart';
import '../../services/event_seat_service.dart';
import '../../services/event_queue_service.dart';
import '../../services/event_booking_limit_service.dart';
import 'event_reservation_page.dart';
import 'seat_selection_page.dart';
import 'waiting_queue_page.dart';

// Définition temporaire de EventBookingLimit si la classe n'existe pas
class EventBookingLimit {
  final String eventId;
  final int maxPerPerson;
  final int maxPerTransaction;
  final bool requireIdVerification;
  final int? memberOnlyLimit;
  final List<String> restrictedZones;

  EventBookingLimit({
    required this.eventId,
    required this.maxPerPerson,
    required this.maxPerTransaction,
    this.requireIdVerification = false,
    this.memberOnlyLimit,
    this.restrictedZones = const [],
  });
}

class EventDetailPage extends StatefulWidget {
  final String eventId;
  const EventDetailPage({super.key, required this.eventId});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  late Event _event;
  bool _isLoading = true;
  bool _isFavorite = false;
  bool _hasSeatMap = false;
  int _availableSeats = 0;
  EventBookingLimit? _bookingLimit;
  bool _isCheckingQueue = false;

  @override
  void initState() {
    super.initState();
    _loadEvent();
  }

  Future<void> _loadEvent() async {
    final provider = context.read<EventProvider>();
    final event = await provider.fetchEventById(widget.eventId);
    if (event != null) {
      setState(() {
        _event = event;
        _isLoading = false;
        _isFavorite = event.isLiked;
      });
      await provider.incrementViews(widget.eventId);
      await _loadAdditionalInfo();
    }
  }

  Future<void> _loadAdditionalInfo() async {
    try {
      final seatService = EventSeatService(Supabase.instance.client);  // ✅ Correction
      final seats = await seatService.getSeatMap(widget.eventId);
      setState(() {
        _hasSeatMap = seats.isNotEmpty;
        _availableSeats = seats.where((s) => s.isAvailable).length;
      });
      
      final limitService = EventBookingLimitService(Supabase.instance.client);  // ✅ Correction
      final limit = await limitService.getBookingLimit(widget.eventId);
      if (limit != null) {
        setState(() {
          _bookingLimit = EventBookingLimit(
            eventId: limit.eventId,
            maxPerPerson: limit.maxPerPerson,
            maxPerTransaction: limit.maxPerTransaction,
            requireIdVerification: limit.requireIdVerification,
            memberOnlyLimit: limit.memberOnlyLimit,
            restrictedZones: limit.restrictedZones,
          );
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading additional info: $e');
    }
  }

  // ... reste du code identique
}
