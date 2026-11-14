import 'dart:async';

import 'package:cleango_app/features/checkout/pages/midtrans_checkout_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  group('Midtrans checkout navigation policy', () {
    test('allows only exact production and sandbox HTTPS checkout hosts', () {
      for (final url in [
        'https://app.midtrans.com/snap/v4/redirection/token',
        'https://app.sandbox.midtrans.com/snap/v4/redirection/token',
      ]) {
        expect(MidtransCheckoutPage.validatedCheckoutUri(url), Uri.parse(url));
        expect(
          MidtransCheckoutPage.navigationDecision(url),
          NavigationDecision.navigate,
        );
      }
    });

    test(
      'blocks legacy providers, host tricks, credentials and unsafe ports',
      () {
        for (final url in [
          '',
          'not a URL',
          'http://app.midtrans.com/snap/token',
          '//app.midtrans.com/snap/token',
          'https://checkout.xendit.co/token',
          'https://checkout-staging.xendit.co/token',
          'https://xen.to/token',
          'https://dev.xen.to/token',
          'https://midtrans.com/token',
          'https://other.midtrans.com/token',
          'https://app.midtrans.com.evil.example/token',
          'https://evil-app.midtrans.com/token',
          'https://app.midtrans.com./token',
          'https://app.midtrans.com@evil.example/token',
          'https://user:password@app.midtrans.com/token',
          'https://user@app.sandbox.midtrans.com/token',
          'https://app.midtrans.com:8443/token',
          'https://app.sandbox.midtrans.com:80/token',
          'https://127.0.0.1/token',
        ]) {
          expect(
            MidtransCheckoutPage.validatedCheckoutUri(url),
            isNull,
            reason: url,
          );
          expect(
            MidtransCheckoutPage.navigationDecision(url),
            NavigationDecision.prevent,
            reason: url,
          );
        }
        expect(MidtransCheckoutPage.validatedCheckoutUri(null), isNull);
      },
    );

    test('blocks wallet links, downloads and arbitrary finish redirects', () {
      for (final url in [
        'gojek://gopay/merchanttransfer',
        'shopeeid://wallet',
        'intent://pay#Intent;scheme=gojek;end',
        'javascript:alert(1)',
        'file:///sdcard/Download/qr.png',
        'content://downloads/qr.png',
        'blob:https://app.midtrans.com/qr',
        'data:image/png;base64,AA==',
        'https://merchant.example/finish?transaction_status=settlement',
        'https://merchant.example/finish?status_code=200',
        'https://evil.example/?redirect=https://app.midtrans.com',
      ]) {
        expect(
          MidtransCheckoutPage.navigationDecision(url),
          NavigationDecision.prevent,
          reason: url,
        );
      }
    });
  });

  testWidgets('status check stays in QRIS and ignores concurrent taps', (tester) async {
    final done = Completer<void>();
    var calls = 0;
    await tester.pumpWidget(MaterialApp(home: MidtransCheckoutPage(
      checkoutUri: Uri.parse('https://checkout.xendit.co/token'),
      onCheckStatus: () async { calls++; await done.future; },
    )));
    expect(find.text('Kembali & Cek Status'), findsNothing);
    expect(find.byType(BackButton), findsNothing);
    await tester.tap(find.text('Cek Status Pembayaran'));
    await tester.pump();
    await tester.tap(find.byType(FilledButton));
    expect(calls, 1);
    done.complete();
    await tester.pumpAndSettle();
    expect(find.byType(MidtransCheckoutPage), findsOneWidget);
    expect(find.text('Cek Status Pembayaran'), findsOneWidget);
  });

  testWidgets('invalid initial URL never creates WebView and can return', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => MidtransCheckoutPage(
                    checkoutUri: Uri.parse('https://checkout.xendit.co/token'),
                  ),
                ),
              ),
              child: const Text('Open checkout'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open checkout'));
    await tester.pumpAndSettle();

    expect(find.byType(WebViewWidget), findsNothing);
    expect(
      find.textContaining('Tautan pembayaran tidak tersedia'),
      findsOneWidget,
    );
    expect(find.text('Buka checkout di browser'), findsNothing);
    expect(find.text('Cek Status Pembayaran'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Open checkout'), findsOneWidget);
  });
}
