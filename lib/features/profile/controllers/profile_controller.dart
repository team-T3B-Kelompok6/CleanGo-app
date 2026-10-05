import 'package:flutter/foundation.dart';
import '../models/user_profile_model.dart';

class ProfileController extends ChangeNotifier {
  ProfileController() {
    _profile = _initialProfile;
  }

  static final UserProfileModel _initialProfile = UserProfileModel(
    id: 'usr-001',
    customerId: 'CG-8829104',
    fullName: 'Krisna Pratama',
    phoneNumber: '+62 812–3456–7890',
    isPhoneVerified: true,
    email: 'krisna.pratama@email.com',
    gender: 'Laki-laki',
    birthDate: DateTime(1995, 5, 14),
    avatarAsset: 'assets/images/user_profile.jpeg',
  );

  late UserProfileModel _profile;

  UserProfileModel get profile => _profile;

  String get id => _profile.id;
  String get customerId => _profile.customerId;
  String get fullName => _profile.fullName;
  String get phoneNumber => _profile.phoneNumber;
  bool get isPhoneVerified => _profile.isPhoneVerified;
  String get email => _profile.email;
  String get gender => _profile.gender;
  DateTime get birthDate => _profile.birthDate;
  String get formattedBirthDate => _profile.formattedBirthDate;
  String get avatarAsset => _profile.avatarAsset;
  String get password => _profile.password;

  bool verifyPassword(String input) => input == _profile.password;

  bool changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    if (verifyPassword(currentPassword)) {
      _profile = _profile.copyWith(password: newPassword);
      notifyListeners();
      return true;
    }
    return false;
  }

  void updateProfile({
    String? fullName,
    String? phoneNumber,
    bool? isPhoneVerified,
    String? email,
    String? gender,
    DateTime? birthDate,
    String? avatarAsset,
    String? password,
  }) {
    _profile = _profile.copyWith(
      fullName: fullName,
      phoneNumber: phoneNumber,
      isPhoneVerified: isPhoneVerified,
      email: email,
      gender: gender,
      birthDate: birthDate,
      avatarAsset: avatarAsset,
      password: password,
    );
    notifyListeners();
  }

  void updateAvatar(String asset) {
    if (_profile.avatarAsset != asset) {
      _profile = _profile.copyWith(avatarAsset: asset);
      notifyListeners();
    }
  }

  void setPhoneVerified(bool verified) {
    if (_profile.isPhoneVerified != verified) {
      _profile = _profile.copyWith(isPhoneVerified: verified);
      notifyListeners();
    }
  }
}
