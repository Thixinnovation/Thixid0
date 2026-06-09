import 'package:flutter/material.dart';

class HealthExamen {
  final String id;
  final String userId;
  final String title;
  final String? laboratory;
  final DateTime examDate;
  final String? resultUrl;
  final String? doctorComment;
  final List<HealthExamenResult> results;
  final DateTime createdAt;

  HealthExamen({
    required this.id,
    required this.userId,
    required this.title,
    this.laboratory,
    required this.examDate,
    this.resultUrl,
    this.doctorComment,
    this.results = const [],
    required this.createdAt,
  });

  factory HealthExamen.fromJson(Map<String, dynamic> json) {
    final resultsList = json['results'] as List? ?? [];
    
    return HealthExamen(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      laboratory: json['laboratory'],
      examDate: DateTime.parse(json['exam_date']),
      resultUrl: json['result_url'],
      doctorComment: json['doctor_comment'],
      results: resultsList.map((r) => HealthExamenResult.fromJson(r as Map<String, dynamic>)).toList(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'title': title,
    'laboratory': laboratory,
    'exam_date': examDate.toIso8601String(),
    'result_url': resultUrl,
    'doctor_comment': doctorComment,
    'results': results.map((r) => r.toJson()).toList(),
    'created_at': createdAt.toIso8601String(),
  };

  bool get hasResult => resultUrl != null && resultUrl!.isNotEmpty;
  String get formattedDate => '${examDate.day}/${examDate.month}/${examDate.year}';
}

class HealthExamenResult {
  final String parametre;
  final String valeur;
  final String unite;
  final String norme;
  final String statut; // normal, haut, bas, critique

  HealthExamenResult({
    required this.parametre,
    required this.valeur,
    required this.unite,
    required this.norme,
    required this.statut,
  });

  factory HealthExamenResult.fromJson(Map<String, dynamic> json) {
    return HealthExamenResult(
      parametre: json['parametre'],
      valeur: json['valeur'],
      unite: json['unite'] ?? '',
      norme: json['norme'] ?? '',
      statut: json['statut'] ?? 'normal',
    );
  }

  Map<String, dynamic> toJson() => {
    'parametre': parametre,
    'valeur': valeur,
    'unite': unite,
    'norme': norme,
    'statut': statut,
  };

  bool get isAbnormal => statut != 'normal';
  
  Color get statusColor {
    switch (statut) {
      case 'normal':
        return Colors.green;
      case 'haut':
        return Colors.orange;
      case 'bas':
        return Colors.orange;
      case 'critique':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
