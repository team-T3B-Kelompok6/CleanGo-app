import 'package:cleango_app/core/theme/app_theme.dart';
import 'package:cleango_app/features/support/controllers/support_controller.dart';
import 'package:cleango_app/features/support/pages/help_center_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('help and terms overlays can be read and dismissed', (
    tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => SupportController(),
        child: MaterialApp(theme: AppTheme.light, home: const HelpCenterPage()),
      ),
    );
    Future<void> finishTransition() async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }

    await tester.tap(find.byIcon(Icons.help_outline_rounded).first);
    await finishTransition();
    expect(find.text('Pusat Dukungan'), findsOneWidget);
    await tester.tap(find.text('Mengerti'));
    await finishTransition();

    final terms = find.text('Syarat & Ketentuan Layanan');
    await tester.scrollUntilVisible(
      terms,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await finishTransition();
    await tester.tap(terms);
    await finishTransition();
    final lastSection = find.text('4. Privasi & Keamanan Data');
    await tester.ensureVisible(lastSection);
    await finishTransition();
    expect(lastSection, findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Tutup'));
    await finishTransition();
    expect(find.byTooltip('Tutup'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('shows search empty state and reset restores FAQ data', (
    tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => SupportController(),
        child: const MaterialApp(home: HelpCenterPage()),
      ),
    );

    await tester.enterText(find.byType(TextField).first, 'xyz999tidakada');
    await tester.pump();

    expect(find.text('Topik bantuan tidak ditemukan'), findsOneWidget);

    await tester.tap(find.text('Reset Pencarian'));
    await tester.pump();

    expect(find.text('Topik bantuan tidak ditemukan'), findsNothing);
    expect(
      find.text('Bagaimana cara menjadwalkan ulang pesanan?'),
      findsOneWidget,
    );
  });
}
