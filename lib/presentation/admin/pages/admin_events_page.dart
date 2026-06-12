
// lib/services/event_booking_limit_service.dart

// ✅ CORRECTION : Méthode isSuspiciousActivity
Future<bool> isSuspiciousActivity(String eventId) async {
  final userId = currentUserId;
  if (userId.isEmpty) return false;

  try {
    // Compter les tentatives dans les dernières minutes
    final fiveMinutesAgo = DateTime.now().subtract(const Duration(minutes: 5));
    
    final response = await _supabase
        .from('event_booking_attempts')
        .select('id')
        .eq('event_id', eventId)
        .eq('user_id', userId)
        .gte('attempted_at', fiveMinutesAgo.toIso8601String());
    
    // ✅ CORRECTION : Compter manuellement en Dart
    final count = (response as List).length;
    return count > 10;
  } catch (e) {
    debugPrint('❌ Error isSuspiciousActivity: $e');
    return false;
  }
}
