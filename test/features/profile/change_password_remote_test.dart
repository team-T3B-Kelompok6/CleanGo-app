import 'package:cleango_app/core/constants/app_routes.dart';
import 'package:cleango_app/core/storage/token_storage.dart';
import 'package:cleango_app/features/auth/controllers/auth_session_controller.dart';
import 'package:cleango_app/core/theme/app_theme.dart';
import 'package:cleango_app/features/profile/controllers/profile_controller.dart';
import 'package:cleango_app/features/profile/data/customer_profile_service.dart';
import 'package:cleango_app/features/profile/models/user_profile_model.dart';
import 'package:cleango_app/features/profile/pages/change_password_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _MemoryTokens implements TokenStorage {
  _MemoryTokens(this.token);
  final String? token;
  bool cleared = false;
  @override
  Future<String?> readAccessToken() async => cleared ? null : token;
  @override
  Future<void> clearSession() async => cleared = true;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeProfileService extends CustomerProfileService {
  _FakeProfileService({this.fail = false});
  final bool fail;
  int passwordCalls = 0;
  String? lastCurrent;
  String? lastNew;

  @override
  Future<void> changePassword(
    String token, {
    required String currentPassword,
    required String newPassword,
  }) async {
    passwordCalls++;
    lastCurrent = currentPassword;
    lastNew = newPassword;
    if (fail) throw StateError('Password lama salah');
  }

  @override
  Future<UserProfileModel> fetchProfile(String token) async => _profile;

  static final _profile = UserProfileModel(
    id: '1',
    customerId: '1',
    fullName: 'Pengguna',
    phoneNumber: '0812',
    email: 'p@e.com',
    gender: 'Laki-laki',
    birthDate: DateTime(1995, 5, 14),
  );
}

Widget _app(ProfileController controller, TokenStorage tokens) => MultiProvider(
  providers: [
    ChangeNotifierProvider<ProfileController>.value(value: controller),
    ChangeNotifierProvider<AuthSessionController>(
      create: (_) => AuthSessionController(tokens),
    ),
  ],
  child: MaterialApp(
    theme: AppTheme.light,
    home: const ChangePasswordPage(),
    routes: {AppRoutes.login: (_) => const Scaffold(body: Text('Halaman Login'))},
  ),
);

Future<void> _fill(WidgetTester tester, String current, String next) async {
  final fields = find.byType(TextField);
  await tester.enterText(fields.at(0), current);
  await tester.enterText(fields.at(1), next);
  await tester.enterText(fields.at(2), next);
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pump();
}

void main() {
  testWidgets('changing the password calls the backend, not just local state', (
    tester,
  ) async {
    final service = _FakeProfileService();
    final tokens = _MemoryTokens('a.b.c');
    final controller = ProfileController(tokenStorage: tokens, service: service);
    await tester.pumpWidget(_app(controller, tokens));

    await _fill(tester, 'Lama12345', 'Baru12345');
    await tester.tap(find.byType(ElevatedButton).last);
    await tester.pumpAndSettle();

    expect(service.passwordCalls, 1);
    expect(service.lastCurrent, 'Lama12345');
    expect(service.lastNew, 'Baru12345');
    // Signed out and sent back to the login screen.
    expect(tokens.cleared, isTrue);
    expect(find.byType(ChangePasswordPage), findsNothing);
    expect(find.text('Halaman Login'), findsOneWidget);
  });

  testWidgets('shows the server error when the current password is wrong', (
    tester,
  ) async {
    final service = _FakeProfileService(fail: true);
    final tokens = _MemoryTokens('a.b.c');
    final controller = ProfileController(tokenStorage: tokens, service: service);
    await tester.pumpWidget(_app(controller, tokens));

    await _fill(tester, 'Lama12345', 'Baru12345');
    await tester.tap(find.byType(ElevatedButton).last);
    await tester.pumpAndSettle();

    expect(service.passwordCalls, 1);
    // The page stays open because the change failed.
    expect(find.byType(ChangePasswordPage), findsOneWidget);
  });

  testWidgets('never reports success without a session', (tester) async {
    final service = _FakeProfileService();
    final tokens = _MemoryTokens(null);
    final controller = ProfileController(tokenStorage: tokens, service: service);
    await tester.pumpWidget(_app(controller, tokens));

    await _fill(tester, 'Lama12345', 'Baru12345');
    await tester.tap(find.byType(ElevatedButton).last);
    await tester.pumpAndSettle();

    expect(service.passwordCalls, 0);
    expect(find.byType(ChangePasswordPage), findsOneWidget);
  });
}
