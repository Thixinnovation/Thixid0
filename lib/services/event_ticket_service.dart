// lib/services/event_ticket_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';

import '../models/event_model.dart';

class EventTicketService {
  final SupabaseClient _supabase;

  EventTicketService(this._supabase);

  String get currentUserId => _supabase.auth.currentUser?.id ?? '';

  // ============================================================
  // VALIDATION DE BILLET
  // ============================================================

  Future<Map<String, dynamic>?> validateTicket(String ticketCode) async {
    try {
      final response = await _supabase
          .from('event_bookings')
          .select('*, events:event_id(*)')
          .eq('ticket_code', ticketCode)
          .maybeSingle();

      if (response == null) return null;
      
      return {
        'valid': response['status'] == 'confirmed',
        'ticket': response,
        'event': response['events'],
      };
    } catch (e) {
      debugPrint('❌ Error validateTicket: $e');
      return null;
    }
  }

  Future<bool> markTicketAsUsed(String ticketCode) async {
    try {
      await _supabase
          .from('event_bookings')
          .update({
            'status': 'used',
            'used_at': DateTime.now().toIso8601String(),
          })
          .eq('ticket_code', ticketCode);
      return true;
    } catch (e) {
      debugPrint('❌ Error markTicketAsUsed: $e');
      return false;
    }
  }

  // ============================================================
  // ANNULATION DE BILLET
  // ============================================================

  Future<bool> cancelTicket(String bookingId) async {
    try {
      // Récupérer le billet
      final booking = await _supabase
          .from('event_bookings')
          .select('event_id, ticket_quantity')
          .eq('id', bookingId)
          .single();
      
      // Annuler le billet
      await _supabase
          .from('event_bookings')
          .update({
            'status': 'cancelled',
          })
          .eq('id', bookingId);
      
      // Remettre les places disponibles
      final event = await _supabase
          .from('events')
          .select('remaining_tickets')
          .eq('id', booking['event_id'])
          .single();
      
      final currentRemaining = event['remaining_tickets'] ?? 0;
      await _supabase
          .from('events')
          .update({'remaining_tickets': currentRemaining + (booking['ticket_quantity'] as int)})
          .eq('id', booking['event_id']);
      
      return true;
    } catch (e) {
      debugPrint('❌ Error cancelTicket: $e');
      return false;
    }
  }

  // ============================================================
  // STATISTIQUES DES VENTES
  // ============================================================

  Future<Map<String, dynamic>> getSalesStats(String eventId) async {
    try {
      final response = await _supabase
          .from('event_bookings')
          .select('*')
          .eq('event_id', eventId);
      
      final List<dynamic> bookings = response as List;
      
      final totalSold = bookings.length;
      final totalRevenue = bookings.fold<double>(0, (sum, b) => sum + (b['total_price'] as double));
      final ticketsSold = bookings.fold<int>(0, (sum, b) => sum + (b['ticket_quantity'] as int));
      
      return {
        'total_bookings': totalSold,
        'total_revenue': totalRevenue,
        'tickets_sold': ticketsSold,
      };
    } catch (e) {
      debugPrint('❌ Error getSalesStats: $e');
      return {};
    }
  }

  // ============================================================
  // GÉNÉRATION QR CODE
  // ============================================================

  String generateQRData(String ticketCode, String eventId) {
    return 'THIX:${ticketCode}:${eventId}:${DateTime.now().millisecondsSinceEpoch}';
  }

  bool verifyQRData(String qrData, String expectedTicketCode) {
    try {
      final parts = qrData.split(':');
      if (parts.length < 3) return false;
      return parts[1] == expectedTicketCode;
    } catch (e) {
      return false;
    }
  }
}
