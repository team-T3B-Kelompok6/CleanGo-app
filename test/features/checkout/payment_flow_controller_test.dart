import 'package:cleango_app/features/address/controllers/address_controller.dart';
import 'package:cleango_app/features/booking/controllers/booking_controller.dart';
import 'package:cleango_app/features/checkout/controllers/payment_flow_controller.dart';
import 'package:cleango_app/features/checkout/domain/models/payment_method_model.dart';
import 'package:cleango_app/features/order/controllers/order_controller.dart';
import 'package:cleango_app/features/order/domain/models/order_model.dart';
import 'package:cleango_app/features/service/data/service_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('only exposes QRIS and cash payment methods', () {
    expect(paymentMethods.map((method) => method.type), [
      PaymentMethodType.qris,
      PaymentMethodType.cash,
    ]);
  });

  group('PaymentFlowController', () {
    late BookingController booking;
    late AddressController addresses;
    late OrderController orders;
    const controller = PaymentFlowController();

    setUp(() {
      booking = BookingController()..startBooking(ServiceData.services.first);
      addresses = AddressController();
      orders = OrderController();
    });

    test('creates an order from the selected booking and address', () async {
      booking
        ..selectDate(DateTime(2030, 1, 3))
        ..selectTime('16:00')
        ..updateNote('Fokus area dapur');

      final isSameDay = await controller.createOrder(
        booking: booking,
        addresses: addresses,
        orders: orders,
        method: paymentMethodByType(PaymentMethodType.qris),
        totalPayment: 'Rp102.500',
        servicePrice: 150000,
        platformFee: 5000,
        discountAmount: 52500,
        now: DateTime(2030, 1, 2),
      );

      final order = orders.scheduledOrder;
      expect(isSameDay, isFalse);
      expect(order.serviceName, 'Deep Cleaning');
      expect(order.destinationAddress, addresses.selectedAddress!.fullAddress);
      expect(order.scheduledAt, DateTime(2030, 1, 3, 16));
      expect(order.note, 'Fokus area dapur');
      expect(order.paymentMethod, 'QRIS');
      expect(order.servicePrice, 150000);
      expect(order.platformFee, 5000);
      expect(order.discountAmount, 52500);
      expect(order.stage, OrderStatusStage.dikonfirmasi);
      expect(
        order.arrivalEstimate,
        OrderStatusStage.dikonfirmasi.arrivalEstimate,
      );
      expect(
        order.travelDescription,
        OrderStatusStage.dikonfirmasi.travelDescription,
      );
    });

    test('marks a booking on the current date as same-day', () async {
      booking
        ..selectDate(DateTime(2030, 1, 2))
        ..selectTime('08:00');

      final isSameDay = await controller.createOrder(
        booking: booking,
        addresses: addresses,
        orders: orders,
        method: paymentMethodByType(PaymentMethodType.cash),
        totalPayment: 'Rp155.000',
        servicePrice: 150000,
        platformFee: 5000,
        discountAmount: 0,
        now: DateTime(2030, 1, 2, 7),
      );

      expect(isSameDay, isTrue);
      expect(orders.scheduledOrder.paymentMethod, 'Tunai');
    });
  });
}
