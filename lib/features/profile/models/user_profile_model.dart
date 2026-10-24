class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.customerId,
    required this.fullName,
    required this.phoneNumber,
    this.isPhoneVerified = true,
    required this.email,
    required this.gender,
    required this.birthDate,
    this.avatarAsset = 'assets/images/user_profile.jpeg',
  });

  final String id;
  final String customerId;
  final String fullName;
  final String phoneNumber;
  final bool isPhoneVerified;
  final String email;
  final String gender; // 'Laki-laki' | 'Perempuan'
  final DateTime birthDate;
  final String avatarAsset;

  String get formattedBirthDate => formatBirthDate(birthDate);

  static String formatBirthDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final monthName = months[date.month - 1];
    return '${date.day} $monthName ${date.year}';
  }

  UserProfileModel copyWith({
    String? id,
    String? customerId,
    String? fullName,
    String? phoneNumber,
    bool? isPhoneVerified,
    String? email,
    String? gender,
    DateTime? birthDate,
    String? avatarAsset,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      avatarAsset: avatarAsset ?? this.avatarAsset,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'isPhoneVerified': isPhoneVerified,
      'email': email,
      'gender': gender,
      'birthDate': birthDate.toIso8601String(),
      'avatarAsset': avatarAsset,
    };
  }

  factory UserProfileModel.fromCustomerJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id']?.toString() ?? json['customerId']?.toString() ?? 'usr-001',
      customerId: json['id']?.toString() ?? json['customerId']?.toString() ?? 'CG-8829104',
      fullName: json['name'] as String? ?? json['fullName'] as String? ?? 'Krisna Pratama',
      phoneNumber: json['phone'] as String? ?? json['phoneNumber'] as String? ?? '+62 812-3456-7890',
      isPhoneVerified: true,
      email: json['email'] as String? ?? 'krisna.pratama@email.com',
      gender: 'Laki-laki',
      birthDate: DateTime(1995, 5, 14),
      avatarAsset: 'assets/images/user_profile.jpeg',
    );
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String? ?? 'usr-001',
      customerId: json['customerId'] as String? ?? 'CG-8829104',
      fullName: json['fullName'] as String? ?? 'Krisna Pratama',
      phoneNumber: json['phoneNumber'] as String? ?? '+62 812–3456–7890',
      isPhoneVerified: json['isPhoneVerified'] as bool? ?? true,
      email: json['email'] as String? ?? 'krisna.pratama@email.com',
      gender: json['gender'] as String? ?? 'Laki-laki',
      birthDate: json['birthDate'] != null
          ? DateTime.tryParse(json['birthDate'] as String) ??
                DateTime(1995, 5, 14)
          : DateTime(1995, 5, 14),
      avatarAsset:
          json['avatarAsset'] as String? ?? 'assets/images/user_profile.jpeg',
    );
  }
}
