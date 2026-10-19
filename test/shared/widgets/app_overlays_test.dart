import 'package:cleango_app/core/theme/app_theme.dart';
import 'package:cleango_app/features/address/widgets/delete_address_dialog.dart';
import 'package:cleango_app/features/checkout/widgets/order_confirmation_dialog.dart';
import 'package:cleango_app/shared/widgets/app_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(
  VoidCallback Function(BuildContext) open, {
  double textScale = 1,
  double bottomInset = 0,
}) {
  return MaterialApp(
    theme: AppTheme.light,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(textScale),
        viewInsets: EdgeInsets.only(bottom: bottomInset),
      ),
      child: child!,
    ),
    home: Scaffold(
      body: Builder(
        builder: (context) =>
            TextButton(onPressed: open(context), child: const Text('Buka')),
      ),
    ),
  );
}

void main() {
  testWidgets('delete address cancel preserves data, confirm runs once', (
    tester,
  ) async {
    var deleted = 0;
    bool? result;
    await tester.pumpWidget(
      _host(
        (context) => () async {
          result = await DeleteAddressDialog.show(
            context,
            addressLabel: 'Rumah utama',
            onConfirm: () => deleted++,
          );
        },
      ),
    );

    await tester.tap(find.text('Buka'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Rumah utama'), findsOneWidget);
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Hapus Alamat'),
    );
    expect(button.style!.backgroundColor!.resolve({}), AppColors.notification);
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(deleted, 0);
    expect(result, isFalse);

    await tester.tap(find.text('Buka'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus Alamat'));
    await tester.pumpAndSettle();
    expect(deleted, 1);
    expect(result, isTrue);
  });

  testWidgets('long dialog scrolls on a small screen with large text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 480));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var confirmed = false;
    await tester.pumpWidget(
      _host(
        (context) =>
            () => showDialog<void>(
              context: context,
              builder: (dialogContext) => AppDialog(
                title: 'Periksa informasi pesanan Anda',
                message: List.filled(
                  14,
                  'Alamat lengkap akan tetap terlihat.',
                ).join(' '),
                cancelLabel: 'Kembali',
                confirmLabel: 'Lihat Pesanan Terjadwal',
                onConfirm: () {
                  confirmed = true;
                  Navigator.pop(dialogContext);
                },
              ),
            ),
        textScale: 1.5,
      ),
    );
    await tester.tap(find.text('Buka'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Lihat Pesanan Terjadwal'),
      250,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lihat Pesanan Terjadwal'));
    await tester.pumpAndSettle();

    expect(confirmed, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('confirmation sheet keeps actions visible above the keyboard', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    bool? confirmed;
    await tester.pumpWidget(
      _host(
        (context) => () async {
          confirmed = await showOrderConfirmationDialog(
            context,
            serviceName: 'Deep Cleaning',
            schedule: 'Senin, 19 Oktober 2026, 12:00 WIB',
            address: List.filled(4, 'Jl. Sigura-gura, Kota Malang.').join(' '),
            note: List.filled(
              4,
              'Bersihkan dapur dan ruang keluarga.',
            ).join(' '),
            paymentMethod: 'QRIS',
            total: 'Rp102.500',
          );
        },
        textScale: 1.3,
        bottomInset: 240,
      ),
    );
    await tester.tap(find.text('Buka'));
    await tester.pumpAndSettle();

    final payButton = find.text('Lanjut Bayar');
    expect(tester.getBottomRight(payButton).dy, lessThanOrEqualTo(400));
    expect(tester.takeException(), isNull);
    await tester.tap(payButton);
    await tester.pumpAndSettle();
    expect(confirmed, isTrue);

    await tester.tap(find.text('Buka'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Periksa Lagi'));
    await tester.pumpAndSettle();
    expect(confirmed, isFalse);

    await tester.tap(find.text('Buka'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Tutup'));
    await tester.pumpAndSettle();
    expect(confirmed, isFalse);
  });
}
