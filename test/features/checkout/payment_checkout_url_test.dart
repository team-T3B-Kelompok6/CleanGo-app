import 'package:cleango_app/features/checkout/controllers/payment_flow_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('checkout URL accepts HTTPS Midtrans hosts only', () {
    for (final host in ['app.midtrans.com', 'app.sandbox.midtrans.com']) {
      final url = 'https://$host/snap/v4/redirection/token';
      expect(PaymentFlowController.checkoutUri(url), Uri.parse(url));
    }
    for (final url in [
      'https://checkout.xendit.co/a',
      'https://checkout-staging.xendit.co/a',
      'https://xen.to/a',
      'https://dev.xen.to/a',
      'http://app.midtrans.com/a',
      'https://app.midtrans.com.attacker.example/a',
      'https://user:pass@app.midtrans.com/a',
      'https://app.midtrans.com:8443/a',
      'https://attacker.example/a',
      '',
    ]) {
      expect(PaymentFlowController.checkoutUri(url), isNull, reason: url);
    }
    expect(PaymentFlowController.checkoutUri(null), isNull);
  });
}
