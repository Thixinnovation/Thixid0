import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/health_consultation.dart';
import '../models/health_examen.dart';
import '../models/health_ordonnance.dart';
import '../models/health_article.dart';
import '../models/health_facility.dart';
import '../models/health_vaccin.dart';
import '../models/health_pregnancy.dart';

class HealthService {
  final SupabaseClient _supabase;

  HealthService([SupabaseClient? client]) : _supabase = client ?? Supabase.instance.client;

  String get currentUserId => _supabase.auth.currentUser?.id ?? '';

  // ==================== STATISTIQUES ====================

  Future<Map<String, dynamic>> getStats() async {
    try {
      final userId = currentUserId;
      
      final consultations = await _supabase
          .from('health_consultations')
          .select('id')
          .eq('user_id', userId);
      
      final examens = await _supabase
          .from('health_examens')
          .select('id')
          .eq('user_id', userId);
      
      final ordonnances = await _supabase
          .from('health_ordonnances')
          .select('id')
          .eq('user_id', userId)
          .gte('expires_at', DateTime.now().toIso8601String());
      
      final urgences = await _supabase
          .from('health_emergency_calls')
          .select('id')
          .eq('user_id', userId)
          .gte('created_at', DateTime.now().subtract(const Duration(days: 365)).toIso8601String());
      
      return {
        'consultations_count': (consultations as List).length,
        'examens_count': (examens as List).length,
        'ordonnances_count': (ordonnances as List).length,
        'urgences_count': (urgences as List).length,
      };
    } catch (e) {
      debugPrint('Error getting health stats: $e');
      return {
        'consultations_count': 0,
        'examens_count': 0,
        'ordonnances_count': 0,
        'urgences_count': 0,
      };
    }
  }

  // ==================== CONSULTATIONS ====================

