// lib/models/beneficiary_model.dart
class Beneficiary {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? avatar;
  final List<BeneficiaryAccount> accounts;
  final DateTime addedAt;

  Beneficiary({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.avatar,
    this.accounts = const [],
    required this.addedAt,
  });

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }
}

class BeneficiaryAccount {
  final String id;
  final String bankName;
  final String accountNumber;
  final String? accountHolderName;
  final bool isDefault;

  BeneficiaryAccount({
    required this.id,
    required this.bankName,
    required this.accountNumber,
    this.accountHolderName,
    this.isDefault = false,
  });
}
