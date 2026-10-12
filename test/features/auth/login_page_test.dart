import 'package:cleango_app/core/constants/app_routes.dart';
import 'package:cleango_app/core/theme/app_theme.dart';
import 'package:cleango_app/features/auth/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildLogin() {
    return MaterialApp(
      theme: AppTheme.light,
      home: const LoginPage(),
      routes: {AppRoutes.home: (_) => const Scaffold(body: Text('Beranda'))},
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

  testWidgets('shows only password error when phone is correct', (
    tester,
  ) async {
    await tester.pumpWidget(buildLogin());
    final fields = find.byType(TextField);

    await tester.enterText(fields.at(0), '81234567890');
    await tester.enterText(fields.at(1), 'salah');
    await tester.tap(find.widgetWithText(FilledButton, 'Login'));
    await tester.pump();

    expect(find.text('Nomor telepon tidak terdaftar.'), findsNothing);
    expect(
      find.text(
        'Kata sandi tidak sesuai. Coba lagi atau klik "Lupa Kata Sandi" untuk mengatur ulang.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('navigates to Beranda with valid dummy credentials', (
    tester,
  ) async {
    await tester.pumpWidget(buildLogin());
    final fields = find.byType(TextField);

    await tester.enterText(fields.at(0), '81234567890');
    await tester.enterText(fields.at(1), '321321');
    await tester.tap(find.widgetWithText(FilledButton, 'Login'));
    await tester.pumpAndSettle();

    expect(find.text('Beranda'), findsOneWidget);
    expect(find.byType(LoginPage), findsNothing);
  });
}
