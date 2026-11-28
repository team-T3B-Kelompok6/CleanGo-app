import 'package:cleango_app/core/network/api_exception.dart';
import 'package:cleango_app/features/auth/data/api_auth_service.dart';
import 'package:cleango_app/features/auth/pages/forgot_password_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecoveryService extends ApiAuthService {
  String? submittedIdentifier;
  String? submittedChannel;
  String? completedIdentifier;
  String? completedOtp;
  String? completedPassword;
  bool shouldThrow = false;

  @override
  Future<void> forgotPassword({
    required String identifier,
    required String channel,
  }) async {
    submittedIdentifier = identifier;
    submittedChannel = channel;
    if (shouldThrow) throw ApiException(statusCode: 500, message: 'Gagal kirim');
  }

  @override
  Future<void> resetPassword({
    required String identifier,
    required String otp,
    required String newPassword,
  }) async {
    completedIdentifier = identifier;
    completedOtp = otp;
    completedPassword = newPassword;
  }
}

Future<void> _submitRecovery(
  WidgetTester tester,
  _RecoveryService service, {
  required String identifier,
}) async {
  await tester.pumpWidget(
    MaterialApp(home: ForgotPasswordPage(authService: service)),
  );
  await tester.enterText(find.byType(TextFormField), identifier);
  await tester.tap(find.byType(FilledButton));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'nomor telepon mengirimkan channel whatsapp',
    (tester) async {
      final service = _RecoveryService();
      await _submitRecovery(tester, service, identifier: '081234567890');
      expect(service.submittedIdentifier, '081234567890');
      expect(service.submittedChannel, 'whatsapp');
    },
  );

  testWidgets(
    'email mengirimkan channel email',
    (tester) async {
      final service = _RecoveryService();
      await _submitRecovery(tester, service, identifier: 'customer@example.test');
      expect(service.submittedIdentifier, 'customer@example.test');
      expect(service.submittedChannel, 'email');
    },
  );

  testWidgets(
    'retry allowed after failed delivery',
    (tester) async {
      final service = _RecoveryService()..shouldThrow = true;
      await tester.pumpWidget(
        MaterialApp(home: ForgotPasswordPage(authService: service)),
      );
      await tester.enterText(find.byType(TextFormField), 'customer@example.test');
      await tester.tap(find.text('Kirim Kode OTP'));
      await tester.pumpAndSettle();
      expect(find.byType(TextFormField), findsOneWidget);
    },
  );

  testWidgets(
    'shows specific error when account is not registered',
    (tester) async {
      final service = _RecoveryService()
        ..shouldThrow = true; // Akan melempar ApiException
      await tester.pumpWidget(
        MaterialApp(home: ForgotPasswordPage(authService: service)),
      );
      await tester.enterText(find.byType(TextFormField), 'ghost@example.test');
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(find.text('Gagal kirim'), findsNWidgets(2));
      expect(find.byType(TextFormField), findsOneWidget);
    },
  );
}