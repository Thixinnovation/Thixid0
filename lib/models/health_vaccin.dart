class HealthVaccin {
  final String id;
  final String userId;
  final String name;
  final DateTime dateAdministered;
  final String? location;
  final DateTime? nextDueDate;
  final String? batchNumber;
  final String? administeredBy;
  final DateTime createdAt;

  HealthVaccin({
    required this.id,
    required this.userId,
    required this.name,
    required this.dateAdministered,
    this.location,
    this.nextDueDate,
    this.batchNumber,
    this.administeredBy,
    required this.createdAt,
  });

  factory HealthVaccin.fromJson(Map<String, dynamic> json) {
    return HealthVaccin(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      dateAdministered: DateTime.parse(json['date_administered']),
      location: json['location'],
      nextDueDate: json['next_due_date'] != null ? DateTime.parse(json['next_due_date']) : null,
      batchNumber: json['batch_number'],
      administeredBy: json['administered_by'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'name': name,
    'date_administered': dateAdministered.toIso8601String(),
    'location': location,
    'next_due_date': nextDueDate?.toIso8601String(),
    'batch_number': batchNumber,
    'administered_by': administeredBy,
    'created_at': createdAt.toIso8601String(),
  };

  bool get isUpToDate => nextDueDate == null || nextDueDate!.isAfter(DateTime.now());
  bool get isDue => nextDueDate != null && nextDueDate!.isBefore(DateTime.now());
  int? get daysUntilDue => nextDueDate != null ? nextDueDate!.difference(DateTime.now()).inDays : null;
  
  String get formattedDate => '${dateAdministered.day}/${dateAdministered.month}/${dateAdministered.year}';
}
