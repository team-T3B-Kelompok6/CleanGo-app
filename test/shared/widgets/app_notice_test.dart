import 'package:cleango_app/core/theme/app_theme.dart';
import 'package:cleango_app/shared/widgets/app_notice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'success and error share the same layout with distinct status colors',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Builder(
              builder: (context) => Column(
                children: [
                  TextButton(
                    onPressed: () =>
                        AppNotice.show(context, 'Perubahan berhasil disimpan.'),
                    child: const Text('Berhasil'),
                  ),
                  TextButton(
                    onPressed: () => AppNotice.show(
                      context,
                      'Perubahan belum berhasil disimpan. Periksa kembali isian Anda.',
                      type: AppNoticeType.error,
                    ),
                    child: const Text('Gagal'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Berhasil'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<SnackBar>(find.byType(SnackBar)).backgroundColor,
        AppColors.primary,
      );
      expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);
      await tester.tap(find.text('Gagal'));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        tester.widget<SnackBar>(find.byType(SnackBar)).backgroundColor,
        AppColors.notification,
      );
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
      expect(find.text('Perubahan berhasil disimpan.'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('success notice survives navigation to the result page', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () {
                AppNotice.show(context, 'Pembayaran berhasil.');
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const Scaffold(body: Text('Pesanan')),
                  ),
                );
              },
              child: const Text('Bayar'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Bayar'));
    await tester.pumpAndSettle();
    expect(find.text('Pesanan'), findsOneWidget);
    expect(find.text('Pembayaran berhasil.'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });
}
