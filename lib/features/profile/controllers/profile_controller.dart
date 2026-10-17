import 'package:flutter/foundation.dart';

import '../../../core/storage/token_storage.dart';
import '../data/customer_profile_service.dart';
import '../models/user_profile_model.dart';

class ProfileController extends ChangeNotifier {
  ProfileController({TokenStorage? tokenStorage, CustomerProfileService? service})
      : _tokenStorage = tokenStorage,
        _service = service ?? CustomerProfileService() {
    _profile = _initialProfile;
  }

  final TokenStorage? _tokenStorage;
  final CustomerProfileService _service;
  String? _error;
  bool _loading = false;
  String? get error => _error;
  bool get loading => _loading;

  Future<void> loadFromApi() async {
    final token = await _tokenStorage?.readAccessToken();
    if (token == null || token.isEmpty) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _profile = await _service.fetchProfile(token);
    } catch (e) { _error = e.toString(); } finally { _loading = false; notifyListeners(); }
  }

  Future<bool> updateProfileRemote({String? fullName, String? email, String? phoneNumber}) async {
    final token = await _tokenStorage?.readAccessToken();
    if (token == null || token.isEmpty) { updateProfile(fullName: fullName, email: email, phoneNumber: phoneNumber); return true; }
    try {
      _profile = await _service.updateProfile(token, fullName: fullName, email: email, phoneNumber: phoneNumber);
      notifyListeners();
      return true;
    } catch (e) { _error = e.toString(); notifyListeners(); return false; }
  }

  Future<bool> changePasswordRemote({required String currentPassword, required String newPassword}) async {
    final token = await _tokenStorage?.readAccessToken();
    if (token == null || token.isEmpty) return changePassword(currentPassword: currentPassword, newPassword: newPassword);
    try {
      await _service.changePassword(token, currentPassword: currentPassword, newPassword: newPassword);
      return true;
    } catch (e) { _error = e.toString(); notifyListeners(); return false; }
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
