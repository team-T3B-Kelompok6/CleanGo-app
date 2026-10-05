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
    this.password = '321321',
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
  final String password;

  String get formattedBirthDate {
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
    final monthName = months[birthDate.month - 1];
    return '${birthDate.day} $monthName ${birthDate.year}';
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
    String? password,
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
      password: password ?? this.password,
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
      'password': password,
    };
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
          ? DateTime.tryParse(json['birthDate'] as String) ?? DateTime(1995, 5, 14)
          : DateTime(1995, 5, 14),
      avatarAsset: json['avatarAsset'] as String? ?? 'assets/images/user_profile.jpeg',
      password: json['password'] as String? ?? '321321',
    );
  }
}
