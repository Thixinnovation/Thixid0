class HealthConsultation {
  final String id;
  final String userId;
  final String doctorId;
  final String doctorName;
  final String? doctorAvatar;
  final String? doctorSpecialty;
  final DateTime appointmentDate;
  final String? location;
  final bool isVirtual;
  final String status; // pending, confirmed, cancelled, completed
  final String? notes;
  final DateTime createdAt;

  HealthConsultation({
    required this.id,
    required this.userId,
    required this.doctorId,
    required this.doctorName,
    this.doctorAvatar,
    this.doctorSpecialty,
    required this.appointmentDate,
    this.location,
    required this.isVirtual,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  factory HealthConsultation.fromJson(Map<String, dynamic> json) {
    final doctor = json['doctors'] as Map<String, dynamic>?;
    
    return HealthConsultation(
      id: json['id'],
      userId: json['user_id'],
      doctorId: json['doctor_id'],
      doctorName: doctor?['name'] ?? json['doctor_name'] ?? 'Médecin',
      doctorAvatar: doctor?['avatar_url'] ?? json['doctor_avatar'],
      doctorSpecialty: doctor?['specialty'] ?? json['doctor_specialty'],
      appointmentDate: DateTime.parse(json['appointment_date']),
      location: json['location'],
      isVirtual: json['is_virtual'] ?? false,
      status: json['status'] ?? 'pending',
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'doctor_id': doctorId,
    'appointment_date': appointmentDate.toIso8601String(),
    'location': location,
    'is_virtual': isVirtual,
    'status': status,
    'notes': notes,
    'created_at': createdAt.toIso8601String(),
  };

  bool get isUpcoming => appointmentDate.isAfter(DateTime.now()) && status != 'cancelled';
  bool get isPast => appointmentDate.isBefore(DateTime.now());
  bool get isConfirmed => status == 'confirmed';
  bool get isCancelled => status == 'cancelled';
  bool get isCompleted => status == 'completed';
  
  String get formattedDate => '${appointmentDate.day}/${appointmentDate.month}/${appointmentDate.year}';
  String get formattedTime => '${appointmentDate.hour}:${appointmentDate.minute.toString().padLeft(2, '0')}';
  String get formattedDateTime => '$formattedDate à $formattedTime';
}
