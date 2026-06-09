class HealthPregnancy {
  final String id;
  final String userId;
  final DateTime startDate;
  final DateTime? expectedDate;
  final int? currentWeek;
  final String? notes;
  final DateTime createdAt;

  HealthPregnancy({
    required this.id,
    required this.userId,
    required this.startDate,
    this.expectedDate,
    this.currentWeek,
    this.notes,
    required this.createdAt,
  });

  factory HealthPregnancy.fromJson(Map<String, dynamic> json) {
    final startDate = DateTime.parse(json['start_date']);
    final currentWeek = json['current_week'] ?? DateTime.now().difference(startDate).inDays ~/ 7;
    
    return HealthPregnancy(
      id: json['id'],
      userId: json['user_id'],
      startDate: startDate,
      expectedDate: json['expected_date'] != null ? DateTime.parse(json['expected_date']) : null,
      currentWeek: currentWeek,
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'start_date': startDate.toIso8601String(),
    'expected_date': expectedDate?.toIso8601String(),
    'current_week': currentWeek,
    'notes': notes,
    'created_at': createdAt.toIso8601String(),
  };

  int get weeksLeft => expectedDate != null ? expectedDate!.difference(DateTime.now()).inDays ~/ 7 : 40 - (currentWeek ?? 0);
  double get babySize => (currentWeek ?? 0) * 1.5;
  double get babyWeight => (currentWeek ?? 0) * 50;
  String get trimester => (currentWeek ?? 0) <= 12 ? '1er trimestre' : ((currentWeek ?? 0) <= 27 ? '2ème trimestre' : '3ème trimestre');
}
