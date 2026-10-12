import 'package:flutter/widgets.dart';

import '../models/user_profile_model.dart';
import 'profile_controller.dart';

class PersonalDataFormController {
  PersonalDataFormController(UserProfileModel profile)
    : name = TextEditingController(text: profile.fullName),
      phone = TextEditingController(
        text: _localPhoneDigits(profile.phoneNumber),
      ),
      email = TextEditingController(text: profile.email),
      selectedGender = profile.gender,
      selectedBirthDate = profile.birthDate;

  final TextEditingController name;
  final TextEditingController phone;
  final TextEditingController email;

  String selectedGender;
  DateTime selectedBirthDate;
  bool isPhoneEditable = false;

  String get formattedBirthDate =>
      UserProfileModel.formatBirthDate(selectedBirthDate);

  void selectGender(String gender) => selectedGender = gender;
  void selectBirthDate(DateTime date) => selectedBirthDate = date;

  bool togglePhoneEditing() {
    isPhoneEditable = !isPhoneEditable;
    return isPhoneEditable;
  }

  void saveTo(ProfileController profileController) {
    profileController.updateProfile(
      fullName: name.text.trim(),
      phoneNumber: '+62 ${_localPhoneDigits(phone.text)}',
      email: email.text.trim(),
      gender: selectedGender,
      birthDate: selectedBirthDate,
    );
  }

  void dispose() {
    name.dispose();
    phone.dispose();
    email.dispose();
  }

  static String _localPhoneDigits(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('62')) return digits.substring(2);
    if (digits.startsWith('0')) return digits.substring(1);
    return digits;
  }
}
