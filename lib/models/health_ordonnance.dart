class HealthOrdonnance {
  final String id;
  final String userId;
  final String doctorId;
  final String doctorName;
  final String? doctorSpecialty;
  final List<HealthMedicament> medicaments;
  final String? instructions;
  final DateTime createdAt;
  final DateTime? expiresAt;

  HealthOrdonnance({
    required this.id,
    required this.userId,
    required this.doctorId,
    required this.doctorName,
    this.doctorSpecialty,
    required this.medicaments,
    this.instructions,
    required this.createdAt,
    this.expiresAt,
  });

  factory HealthOrdonnance.fromJson(Map<String, dynamic> json) {
    final doctor = json['doctor'] as Map<String, dynamic>?;
    final medicamentsList = json['medicaments'] as List? ?? [];
    
    return HealthOrdonnance(
      id: json['id'],
      userId: json['user_id'],
      doctorId: json['doctor_id'],
      doctorName: doctor?['name'] ?? json['doctor_name'] ?? 'Médecin',
      doctorSpecialty: doctor?['specialty'],
      medicaments: medicamentsList.map((m) => HealthMedicament.fromJson(m as Map<String, dynamic>)).toList(),
      instructions: json['instructions'],
      createdAt: DateTime.parse(json['created_at']),
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'doctor_id': doctorId,
    'medicaments': medicaments.map((m) => m.toJson()).toList(),
    'instructions': instructions,
    'created_at': createdAt.toIso8601String(),
    'expires_at': expiresAt?.toIso8601String(),
  };

  bool get isActive => expiresAt == null || expiresAt!.isAfter(DateTime.now());
  bool get isExpired => expiresAt != null && expiresAt!.isBefore(DateTime.now());
  String get formattedDate => '${createdAt.day}/${createdAt.month}/${createdAt.year}';
}

class HealthMedicament {
  final String name;
  final String dosage;
  final String? duration;
  final String? instructions;

  HealthMedicament({
    required this.name,
    required this.dosage,
    this.duration,
    this.instructions,
  });

  factory HealthMedicament.fromJson(Map<String, dynamic> json) {
    return HealthMedicament(
      name: json['name'],
      dosage: json['dosage'],
      duration: json['duration'],
      instructions: json['instructions'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'dosage': dosage,
    'duration': duration,
    'instructions': instructions,
  };
}
