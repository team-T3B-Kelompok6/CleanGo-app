import 'package:cleango_app/features/address/controllers/address_controller.dart';
import 'package:cleango_app/features/address/domain/models/address_model.dart';
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
      expect(order.hasDestinationCoordinates, isTrue);
      expect(order.arrivalEstimate, contains('16:00 WIB'));
      expect(order.arrivalEstimate, isNot(contains('09:10')));
      expect(order.travelDescription, 'Menunggu cleaner ditugaskan.');
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

    test(
      'keeps the address chosen for this booking on the order and map',
      () async {
        const bookingAddress = AddressModel(
          id: 'booking-address',
          title: 'Jl. Ijen No. 10',
          fullAddress: 'Jl. Ijen No. 10, Klojen, Kota Malang',
          note: 'Pagar hijau',
          type: 'Rumah',
          contactName: 'Krisna',
          phoneNumber: '(+62) 81234567890',
          isPrimary: true,
          latitude: -7.9717,
          longitude: 112.6219,
        );
        const anotherAddress = AddressModel(
          id: 'another-address',
          title: 'Alamat lain',
          fullAddress: 'Jl. Alamat Lain No. 1',
          type: 'Kantor',
          contactName: 'Orang lain',
          phoneNumber: '(+62) 81111111111',
          latitude: -6.2,
          longitude: 106.8,
        );
        addresses.dispose();
        addresses = AddressController(
          initialAddresses: const [bookingAddress, anotherAddress],
        );
        booking.updateAddress(
          bookingAddress.toCleaningAddress(),
          addressId: bookingAddress.id,
        );
        addresses.selectAddress(anotherAddress.id);

        await controller.createOrder(
          booking: booking,
          addresses: addresses,
          orders: orders,
          method: paymentMethodByType(PaymentMethodType.qris),
          totalPayment: 'Rp155.000',
          servicePrice: 150000,
          platformFee: 5000,
          discountAmount: 0,
          now: DateTime(2030, 1, 2),
        );

        final order = orders.scheduledOrder;
        expect(order.destinationAddress, bookingAddress.fullAddress);
        expect(order.destinationSubAddress, bookingAddress.note);
        expect(order.destinationLatitude, bookingAddress.latitude);
        expect(order.destinationLongitude, bookingAddress.longitude);
        expect(order.hasDestinationCoordinates, isTrue);
        expect(order.customerName, bookingAddress.contactName);
        expect(order.customerPhone, bookingAddress.phoneNumber);
      },
    );
  });
}
