import 'package:cleango_app/features/booking/data/customer_booking_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps booking pay response data and payment keys', () {
    final result = BookingPayment.fromJson({
      'data': {
        'id': 42,
        'code': 'CG-000042',
        'status': 'Menunggu Assign',
        'totalAmount': 105000,
        'paymentStatus': 'pending',
      },
      'payment': {
        'status': 'pending',
        'checkoutUrl': 'https://checkout.xendit.co/abc',
        'expiresAt': '2030-01-02T12:00:00.000Z',
      },
    });

    expect(result.booking.id, '42');
    expect(result.booking.paymentStatus, 'pending');
    expect(result.status, 'pending');
    expect(result.checkoutUrl, 'https://checkout.xendit.co/abc');
    expect(result.expiresAt, DateTime.parse('2030-01-02T12:00:00.000Z').toLocal());
  });
}
