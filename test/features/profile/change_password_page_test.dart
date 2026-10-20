import 'package:cleango_app/core/theme/app_theme.dart';
import 'package:cleango_app/features/profile/controllers/profile_controller.dart';
import 'package:cleango_app/features/profile/pages/change_password_page.dart';
import 'package:cleango_app/shared/widgets/app_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('reset dialog only clears fields after confirmation', (
    tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ProfileController(),
        child: MaterialApp(
          theme: AppTheme.light,
          home: const ChangePasswordPage(),
        ),
      ),
    );
    final currentPassword = find.byType(TextField).first;
    await tester.enterText(currentPassword, '321321');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.tap(find.byIcon(Icons.lock_reset_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(currentPassword).controller!.text,
      '321321',
    );

    await tester.tap(find.byIcon(Icons.lock_reset_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kosongkan'));
    await tester.pumpAndSettle();
    for (final field in tester.widgetList<TextField>(find.byType(TextField))) {
      expect(field.controller!.text, isEmpty);
    }

    await tester.tap(find.text('Lupa Sandi?'));
    await tester.pumpAndSettle();
    expect(find.byType(AppSheet), findsOneWidget);
    expect(find.textContaining('krisna.pratama@email.com'), findsOneWidget);
    await tester.tap(find.byTooltip('Tutup'));
    await tester.pumpAndSettle();
    expect(find.byType(AppSheet), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
