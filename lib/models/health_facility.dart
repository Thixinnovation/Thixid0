import 'package:flutter/material.dart';

class HealthFacility {
  final String id;
  final String name;
  final String type; // hospital, pharmacy, clinic
  final String? address;
  final String? phone;
  final double? latitude;
  final double? longitude;
  final double? rating;
  final bool is24h;
  final bool isEmergency;
  final bool isActive;
  final DateTime createdAt;

  HealthFacility({
    required this.id,
    required this.name,
    required this.type,
    this.address,
    this.phone,
    this.latitude,
    this.longitude,
    this.rating,
    required this.is24h,
    required this.isEmergency,
    required this.isActive,
    required this.createdAt,
  });

  factory HealthFacility.fromJson(Map<String, dynamic> json) {
    return HealthFacility(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      address: json['address'],
      phone: json['phone'],
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      is24h: json['is_24h'] ?? false,
      isEmergency: json['is_emergency'] ?? false,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'address': address,
    'phone': phone,
    'latitude': latitude,
    'longitude': longitude,
    'rating': rating,
    'is_24h': is24h,
    'is_emergency': isEmergency,
    'is_active': isActive,
    'created_at': createdAt.toIso8601String(),
  };

  bool get isHospital => type == 'hospital';
  bool get isPharmacy => type == 'pharmacy';
  bool get isClinic => type == 'clinic';
  
  IconData get icon {
    if (isHospital) return Icons.local_hospital;
    if (isPharmacy) return Icons.local_pharmacy;
    return Icons.medical_services;
  }
  
  Color get color {
    if (isHospital) return Colors.red;
    if (isPharmacy) return Colors.green;
    return Colors.blue;
  }
}
