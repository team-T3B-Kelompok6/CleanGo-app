import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  AppPreferences(this._preferences);

  static const _onboardingCompletedKey = 'onboarding_completed';
  static const _lastServiceFilterKey = 'last_service_filter';

  final SharedPreferencesAsync _preferences;

  Future<bool> hasCompletedOnboarding() async =>
      await _preferences.getBool(_onboardingCompletedKey) ?? false;

  Future<void> completeOnboarding() {
    return _preferences.setBool(_onboardingCompletedKey, true);
  }

  Future<String?> readLastServiceFilter() {
    return _preferences.getString(_lastServiceFilterKey);
  }

  Future<void> saveLastServiceFilter(String filter) {
    return _preferences.setString(_lastServiceFilterKey, filter);
  }

  Future<void> removeLastServiceFilter() {
    return _preferences.remove(_lastServiceFilterKey);
  }
}
