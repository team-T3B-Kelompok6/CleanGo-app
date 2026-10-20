import 'package:cleango_app/features/profile/controllers/profile_controller.dart';
import 'package:cleango_app/features/profile/pages/personal_data_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  Widget buildPage() {
    return ChangeNotifierProvider(
      create: (_) => ProfileController(),
      child: const MaterialApp(home: PersonalDataPage()),
    );
  }

  testWidgets('invalid profile data blocks save and clears after correction', (
    tester,
  ) async {
    await tester.pumpWidget(buildPage());
    final nameField = find.byType(TextFormField).first;

    await tester.enterText(nameField, '12345');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Simpan Perubahan'));
    await tester.pump();

    expect(find.text('Masukkan nama lengkap yang valid.'), findsOneWidget);
    expect(find.text('Data diri berhasil disimpan.'), findsNothing);

    await tester.enterText(nameField, 'Krisna Pratama');
    await tester.pump();

    expect(find.text('Masukkan nama lengkap yang valid.'), findsNothing);
  });
}
