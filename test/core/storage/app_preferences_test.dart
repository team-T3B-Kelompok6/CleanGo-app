import 'package:cleango_app/core/storage/app_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('menyimpan status onboarding secara permanen', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = AppPreferences(await SharedPreferences.getInstance());

    expect(preferences.hasCompletedOnboarding, isFalse);

    await preferences.completeOnboarding();

    expect(preferences.hasCompletedOnboarding, isTrue);
  });
}
