import 'package:cleango_app/core/network/api_config.dart';
import 'package:cleango_app/features/booking/data/customer_booking_api.dart';
import 'package:cleango_app/features/order/controllers/order_controller.dart';
import 'package:cleango_app/features/order/data/order_data.dart';
import 'package:cleango_app/features/order/data/eta_repository.dart';
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

class _OwnedTracking extends EtaRepository {
  int calls = 0;
  @override
  Future<EtaEstimate> calculateForBooking(String id) async {
    calls++;
    return EtaEstimate(
      distanceMeters: 1200,
      baselineEtaSeconds: 121,
      etaSeconds: 121,
      etaMinutes: 3,
      source: 'osrm',
      modelVersion: null,
      updatedAt: DateTime.now(),
      path: const [],
      cleanerLatitude: -7.97,
      cleanerLongitude: 112.61,
    );
  }

  @override
  Future<EtaEstimate> calculate({
    required double cleanerLatitude,
    required double cleanerLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
  }) => throw StateError('Real bookings must not use preview coordinates');
  @override
  void dispose() {}
}

CustomerBookingSummary _booking({
  required String code,
  required String status,
  String time = '10:00',
  int total = 105000,
  bool reviewEditable = false,
  bool hasReview = false,
  int? reviewRating,
  String reviewComment = '',
  String cleanerName = '',
  String recipientName = '',
  String recipientPhone = '',
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
  reviewEditable: reviewEditable,
  hasReview: hasReview,
  reviewRating: reviewRating,
  reviewComment: reviewComment,
  cleanerName: cleanerName,
  recipientName: recipientName,
  recipientPhone: recipientPhone,
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
        'serviceDurationMinutes': 120,
        'startedAt': '2026-10-25T07:00:00.000Z',
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
      expect(booking.serviceDurationMinutes, 120);
      expect(
        booking.startedAt,
        DateTime.parse('2026-10-25T07:00:00.000Z').toLocal(),
      );
      expect(booking.isFinished, isFalse);
      expect(booking.scheduledAt, DateTime(2026, 10, 25, 14));
    });

    test('parses review photos with their ids for editing', () {
      final booking = CustomerBookingSummary.fromJson({
        'id': 77,
        'code': 'CG-TEST',
        'date': '2026-10-25',
        'time': '14:00',
        'service': 'Sofa Cleaning',
        'servicePrice': 150000,
        'platformFee': 5000,
        'discountAmount': 0,
        'totalAmount': 155000,
        'status': 'Selesai',
        'notes': '',
        'address': 'Jl. A, Malang',
        'hasReview': true,
        'reviewPhotos': [
          {'id': '4', 'url': '/uploads/review-photos/a.jpg'},
        ],
      });

      expect(booking.reviewPhotos, hasLength(1));
      expect(booking.reviewPhotos.first.id, '4');
      expect(
        booking.reviewPhotos.first.url,
        '${ApiConfig.baseUrl}/uploads/review-photos/a.jpg',
      );
    });

    test('flags finished bookings', () {
      expect(_booking(code: 'A', status: 'Selesai').isFinished, isTrue);
      expect(_booking(code: 'B', status: 'Batal').isFinished, isTrue);
      expect(_booking(code: 'C', status: 'Menuju Lokasi').isFinished, isFalse);
    });
  });

  group('OrderController.loadFromApi', () {
    test('owned bookings wait for departure and use saved GPS instead of demo positions', () async {
      final tracking = _OwnedTracking();
      final api = _FakeBookingApi(
        bookings: [_booking(code: '9', status: 'Menunggu Lokasi')],
      );
      final controller = OrderController(
        bookingApi: api,
        etaRepository: tracking,
      );
      addTearDown(controller.dispose);
      await controller.loadFromApi();
      expect(controller.scheduledOrder.backendBookingId, '9');
      expect(controller.scheduledOrder.hasCleanerCoordinates, isFalse);
      expect(controller.canCalculateEta, isFalse);
      await controller.refreshEta();
      expect(tracking.calls, 0);
    });

    test('in-transit owned booking reads real GPS and cannot be moved by demo controls', () async {
      final tracking = _OwnedTracking();
      final controller = OrderController(
        etaRepository: tracking,
        bookingApi: _FakeBookingApi(
          bookings: [_booking(code: '9', status: 'Menuju Lokasi')],
        ),
      );
      addTearDown(controller.dispose);
      await controller.loadFromApi();
      await controller.refreshEta();
      expect(tracking.calls, 1);
      expect(controller.scheduledOrder.hasCleanerCoordinates, isTrue);
      expect(controller.scheduledOrder.cleanerLatitude, -7.97);
      await controller.updateCleanerLocation(0, 0);
      expect(controller.scheduledOrder.cleanerLatitude, -7.97);
      expect(tracking.calls, 1);
      controller.setStage(OrderStatusStage.sedangDikerjakan);
      controller.completeScheduledOrder();
      expect(controller.currentStage, OrderStatusStage.dalamPerjalanan);
      expect(controller.estimatedWorkCompletedAt, isNull);
      expect(controller.hasScheduledOrder, isTrue);
    });
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
        bookings: [
          _booking(
            code: 'CG-9',
            status: 'Selesai',
            reviewEditable: true,
            cleanerName: 'Budi Santoso',
            recipientName: 'Timothy',
            recipientPhone: '082140636747',
          ),
        ],
      );
      final controller = OrderController(bookingApi: api);

      await controller.loadFromApi();

      expect(controller.historyOrders.length, 1);
      expect(controller.historyOrders.first.orderId, '#CG-9');
      expect(controller.historyOrders.first.status, 'SELESAI');
      expect(controller.historyOrders.first.canReview, isTrue);
      expect(controller.historyOrders.first.hasReview, isFalse);
      expect(controller.historyOrders.first.cleanerName, 'Budi Santoso');
      expect(controller.historyOrders.first.customerName, 'Timothy');
    });

    test('keeps the demo orders when the backend returns nothing', () async {
      final controller = OrderController(bookingApi: _FakeBookingApi());

      await controller.loadFromApi();

      expect(controller.scheduledOrders.length, 1);
      expect(
        controller.scheduledOrder.orderNumber,
        OrderData.scheduledOrder.orderNumber,
      );
      expect(controller.historyOrders.length, OrderData.history.length);
    });

    test('keeps the demo orders when the request fails', () async {
      final controller = OrderController(
        bookingApi: _FakeBookingApi(fail: true),
      );

      await controller.loadFromApi();

      expect(
        controller.scheduledOrder.orderNumber,
        OrderData.scheduledOrder.orderNumber,
      );
    });

    test('does nothing without a configured api', () async {
      final controller = OrderController();

      await controller.loadFromApi();

      expect(
        controller.scheduledOrder.orderNumber,
        OrderData.scheduledOrder.orderNumber,
      );
    });
  });
}
