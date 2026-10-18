import 'package:cleango_app/features/checkout/controllers/payment_countdown_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('starts from the configured duration', () {
    final controller = PaymentCountdownController(
      duration: const Duration(minutes: 5),
    );
    addTearDown(controller.dispose);

    expect(controller.remaining, const Duration(minutes: 5));
    expect(controller.formattedRemaining, '05:00');
    expect(controller.isExpired, isFalse);
  });
}
