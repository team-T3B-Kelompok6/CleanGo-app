import 'package:cleango_app/features/booking/data/customer_booking_api.dart';
import 'package:cleango_app/features/order/controllers/order_controller.dart';
import 'package:cleango_app/features/order/data/order_data.dart';
import 'package:cleango_app/features/order/domain/models/order_model.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeBookingApi extends CustomerBookingApi {
  _FakeBookingApi({this.bookings = const [], this.fail = false});

  final List<CustomerBookingSummary> bookings;
  final bool fail;
  int calls = 0;

  @override
  Future<List<CustomerBookingSummary>> fetchBookings() async {
    calls++;
    if (fail) throw StateError('jaringan mati');
    return bookings;
  }
}

CustomerBookingSummary _booking({
  required String code,
  required String status,
  String time = '10:00',
  int total = 105000,
}) => CustomerBookingSummary(
  id: code,
  code: code,
  date: '2026-10-25',
  time: time,
  service: 'Basic Home Cleaning',
  servicePrice: 100000,
  platformFee: 5000,
  discountAmount: 0,
  totalAmount: total,
  status: status,
  notes: 'catatan',
  address: 'Jl. Uji No. 1, Malang',
  latitude: -7.98,
  longitude: 112.63,
);

void main() {
  group('CustomerBookingSummary', () {
    test('parses the backend payload', () {
      final booking = CustomerBookingSummary.fromJson({
        'id': 77,
        'code': 'CG-TEST',
        'date': '2026-10-25',
        'time': '14:00',
        'service': 'Sofa Cleaning',
        'servicePrice': 150000,
        'platformFee': 5000,
        'discountAmount': 20000,
        'totalAmount': 135000,
        'status': 'Menunggu Assign',
        'notes': 'bawa vacuum',
        'address': 'Jl. A, Malang',
        'latitude': -7.98,
        'longitude': 112.63,
      });

      expect(booking.id, '77');
      expect(booking.code, 'CG-TEST');
      expect(booking.totalAmount, 135000);
      expect(booking.isFinished, isFalse);
      expect(booking.scheduledAt, DateTime(2026, 10, 25, 14));
    });

    test('flags finished bookings', () {
      expect(_booking(code: 'A', status: 'Selesai').isFinished, isTrue);
      expect(_booking(code: 'B', status: 'Batal').isFinished, isTrue);
      expect(_booking(code: 'C', status: 'Menuju Lokasi').isFinished, isFalse);
    });
  });

  group('OrderController.loadFromApi', () {
    test('maps active bookings into scheduled orders', () async {
      final api = _FakeBookingApi(
        bookings: [
          _booking(code: 'CG-1', status: 'Menunggu Assign', time: '10:00'),
          _booking(code: 'CG-2', status: 'Sedang Dikerjakan', time: '14:00'),
        ],
      );
      final controller = OrderController(bookingApi: api);

      await controller.loadFromApi();

      expect(api.calls, 1);
      final orders = controller.scheduledOrders;
      expect(orders.length, 2);
      expect(orders.map((o) => o.orderNumber), containsAll(['#CG-1', '#CG-2']));
      expect(orders.first.price, 'Rp105.000');
      expect(controller.currentStage, OrderStatusStage.sedangDikerjakan);
    });

    test('maps finished bookings into history', () async {
      final api = _FakeBookingApi(
        bookings: [_booking(code: 'CG-9', status: 'Selesai')],
      );
      final controller = OrderController(bookingApi: api);

      await controller.loadFromApi();

      expect(controller.historyOrders.length, 1);
      expect(controller.historyOrders.first.orderId, '#CG-9');
      expect(controller.historyOrders.first.status, 'SELESAI');
      expect(controller.historyOrders.first.canReview, isTrue);
    });

    test('keeps the demo orders when the backend returns nothing', () async {
      final controller = OrderController(bookingApi: _FakeBookingApi());

      await controller.loadFromApi();

      expect(controller.scheduledOrders.length, 1);
      expect(controller.scheduledOrder.orderNumber, OrderData.scheduledOrder.orderNumber);
      expect(controller.historyOrders.length, OrderData.history.length);
    });

    test('keeps the demo orders when the request fails', () async {
      final controller = OrderController(bookingApi: _FakeBookingApi(fail: true));

      await controller.loadFromApi();

      expect(controller.scheduledOrder.orderNumber, OrderData.scheduledOrder.orderNumber);
    });

    test('does nothing without a configured api', () async {
      final controller = OrderController();

      await controller.loadFromApi();

      expect(controller.scheduledOrder.orderNumber, OrderData.scheduledOrder.orderNumber);
    });
  });
}
