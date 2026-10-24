import 'package:cleango_app/core/constants/app_routes.dart';
import 'package:cleango_app/core/network/api_exception.dart';
import 'package:cleango_app/core/storage/token_storage.dart';
import 'package:cleango_app/core/theme/app_theme.dart';
import 'package:cleango_app/features/auth/controllers/auth_session_controller.dart';
import 'package:cleango_app/features/auth/data/api_auth_service.dart';
import 'package:cleango_app/features/auth/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _StubAuthService extends ApiAuthService {
  _StubAuthService({this.validCredentials = true});

  final bool validCredentials;

  @override
  Future<AuthResult> login({
    required String phone,
    required String password,
  }) async {
    if (!validCredentials) {
      throw const ApiException(
        statusCode: 401,
        message: 'Nomor telepon atau kata sandi salah.',
      );
    }
    return AuthResult(
      token: 'test-token',
      user: User(id: 1, name: 'Tester', email: 'tester@mail.com', role: 'customer'),
    );
  }
}

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  Widget buildLogin({ApiAuthService? authService}) {
    return ChangeNotifierProvider(
      create: (_) => AuthSessionController(SecureTokenStorage()),
      child: MaterialApp(
        theme: AppTheme.light,
        home: LoginPage(authService: authService),
        routes: {AppRoutes.home: (_) => const Scaffold(body: Text('Beranda'))},
      ),
    );
  }

  testWidgets('shows required errors next to both empty fields', (
    tester,
  ) async {
    await tester.pumpWidget(buildLogin());

    await tester.tap(find.widgetWithText(FilledButton, 'Login'));
    await tester.pump();

    expect(find.text('Nomor telepon wajib diisi.'), findsOneWidget);
    expect(find.text('Kata sandi wajib diisi.'), findsOneWidget);
  });

  testWidgets('shows server error for wrong credentials', (tester) async {
    await tester.pumpWidget(buildLogin(authService: _StubAuthService(validCredentials: false)));
    final fields = find.byType(TextField);

    await tester.enterText(fields.at(0), '81234567890');
    await tester.enterText(fields.at(1), 'salah');
    await tester.tap(find.widgetWithText(FilledButton, 'Login'));
    await tester.pumpAndSettle();

    expect(find.text('Nomor telepon atau kata sandi salah.'), findsOneWidget);
  });

  testWidgets('navigates to Beranda with valid credentials', (tester) async {
    await tester.pumpWidget(buildLogin(authService: _StubAuthService()));
    final fields = find.byType(TextField);

    await tester.enterText(fields.at(0), '81234567890');
    await tester.enterText(fields.at(1), '321321');
    await tester.tap(find.widgetWithText(FilledButton, 'Login'));
    await tester.pumpAndSettle();

    expect(find.text('Beranda'), findsOneWidget);
    expect(find.byType(LoginPage), findsNothing);
  });
}
