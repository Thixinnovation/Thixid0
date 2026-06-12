// lib/services/event_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:math';

import '../models/event_model.dart';

class EventService {
  final SupabaseClient _supabase;

  EventService(this._supabase);

  String get currentUserId => _supabase.auth.currentUser?.id ?? '';

  // ============================================================
  // LECTURE DES ÉVÉNEMENTS
  // ============================================================

  Future<List<Event>> getEvents({
    String? category,
    String? dateFilter,
    String? city,
    int limit = 50,
  }) async {
    try {
      final response = await _supabase.from('events').select('*');
      
      List<dynamic> results = response as List;
      
      // Filtre par catégorie
      if (category != null && category != 'all') {
        results = results.where((e) => e['category'] == category).toList();
      }
      
      // Filtre par date
      final now = DateTime.now();
      if (dateFilter == 'today') {
        results = results.where((e) => 
          DateTime.parse(e['start_date']).day == now.day &&
          DateTime.parse(e['start_date']).month == now.month &&
          DateTime.parse(e['start_date']).year == now.year
        ).toList();
      } else if (dateFilter == 'week') {
        final weekLater = now.add(const Duration(days: 7));
        results = results.where((e) => 
          DateTime.parse(e['start_date']).isAfter(now) &&
          DateTime.parse(e['start_date']).isBefore(weekLater)
        ).toList();
      } else if (dateFilter == 'month') {
        results = results.where((e) => 
          DateTime.parse(e['start_date']).month == now.month &&
          DateTime.parse(e['start_date']).year == now.year
        ).toList();
      } else {
        // Par défaut : événements à venir
        results = results.where((e) => 
          DateTime.parse(e['start_date']).isAfter(now) && e['status'] == 'upcoming'
        ).toList();
      }
      
      // Filtre par ville
      if (city != null && city != 'all') {
        results = results.where((e) => e['city'] == city).toList();
      }
      
      // Tri par date
      results.sort((a, b) => DateTime.parse(a['start_date']).compareTo(DateTime.parse(b['start_date'])));
      
      // Limite
      results = results.take(limit).toList();
      
      final events = <Event>[];
      for (var e in results) {
        final isLiked = await _isEventLiked(e['id']);
        final isSaved = await _isEventSaved(e['id']);
        
        events.add(Event.fromJson({
          ...e,
          'is_liked': isLiked,
          'is_saved': isSaved,
        }));
      }
      
      return events;
    } catch (e) {
      debugPrint('❌ Error getEvents: $e');
      return [];
    }
  }

  Future<Event?> getEventById(String eventId) async {
    try {
      final response = await _supabase
          .from('events')
          .select('*')
          .eq('id', eventId)
          .maybeSingle();

      if (response == null) return null;

      final isLiked = await _isEventLiked(eventId);
      final isSaved = await _isEventSaved(eventId);

      return Event.fromJson({
        ...response,
        'is_liked': isLiked,
        'is_saved': isSaved,
      });
    } catch (e) {
      debugPrint('❌ Error getEventById: $e');
      return null;
    }
  }

  Future<List<Event>> getFeaturedEvents() async {
    try {
      final response = await _supabase.from('events').select('*');
      
      List<dynamic> results = response as List;
      results = results.where((e) => 
        e['is_featured'] == true && 
        e['status'] == 'upcoming' &&
        DateTime.parse(e['start_date']).isAfter(DateTime.now())
      ).toList();
      
      results.sort((a, b) => DateTime.parse(a['start_date']).compareTo(DateTime.parse(b['start_date'])));
      
      final events = <Event>[];
      for (var e in results) {
        final isLiked = await _isEventLiked(e['id']);
        events.add(Event.fromJson({
          ...e,
          'is_liked': isLiked,
        }));
      }
      
      return events;
    } catch (e) {
      debugPrint('❌ Error getFeaturedEvents: $e');
      return [];
    }
  }

  Future<List<Event>> getEventsByCategory(String category) async {
    try {
      final response = await _supabase.from('events').select('*');
      
      List<dynamic> results = response as List;
      results = results.where((e) => 
        e['category'] == category && 
        e['status'] == 'upcoming' &&
        DateTime.parse(e['start_date']).isAfter(DateTime.now())
      ).toList();
      
      results.sort((a, b) => DateTime.parse(a['start_date']).compareTo(DateTime.parse(b['start_date'])));
      
      final events = <Event>[];
      for (var e in results) {
        final isLiked = await _isEventLiked(e['id']);
        events.add(Event.fromJson({
          ...e,
          'is_liked': isLiked,
        }));
      }
      
      return events;
    } catch (e) {
      debugPrint('❌ Error getEventsByCategory: $e');
      return [];
    }
  }

