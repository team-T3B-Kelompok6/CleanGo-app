import 'package:cleango_app/features/support/controllers/support_controller.dart';
import 'package:cleango_app/features/support/pages/help_center_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
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
