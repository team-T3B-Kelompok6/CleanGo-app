import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  AppPreferences(this._preferences);

  static const _onboardingCompletedKey = 'onboarding_completed';

  final SharedPreferences _preferences;

  bool get hasCompletedOnboarding =>
      _preferences.getBool(_onboardingCompletedKey) ?? false;

  Future<void> completeOnboarding() {
    return _preferences.setBool(_onboardingCompletedKey, true);
  }
}