  Future<List<Event>> searchEvents(String query) async {
    try {
      final response = await _supabase.from('events').select('*');
      
      List<dynamic> results = response as List;
      final searchLower = query.toLowerCase();
      
      results = results.where((e) => 
        e['status'] == 'upcoming' && (
          e['title'].toString().toLowerCase().contains(searchLower) ||
          e['description'].toString().toLowerCase().contains(searchLower) ||
          e['location'].toString().toLowerCase().contains(searchLower) ||
          (e['organizer_name'] ?? '').toString().toLowerCase().contains(searchLower)
        )
      ).toList();
      
      results.sort((a, b) => DateTime.parse(a['start_date']).compareTo(DateTime.parse(b['start_date'])));
      
      final events = <Event>[];
      for (var e in results) {
        events.add(Event.fromJson(e));
      }
      
      return events;
    } catch (e) {
      debugPrint('❌ Error searchEvents: $e');
      return [];
    }
  }

  // ============================================================
  // INTERACTIONS (Likes, Vues, Favoris)
  // ============================================================

  Future<void> incrementViews(String eventId) async {
    try {
      final event = await _supabase
          .from('events')
          .select('views_count')
          .eq('id', eventId)
          .maybeSingle();
      
      if (event == null) return;
      
      final currentViews = event['views_count'] ?? 0;
      await _supabase
          .from('events')
          .update({'views_count': currentViews + 1})
          .eq('id', eventId);
    } catch (e) {
      debugPrint('❌ Error incrementViews: $e');
    }
  }

  Future<bool> _isEventLiked(String eventId) async {
    final currentUserId = this.currentUserId;
    if (currentUserId.isEmpty) return false;

    try {
      final response = await _supabase
          .from('event_favorites')
          .select('id')
          .eq('event_id', eventId)
          .eq('user_id', currentUserId)
          .maybeSingle();
      return response != null;
    } catch (e) {
      return false;
    }
  }

