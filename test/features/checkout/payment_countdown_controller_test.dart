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

  test(
    'expires even when the preceding tick already displays zero seconds',
    () async {
      final controller = PaymentCountdownController(
        duration: const Duration(milliseconds: 2500),
      );
      addTearDown(controller.dispose);
      var updates = 0;
      controller.addListener(() => updates++);

      await Future<void>.delayed(const Duration(seconds: 4));
      expect(controller.formattedRemaining, '00:00');
      expect(controller.remaining, Duration.zero);
      expect(controller.isExpired, isTrue);

      final expiredUpdates = updates;
      await Future<void>.delayed(const Duration(milliseconds: 1100));
      expect(updates, expiredUpdates);
    },
  );
}
