import 'package:cleango_app/core/theme/app_theme.dart';
import 'package:cleango_app/features/auth/data/api_auth_service.dart';
import 'package:cleango_app/features/auth/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubAuthService extends ApiAuthService {
  @override
  Future<AuthResult> register({
    required String name,
    required String phone,
    required String password,
    String? email,
  }) async {
    return AuthResult(
      token: 'test-token',
      user: User(id: 1, name: name, email: email ?? '', role: 'customer'),
    );
  }
}

void main() {
  Widget buildRegister() {
    return MaterialApp(theme: AppTheme.light, home: const RegisterPage());
  }

  Widget buildRegisterFlow() {
    return MaterialApp(
      theme: AppTheme.light,
      home: Builder(
        builder: (context) => Scaffold(
          body: FilledButton(
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute(
                builder: (_) => RegisterPage(authService: _StubAuthService()),
              ),
            ),
            child: const Text('Buka Register'),
          ),
        ),
      ),
    );
  }

  testWidgets('shows no validation errors before the first submit', (
    tester,
  ) async {
    await tester.pumpWidget(buildRegister());

    expect(find.text('Nama wajib diisi.'), findsNothing);
    expect(find.text('Nomor telepon wajib diisi.'), findsNothing);
    expect(find.text('Kata sandi wajib diisi.'), findsNothing);
  });

  testWidgets('clears a field error when its value becomes valid', (
    tester,
  ) async {
    await tester.pumpWidget(buildRegister());

    await tester.tap(find.widgetWithText(FilledButton, 'Daftar'));
    await tester.pump();
    expect(find.text('Nama wajib diisi.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'Krisna Pratama');
    await tester.pump();

    expect(find.text('Nama wajib diisi.'), findsNothing);
  });

  testWidgets('shows confirmation mismatch and clears it after correction', (
    tester,
  ) async {
    await tester.pumpWidget(buildRegister());
    final fields = find.byType(TextFormField);

    await tester.enterText(fields.at(0), 'Krisna Pratama');
    await tester.enterText(fields.at(1), '81234567890');
    await tester.enterText(fields.at(2), 'CleanGo123');
    await tester.enterText(fields.at(3), 'CleanGo999');
    await tester.tap(find.widgetWithText(FilledButton, 'Daftar'));
    await tester.pump();

    expect(find.text('Konfirmasi password belum sama.'), findsOneWidget);

    await tester.enterText(fields.at(3), 'CleanGo123');
    await tester.pump();
    expect(find.text('Konfirmasi password belum sama.'), findsNothing);
  });

  testWidgets('valid registration returns to the previous page', (
    tester,
  ) async {
    await tester.pumpWidget(buildRegisterFlow());
    await tester.tap(find.text('Buka Register'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);

    await tester.enterText(fields.at(0), 'Krisna Pratama');
    await tester.enterText(fields.at(1), '81234567890');
    await tester.enterText(fields.at(2), 'CleanGo123');
    await tester.enterText(fields.at(3), 'CleanGo123');
    await tester.tap(find.widgetWithText(FilledButton, 'Daftar'));
    await tester.pumpAndSettle();

    expect(find.byType(RegisterPage), findsNothing);
    expect(find.text('Buka Register'), findsOneWidget);
  });
}