  Future<List<HealthConsultation>> getConsultations() async {
    try {
      final userId = currentUserId;
      
      final response = await _supabase
          .from('health_consultations')
          .select('''
            *,
            doctors:doctor_id (
              id, name, specialty, avatar_url
            )
          ''')
          .eq('user_id', userId)
          .order('appointment_date', ascending: false);
      
      return (response as List).map((e) => HealthConsultation.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error getting consultations: $e');
      return [];
    }
  }

  Future<List<HealthConsultation>> getUpcomingConsultations() async {
    final all = await getConsultations();
    return all.where((c) => c.isUpcoming).toList();
  }

  Future<List<HealthConsultation>> getPastConsultations() async {
    final all = await getConsultations();
    return all.where((c) => c.isPast).toList();
  }

  Future<HealthConsultation?> getConsultationById(String id) async {
    try {
      final response = await _supabase
          .from('health_consultations')
          .select('''
            *,
            doctors:doctor_id (
              id, name, specialty, avatar_url
            )
          ''')
          .eq('id', id)
          .maybeSingle();
      
      return response != null ? HealthConsultation.fromJson(response) : null;
    } catch (e) {
      debugPrint('Error getting consultation: $e');
      return null;
    }
  }

  Future<void> createConsultation({
    required String doctorId,
    required DateTime appointmentDate,
    String? location,
    bool isVirtual = false,
    String? notes,
  }) async {
    try {
      final userId = currentUserId;
      
      await _supabase.from('health_consultations').insert({
        'user_id': userId,
        'doctor_id': doctorId,
        'appointment_date': appointmentDate.toIso8601String(),
        'location': location,
        'is_virtual': isVirtual,
        'status': 'pending',
        'notes': notes,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error creating consultation: $e');
      rethrow;
    }
  }

  Future<void> cancelConsultation(String id) async {
    try {
      await _supabase
          .from('health_consultations')
          .update({'status': 'cancelled'})
          .eq('id', id);
    } catch (e) {
      debugPrint('Error cancelling consultation: $e');
      rethrow;
    }
  }

  Future<void> confirmConsultation(String id) async {
    try {
      await _supabase
          .from('health_consultations')
          .update({'status': 'confirmed'})
          .eq('id', id);
    } catch (e) {
      debugPrint('Error confirming consultation: $e');
      rethrow;
    }
  }

  // ==================== EXAMENS ====================

  Future<List<HealthExamen>> getExamens() async {
    try {
      final userId = currentUserId;
      
      final response = await _supabase
          .from('health_examens')
          .select()
          .eq('user_id', userId)
          .order('exam_date', ascending: false);
      
      return (response as List).map((e) => HealthExamen.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error getting examens: $e');
      return [];
    }
  }

  Future<HealthExamen?> getExamenById(String id) async {
    try {
      final response = await _supabase
          .from('health_examens')
          .select()
          .eq('id', id)
          .maybeSingle();
      
      return response != null ? HealthExamen.fromJson(response) : null;
    } catch (e) {
      debugPrint('Error getting examen: $e');
      return null;
    }
  }

  // ==================== ORDONNANCES ====================

  Future<List<HealthOrdonnance>> getOrdonnances() async {
    try {
      final userId = currentUserId;
      
      final response = await _supabase
          .from('health_ordonnances')
          .select('''
            *,
            doctor:doctor_id (
              id, name, specialty
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return (response as List).map((e) => HealthOrdonnance.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error getting ordonnances: $e');
      return [];
    }
  }

  Future<HealthOrdonnance?> getOrdonnanceById(String id) async {
    try {
      final response = await _supabase
          .from('health_ordonnances')
          .select('''
            *,
            doctor:doctor_id (
              id, name, specialty
            )
          ''')
          .eq('id', id)
          .maybeSingle();
      
      return response != null ? HealthOrdonnance.fromJson(response) : null;
    } catch (e) {
      debugPrint('Error getting ordonnance: $e');
      return null;
    }
  }

  Future<void> renewOrdonnance(String id) async {
    try {
      await _supabase
          .from('health_ordonnances')
          .update({
            'created_at': DateTime.now().toIso8601String(),
            'expires_at': DateTime.now().add(const Duration(days: 365)).toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      debugPrint('Error renewing ordonnance: $e');
      rethrow;
    }
  }

  // ==================== ARTICLES ====================

  Future<List<HealthArticle>> getArticles({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('health_articles')
          .select()
          .eq('is_published', true)
          .order('created_at', ascending: false)
          .limit(limit);
      
      return (response as List).map((e) => HealthArticle.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error getting articles: $e');
      return [];
    }
  }

  Future<HealthArticle?> getArticleById(String id) async {
    try {
      final response = await _supabase
          .from('health_articles')
          .select()
          .eq('id', id)
          .maybeSingle();
      
      if (response != null) {
        await _supabase.rpc('increment_article_views', params: {'article_id': id});
        return HealthArticle.fromJson(response);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting article: $e');
      return null;
    }
  }

  // ==================== ÉTABLISSEMENTS ====================

  Future<List<HealthFacility>> getHospitals() async {
    try {
      final response = await _supabase
          .from('health_facilities')
          .select()
          .eq('type', 'hospital')
          .eq('is_active', true)
          .order('name');
      
      return (response as List).map((e) => HealthFacility.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error getting hospitals: $e');
      return [];
    }
  }

  Future<List<HealthFacility>> getPharmacies() async {
    try {
      final response = await _supabase
          .from('health_facilities')
          .select()
          .eq('type', 'pharmacy')
          .eq('is_active', true)
          .order('name');
      
      return (response as List).map((e) => HealthFacility.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error getting pharmacies: $e');
      return [];
    }
  }

  Future<List<HealthFacility>> getNearbyFacilities({
    required double lat,
    required double lng,
    String? type,
    double radius = 10,
  }) async {
    try {
      var query = _supabase.rpc('nearby_facilities', params: {
        'lat': lat,
        'lng': lng,
        'radius_km': radius,
      });
      
      if (type != null) {
        query = _supabase
            .from('health_facilities')
            .select()
            .eq('type', type)
            .eq('is_active', true);
      }
      
      final response = await query;
      return (response as List).map((e) => HealthFacility.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error getting nearby facilities: $e');
      return [];
    }
  }

  // ==================== VACCINS ====================

  Future<List<HealthVaccin>> getVaccins() async {
    try {
      final userId = currentUserId;
      
      final response = await _supabase
          .from('health_vaccins')
          .select()
          .eq('user_id', userId)
          .order('date_administered', ascending: false);
      
      return (response as List).map((e) => HealthVaccin.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error getting vaccins: $e');
      return [];
    }
  }

  Future<void> addVaccin({
    required String name,
    required DateTime dateAdministered,
    String? location,
    DateTime? nextDueDate,
    String? batchNumber,
    String? administeredBy,
  }) async {
    try {
      final userId = currentUserId;
      
      await _supabase.from('health_vaccins').insert({
        'user_id': userId,
        'name': name,
        'date_administered': dateAdministered.toIso8601String(),
        'location': location,
        'next_due_date': nextDueDate?.toIso8601String(),
        'batch_number': batchNumber,
        'administered_by': administeredBy,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error adding vaccin: $e');
      rethrow;
    }
  }

  // ==================== GROSSESSE ====================

  Future<HealthPregnancy?> getCurrentPregnancy() async {
    try {
      final userId = currentUserId;
      
      final response = await _supabase
          .from('health_pregnancies')
          .select()
          .eq('user_id', userId)
          .order('start_date', ascending: false)
          .limit(1)
          .maybeSingle();
      
      return response != null ? HealthPregnancy.fromJson(response) : null;
    } catch (e) {
      debugPrint('Error getting pregnancy: $e');
      return null;
    }
  }

  Future<void> startPregnancy({required DateTime startDate, DateTime? expectedDate}) async {
    try {
      final userId = currentUserId;
      
      await _supabase.from('health_pregnancies').insert({
        'user_id': userId,
        'start_date': startDate.toIso8601String(),
        'expected_date': expectedDate?.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error starting pregnancy: $e');
      rethrow;
    }
  }

  Future<void> updatePregnancy(String id, {String? notes}) async {
    try {
      await _supabase
          .from('health_pregnancies')
          .update({'notes': notes})
          .eq('id', id);
    } catch (e) {
      debugPrint('Error updating pregnancy: $e');
      rethrow;
    }
  }

  // ==================== MÉDECINS ====================

  Future<List<Map<String, dynamic>>> getDoctors({String? specialty}) async {
    try {
      var query = _supabase
          .from('profiles')
          .select('id, display_name, avatar_url, title, specialty, rating')
          .eq('is_doctor', true);
      
      if (specialty != null && specialty != 'Tous') {
        query = query.eq('specialty', specialty);
      }
      
      final response = await query;
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error getting doctors: $e');
      return [];
    }
  }

  // ==================== MÉDICAMENTS ====================

  Future<List<Map<String, dynamic>>> searchMedicaments(String query) async {
    try {
      final response = await _supabase
          .from('health_medicaments')
          .select()
          .ilike('name', '%$query%')
          .limit(20);
      
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error searching medicaments: $e');
      return [];
    }
  }
}
