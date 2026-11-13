import 'package:cleango_app/features/checkout/controllers/payment_flow_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('checkout URL accepts HTTPS Midtrans and legacy Xendit hosts only', () {
    expect(
      PaymentFlowController.checkoutUri(
        'https://app.sandbox.midtrans.com/snap/v4/redirection/token',
      ),
      Uri.parse('https://app.sandbox.midtrans.com/snap/v4/redirection/token'),
    );
    expect(
      PaymentFlowController.checkoutUri('http://checkout.xendit.co/a'),
      isNull,
    );
    expect(
      PaymentFlowController.checkoutUri(
        'https://checkout.xendit.co.attacker.example/a',
      ),
      isNull,
    );
    expect(
      PaymentFlowController.checkoutUri('https://user:pass@pay.xendit.co/a'),
      isNull,
    );
    expect(
      PaymentFlowController.checkoutUri('https://pay.xendit.co:8443/a'),
      isNull,
    );
  });
}
