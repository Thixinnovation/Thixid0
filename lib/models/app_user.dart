import 'package:supabase_flutter/supabase_flutter.dart';

enum AccountType { personal, enterprise }

class AppUser {
  final String id;
  final String thixId;
  final String thixChat;
  final int? thixScore;
  final String email;
  final String? phone;
  final String displayName;
  final AccountType accountType;
  final String? photoUrl;
  final String? bio;
  final String? title;  // ← AJOUTÉ (pour le titre professionnel)
  final String? countryOrOrigin;
  final String? contactPhone;
  final String? maritalStatus;
  final String? gender;
  final String? occupation;
  final String? profession;
  final String? dateOfBirth;
  final String? placeOfBirth;
  final String? nationality;
  final String? address;
  final String? fatherName;
  final String? motherName;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? emergencyContactRelation;
  final String? registrationStatus;
  final List<Map<String, dynamic>> education;
  final List<Map<String, dynamic>> experience;
  final List<Map<String, dynamic>> skills;
  final List<Map<String, dynamic>> enrollments;
  final List<String> languages;
  final bool biometricsEnabled;
  final bool twoFaEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppUser({
    required this.id,
    required this.thixId,
    required this.thixChat,
    this.thixScore,
    required this.email,
    this.phone,
    required this.displayName,
    required this.accountType,
    this.photoUrl,
    this.bio,
    this.title,  // ← AJOUTÉ
    this.countryOrOrigin,
    this.contactPhone,
    this.maritalStatus,
    this.gender,
    this.occupation,
    this.profession,
    this.dateOfBirth,
    this.placeOfBirth,
    this.nationality,
    this.address,
    this.fatherName,
    this.motherName,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.emergencyContactRelation,
    this.registrationStatus,
    this.education = const [],
    this.experience = const [],
    this.skills = const [],
    this.enrollments = const [],
    this.languages = const [],
    this.biometricsEnabled = true,
    this.twoFaEnabled = false,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get hasRealThixId => thixId.isNotEmpty && thixId != 'THIX-PENDING';
  bool get hasActiveTrial => registrationStatus == 'trial';

  AppUser copyWith({
    String? thixId,
    String? displayName,
    String? bio,
    String? title,  // ← AJOUTÉ
    String? countryOrOrigin,
    String? occupation,
    String? profession,
    String? thixChat,
    String? photoUrl,
    String? contactPhone,
    String? maritalStatus,
    String? gender,
    String? dateOfBirth,
    String? placeOfBirth,
    String? nationality,
    String? address,
    String? fatherName,
    String? motherName,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? emergencyContactRelation,
    String? registrationStatus,
    List<String>? languages,
    List<Map<String, dynamic>>? education,
    List<Map<String, dynamic>>? experience,
    List<Map<String, dynamic>>? skills,
    List<Map<String, dynamic>>? enrollments,
    bool? biometricsEnabled,
    bool? twoFaEnabled,
    DateTime? updatedAt,
  }) {
    return AppUser(
      id: id,
      thixId: thixId ?? this.thixId,
      thixChat: thixChat ?? this.thixChat,
      thixScore: thixScore,
      email: email,
      phone: phone,
      displayName: displayName ?? this.displayName,
      accountType: accountType,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      title: title ?? this.title,  // ← AJOUTÉ
      countryOrOrigin: countryOrOrigin ?? this.countryOrOrigin,
      contactPhone: contactPhone ?? this.contactPhone,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      gender: gender ?? this.gender,
      occupation: occupation ?? this.occupation,
      profession: profession ?? this.profession,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      placeOfBirth: placeOfBirth ?? this.placeOfBirth,
      nationality: nationality ?? this.nationality,
      address: address ?? this.address,
      fatherName: fatherName ?? this.fatherName,
      motherName: motherName ?? this.motherName,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      emergencyContactRelation: emergencyContactRelation ?? this.emergencyContactRelation,
      registrationStatus: registrationStatus ?? this.registrationStatus,
      education: education ?? this.education,
      experience: experience ?? this.experience,
      skills: skills ?? this.skills,
      enrollments: enrollments ?? this.enrollments,
      languages: languages ?? this.languages,
      biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
      twoFaEnabled: twoFaEnabled ?? this.twoFaEnabled,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
