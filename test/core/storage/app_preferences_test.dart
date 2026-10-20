import 'package:cleango_app/core/storage/app_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test('menyimpan status onboarding secara permanen', () async {
    final preferences = AppPreferences(SharedPreferencesAsync());

    expect(await preferences.hasCompletedOnboarding(), isFalse);

    await preferences.completeOnboarding();

    expect(await preferences.hasCompletedOnboarding(), isTrue);
  });

  test('menyimpan dan menghapus filter layanan terakhir', () async {
    final preferences = AppPreferences(SharedPreferencesAsync());

    await preferences.saveLastServiceFilter('Rumah');
    expect(await preferences.readLastServiceFilter(), 'Rumah');

    await preferences.removeLastServiceFilter();
    expect(await preferences.readLastServiceFilter(), isNull);
  });
}