  Future<void> likeEvent(String eventId) async {
    final currentUserId = this.currentUserId;
    if (currentUserId.isEmpty) return;

    final exists = await _isEventLiked(eventId);
    if (!exists) {
      await _supabase.from('event_favorites').insert({
        'event_id': eventId,
        'user_id': currentUserId,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> unlikeEvent(String eventId) async {
    final currentUserId = this.currentUserId;
    if (currentUserId.isEmpty) return;

    await _supabase
        .from('event_favorites')
        .delete()
        .eq('event_id', eventId)
        .eq('user_id', currentUserId);
  }

  Future<bool> _isEventSaved(String eventId) async {
    final currentUserId = this.currentUserId;
    if (currentUserId.isEmpty) return false;

    try {
      final response = await _supabase
          .from('event_favorites')
          .select('id')
          .eq('event_id', eventId)
          .eq('user_id', currentUserId)
          .maybeSingle();
      return response != null;
    } catch (e) {
      return false;
    }
  }

  Future<List<Event>> getFavoriteEvents() async {
    final currentUserId = this.currentUserId;
    if (currentUserId.isEmpty) return [];

    try {
      final response = await _supabase
          .from('event_favorites')
          .select('event:event_id(*)')
          .eq('user_id', currentUserId)
          .order('created_at', ascending: false);

      final events = <Event>[];
      for (var e in response as List) {
        events.add(Event.fromJson({
          ...e['event'],
          'is_liked': true,
        }));
      }
      return events;
    } catch (e) {
      debugPrint('❌ Error getFavoriteEvents: $e');
      return [];
    }
  }

  // ============================================================
  // RÉSERVATION
  // ============================================================

  Future<EventBooking?> bookTicket({
    required String eventId,
    required int quantity,
    required double totalPrice,
    String? paymentMethod,
  }) async {
    final currentUserId = this.currentUserId;
    if (currentUserId.isEmpty) throw Exception('Utilisateur non connecté');

    try {
      final ticketCode = _generateTicketCode();
      
      final response = await _supabase.from('event_bookings').insert({
        'event_id': eventId,
        'user_id': currentUserId,
        'ticket_quantity': quantity,
        'total_price': totalPrice,
        'payment_method': paymentMethod,
        'payment_status': 'paid',
        'ticket_code': ticketCode,
        'qr_code': ticketCode,
        'status': 'confirmed',
        'booking_date': DateTime.now().toIso8601String(),
      }).select().single();
      
      // Mettre à jour les places restantes
      final event = await getEventById(eventId);
      if (event != null && event.remainingTickets != null) {
        await _supabase
            .from('events')
            .update({'remaining_tickets': event.remainingTickets! - quantity})
            .eq('id', eventId);
      }
      
      return EventBooking.fromJson(response);
    } catch (e) {
      debugPrint('❌ Error bookTicket: $e');
      return null;
    }
  }

  Future<List<EventBooking>> getMyTickets() async {
    final currentUserId = this.currentUserId;
    if (currentUserId.isEmpty) return [];

    try {
      final response = await _supabase
          .from('event_bookings')
          .select('*, events:event_id(title, image_url, start_date, location)')
          .eq('user_id', currentUserId)
          .order('booking_date', ascending: false);

      final bookings = <EventBooking>[];
      for (var e in response as List) {
        final event = e['events'];
        bookings.add(EventBooking.fromJson({
          ...e,
          'event_title': event['title'],
          'event_image_url': event['image_url'],
          'event_date': event['start_date'],
          'event_location': event['location'],
        }));
      }
      return bookings;
    } catch (e) {
      debugPrint('❌ Error getMyTickets: $e');
      return [];
    }
  }

  String _generateTicketCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return 'THIX-' + String.fromCharCodes(
      Iterable.generate(12, (_) => chars.codeUnitAt(random.nextInt(chars.length)))
    );
  }

  // ============================================================
  // ADMIN - CRUD
  // ============================================================

  Future<Event> createEvent({
    required String title,
    required String description,
    required String category,
    required DateTime startDate,
    required String location,
    double price = 0,
    bool isFree = false,
    int? capacity,
    String? imageUrl,
    String? city,
    String? address,
    bool isFeatured = false,
  }) async {
    final currentUserId = this.currentUserId;
    if (currentUserId.isEmpty) throw Exception('Admin non connecté');

    final response = await _supabase.from('events').insert({
      'title': title,
      'description': description,
      'category': category,
      'start_date': startDate.toIso8601String(),
      'location': location,
      'city': city,
      'address': address,
      'price': price,
      'is_free': isFree,
      'capacity': capacity,
      'remaining_tickets': capacity,
      'image_url': imageUrl,
      'is_featured': isFeatured,
      'status': 'upcoming',
      'organizer_id': currentUserId,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }).select().single();

    return Event.fromJson(response);
  }

  Future<void> updateEvent(String eventId, Map<String, dynamic> data) async {
    final currentUserId = this.currentUserId;
    if (currentUserId.isEmpty) throw Exception('Admin non connecté');

    await _supabase
        .from('events')
        .update({
          ...data,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', eventId);
  }

  Future<void> deleteEvent(String eventId) async {
    final currentUserId = this.currentUserId;
    if (currentUserId.isEmpty) throw Exception('Admin non connecté');

    await _supabase.from('events').delete().eq('id', eventId);
  }

  // ============================================================
  // UPLOAD
  // ============================================================

  Future<String?> uploadImage(String filePath) async {
    try {
      final currentUserId = this.currentUserId;
      if (currentUserId.isEmpty) return null;

      final file = File(filePath);
      final bytes = await file.readAsBytes();
      
      final extension = filePath.split('.').last;
      final fileName = 'event_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final storagePath = 'events/$fileName';
      
      await _supabase.storage
          .from('event_images')
          .uploadBinary(storagePath, bytes);
      
      return _supabase.storage.from('event_images').getPublicUrl(storagePath);
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  // ============================================================
  // STATISTIQUES
  // ============================================================

  // lib/services/event_service.dart

Future<Map<String, dynamic>> getAdminStats() async {
  try {
    final response = await _supabase.from('events').select('*');
    final List<dynamic> events = response as List;
    
    final totalEvents = events.length;
    final upcomingEvents = events.where((e) => 
      e['status'] == 'upcoming' && DateTime.parse(e['start_date']).isAfter(DateTime.now())
    ).length;
    
    // ✅ CORRECTION : Utiliser les types corrects
    int totalViews = 0;
    int totalLikes = 0;
    for (var e in events) {
      totalViews += e['views_count'] as int? ?? 0;
      totalLikes += e['likes_count'] as int? ?? 0;
    }
    
    return {
      'total_events': totalEvents,
      'upcoming_events': upcomingEvents,
      'total_views': totalViews,
      'total_likes': totalLikes,
    };
  } catch (e) {
    debugPrint('❌ Error getAdminStats: $e');
    return {};
  }
}
