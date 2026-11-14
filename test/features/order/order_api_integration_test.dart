import 'dart:async';

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
  bool fail;
  int calls = 0;

  @override
  Future<List<CustomerBookingSummary>> fetchBookings() async {
    calls++;
    if (fail) throw StateError('jaringan mati');
    return bookings;
  }
}

class _OwnedTracking extends EtaRepository {
  DateTime? locationUpdatedAt = DateTime.now();
  int calls = 0;
  Future<EtaEstimate>? pendingResult;
  @override
  Future<EtaEstimate> calculateForBooking(String id) async {
    calls++;
    if (pendingResult != null) return pendingResult!;
    return EtaEstimate(
      distanceMeters: 1200,
      baselineEtaSeconds: 121,
      etaSeconds: 121,
      etaMinutes: 3,
      source: 'osrm',
      modelVersion: null,
      updatedAt: DateTime.now(),
      locationUpdatedAt: locationUpdatedAt,
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
  int? cleanerCompletedBookings,
  String recipientName = '',
  String recipientPhone = '',
  String? paymentStatus,
  String paymentMethod = '',
  double? latitude = -7.98,
  double? longitude = 112.63,
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
  latitude: latitude,
  longitude: longitude,
  reviewEditable: reviewEditable,
  hasReview: hasReview,
  reviewRating: reviewRating,
  reviewComment: reviewComment,
  cleanerName: cleanerName,
  cleanerCompletedBookings: cleanerCompletedBookings,
  recipientName: recipientName,
  recipientPhone: recipientPhone,
  paymentStatus: paymentStatus,
  paymentMethod: paymentMethod,
);

void main() {
  test('unpaid bookings stay resumable, never counted as confirmed', () async {
    final api = _FakeBookingApi(
      bookings: [
        _booking(code: 'pending', status: 'Menunggu Pembayaran'),
        _booking(
          code: 'link',
          status: 'Menunggu Pembayaran',
          paymentStatus: 'pending',
          paymentMethod: 'qris',
        ),
        _booking(
          code: 'expired',
          status: 'Menunggu Pembayaran',
          paymentStatus: 'expired',
          paymentMethod: 'qris',
        ),
        _booking(
          code: 'paid',
          status: 'Menunggu Assign',
          paymentStatus: 'paid',
          paymentMethod: 'qris',
        ),
        _booking(
          code: 'cash',
          status: 'Menunggu Assign',
          paymentStatus: 'pending',
          paymentMethod: 'cash',
        ),
      ],
    );
    final controller = OrderController(bookingApi: api);
    addTearDown(controller.dispose);
    await controller.loadFromApi();
    expect(controller.pendingPayments.map((booking) => booking.id), [
      'pending',
      'link',
      'expired',
    ]);
    expect(
      controller.scheduledOrders.map((order) => order.backendBookingId).toSet(),
      {'paid', 'cash'},
    );
  });

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
        'cleanerCompletedBookings': 5,
        'latitude': -7.98,
        'longitude': 112.63,
      });

      expect(booking.id, '77');
      expect(booking.code, 'CG-TEST');
      expect(booking.cleanerCompletedBookings, 5);
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
    test(
      'hides failed or unverified QRIS but keeps cash and paid QRIS',
      () async {
        final controller = OrderController(
          bookingApi: _FakeBookingApi(
            bookings: [
              for (final status in <String?>['failed', 'pending', null])
                _booking(
                  code: 'unpaid-$status',
                  status: 'Menunggu Assign',
                  paymentMethod: 'qris',
                  paymentStatus: status,
                ),
              _booking(
                code: 'checkout-not-started',
                status: 'Menunggu Pembayaran',
              ),
              _booking(
                code: 'cash',
                status: 'Menunggu Assign',
                paymentMethod: 'cash',
                paymentStatus: 'pending',
              ),
              _booking(
                code: 'paid',
                status: 'Menunggu Assign',
                paymentMethod: 'qris',
                paymentStatus: 'paid',
              ),
            ],
          ),
        );
        await controller.loadFromApi();
        expect(
          controller.scheduledOrders.map((order) => order.orderNumber),
          unorderedEquals(['#cash', '#paid']),
        );
        controller.dispose();
      },
    );
    test(
      'hides pending non-cash orders without changing status or history',
      () async {
        final controller = OrderController(
          bookingApi: _FakeBookingApi(
            bookings: [
              _booking(
                code: 'pending-qris',
                status: 'Menunggu Assign',
                paymentStatus: 'pending',
                paymentMethod: 'qris',
              ),
              _booking(
                code: 'pending-other',
                status: 'Menunggu Assign',
                paymentStatus: 'pending',
                paymentMethod: 'gopay',
              ),
              _booking(
                code: 'pending-unknown',
                status: 'Menunggu Assign',
                paymentStatus: 'pending',
              ),
              _booking(
                code: 'pending-cash',
                status: 'Menunggu Assign',
                paymentStatus: 'pending',
                paymentMethod: 'cash',
              ),
              _booking(
                code: 'pending-uppercase-cash',
                status: 'Menunggu Assign',
                paymentStatus: 'pending',
                paymentMethod: 'CASH',
              ),
              _booking(
                code: 'paid-qris',
                status: 'Menuju Lokasi',
                paymentStatus: 'paid',
                paymentMethod: 'qris',
              ),
              _booking(
                code: 'expired-qris',
                status: 'Menunggu Assign',
                paymentStatus: 'expired',
                paymentMethod: 'qris',
              ),
              _booking(
                code: 'cancelled-pending',
                status: 'Batal',
                paymentStatus: 'pending',
                paymentMethod: 'qris',
              ),
            ],
          ),
        );
        addTearDown(controller.dispose);

        await controller.loadFromApi();

        final orders = controller.scheduledOrders;
        expect(
          orders.map((order) => order.orderNumber),
          unorderedEquals([
            '#pending-cash',
            '#pending-uppercase-cash',
            '#paid-qris',
          ]),
        );
        final cash = orders.firstWhere(
          (order) => order.orderNumber == '#pending-cash',
        );
        expect(cash.stage, OrderStatusStage.dikonfirmasi);
        expect(cash.status, 'PESANAN DIKONFIRMASI');
        expect(cash.paymentStatus, 'Menunggu pembayaran');
        final paid = orders.firstWhere(
          (order) => order.orderNumber == '#paid-qris',
        );
        expect(paid.stage, OrderStatusStage.dalamPerjalanan);
        expect(paid.status, 'CLEANER MENUJU LOKASI');
        expect(paid.paymentStatus, 'Lunas');
        expect(controller.historyOrders.single.orderId, '#cancelled-pending');
        expect(controller.historyOrders.single.status, 'BATAL');
      },
    );

    test(
      'polling removes unpaid selection and restores it after payment',
      () async {
        final bookings = [
          _booking(
            code: 'qris',
            status: 'Menunggu Assign',
            paymentStatus: 'paid',
            paymentMethod: 'qris',
          ),
        ];
        final controller = OrderController(
          bookingApi: _FakeBookingApi(bookings: bookings),
        );
        addTearDown(controller.dispose);
        await controller.loadFromApi();
        expect(controller.selectScheduledOrder('#qris'), isTrue);

        bookings[0] = _booking(
          code: 'qris',
          status: 'Menunggu Assign',
          paymentStatus: 'pending',
          paymentMethod: 'qris',
        );
        await controller.loadFromApi();
        expect(controller.scheduledOrders, isEmpty);
        expect(controller.hasScheduledOrder, isFalse);
        expect(controller.selectScheduledOrder('#qris'), isFalse);
        expect(controller.historyOrders, isEmpty);

        bookings[0] = _booking(
          code: 'qris',
          status: 'Menunggu Assign',
          paymentStatus: 'paid',
          paymentMethod: 'qris',
        );
        await controller.loadFromApi();
        expect(controller.hasScheduledOrder, isTrue);
        expect(controller.scheduledOrders.single.orderNumber, '#qris');
        expect(controller.scheduledOrder.orderNumber, '#qris');
      },
    );

    test(
      'status polling keeps the selected order and its last GPS estimate',
      () async {
        final api = _FakeBookingApi(
          bookings: [
            _booking(code: '9', status: 'Menuju Lokasi'),
            _booking(code: '10', status: 'Menuju Lokasi'),
          ],
        );
        final controller = OrderController(
          bookingApi: api,
          etaRepository: _OwnedTracking(),
        );
        addTearDown(controller.dispose);
        await controller.loadFromApi();
        controller.selectScheduledOrder('#9');
        await controller.refreshEta();
        final updatedAt = controller.scheduledOrder.etaUpdatedAt;
        await controller.loadFromApi();
        expect(controller.scheduledOrder.orderNumber, '#9');
        expect(controller.etaAvailable, isTrue);
        expect(controller.scheduledOrder.etaUpdatedAt, updatedAt);
        expect(controller.scheduledOrder.cleanerLatitude, -7.97);
      },
    );

    test(
      'partial tracking keeps GPS and clears previous route and ETA',
      () async {
        final tracking = _OwnedTracking();
        final controller = OrderController(
          bookingApi: _FakeBookingApi(
            bookings: [_booking(code: '9', status: 'Menuju Lokasi')],
          ),
          etaRepository: tracking,
        );
        addTearDown(controller.dispose);
        await controller.loadFromApi();
        await controller.refreshEta();
        expect(controller.etaAvailable, isTrue);
        tracking.pendingResult = Future.value(
          EtaEstimate(
            distanceMeters: 0,
            baselineEtaSeconds: 0,
            etaSeconds: 0,
            etaMinutes: 0,
            source: '',
            modelVersion: null,
            updatedAt: DateTime.now(),
            locationUpdatedAt: DateTime.now(),
            path: const [],
            cleanerLatitude: -7.96,
            cleanerLongitude: 112.62,
            routeStatus: 'unavailable',
            routeMessage: 'Rute belum tersedia',
          ),
        );
        await controller.refreshEta();
        expect(controller.scheduledOrder.hasCleanerCoordinates, isTrue);
        expect(controller.scheduledOrder.cleanerLatitude, -7.96);
        expect(controller.scheduledOrder.routePoints, isEmpty);
        expect(controller.scheduledOrder.etaUpdatedAt, isNull);
        expect(controller.etaAvailable, isFalse);
        expect(controller.etaLoading, isFalse);
        expect(controller.etaHeadline, 'ETA belum tersedia');
        expect(controller.etaError, 'Rute belum tersedia');
      },
    );

    test('route recalculation cannot make old GPS live', () async {
      final tracking = _OwnedTracking()
        ..locationUpdatedAt = DateTime.now().subtract(
          const Duration(minutes: 6),
        );
      final controller = OrderController(
        bookingApi: _FakeBookingApi(
          bookings: [_booking(code: '9', status: 'Menuju Lokasi')],
        ),
        etaRepository: tracking,
      );
      addTearDown(controller.dispose);
      await controller.loadFromApi();
      await controller.refreshEta();
      expect(controller.scheduledOrder.hasCleanerCoordinates, isTrue);
      expect(controller.etaAvailable, isFalse);
      expect(controller.etaHeadline, 'Lokasi cleaner sudah usang');
      expect(controller.etaMinutesLabel, 'Belum tersedia');
      final gpsTime = controller.scheduledOrder.locationUpdatedAt;
      await controller.loadFromApi();
      expect(controller.scheduledOrder.locationUpdatedAt, gpsTime);
      expect(controller.etaAvailable, isFalse);
      tracking.locationUpdatedAt = DateTime.now();
      await controller.refreshEta();
      expect(controller.etaAvailable, isTrue);
    });

    test(
      'an ETA response remains valid when status polling keeps the same trip',
      () async {
        final pending = Completer<EtaEstimate>();
        final tracking = _OwnedTracking()..pendingResult = pending.future;
        final api = _FakeBookingApi(
          bookings: [_booking(code: '9', status: 'Menuju Lokasi')],
        );
        final controller = OrderController(
          bookingApi: api,
          etaRepository: tracking,
        );
        addTearDown(controller.dispose);
        await controller.loadFromApi();
        final refresh = controller.refreshEta();
        await controller.loadFromApi();
        pending.complete(
          EtaEstimate(
            distanceMeters: 1200,
            baselineEtaSeconds: 121,
            etaSeconds: 121,
            etaMinutes: 3,
            source: 'osrm',
            modelVersion: null,
            updatedAt: DateTime.now(),
            locationUpdatedAt: DateTime.now(),
            path: const [],
            cleanerLatitude: -7.97,
            cleanerLongitude: 112.61,
          ),
        );
        await refresh;
        expect(controller.etaAvailable, isTrue);
      },
    );

    test('status polling removes an active order when the server reports completion', () async {
      final bookings = [_booking(code: '9', status: 'Menuju Lokasi')];
      final controller = OrderController(
        bookingApi: _FakeBookingApi(bookings: bookings),
        etaRepository: _OwnedTracking(),
      );
      addTearDown(controller.dispose);
      await controller.loadFromApi();
      bookings[0] = _booking(code: '9', status: 'Selesai');
      await controller.loadFromApi();
      expect(controller.hasScheduledOrder, isFalse);
      expect(controller.currentStage, OrderStatusStage.selesai);
      expect(controller.historyOrders.single.orderId, '#9');
    });
    test(
      'owned booking tracking fetches GPS even without destination coordinates',
      () async {
        final tracking = _OwnedTracking();
        final controller = OrderController(
          bookingApi: _FakeBookingApi(
            bookings: [
              _booking(
                code: '9',
                status: 'Menuju Lokasi',
                latitude: null,
                longitude: null,
              ),
            ],
          ),
          etaRepository: tracking,
        );
        addTearDown(controller.dispose);
        await controller.loadFromApi();
        expect(controller.scheduledOrder.hasDestinationCoordinates, isFalse);
        await controller.refreshEta();
        expect(tracking.calls, 1);
        expect(controller.scheduledOrder.hasCleanerCoordinates, isTrue);
        expect(controller.scheduledOrder.cleanerLatitude, -7.97);
      },
    );

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
            cleanerCompletedBookings: 2,
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
      expect(controller.scheduledOrder.cleanerCompletedBookings, 2);
      expect(controller.historyOrders.first.customerName, 'Timothy');
    });

    test(
      'respons kosong sukses membersihkan daftar aktif dan riwayat',
      () async {
        final controller = OrderController(bookingApi: _FakeBookingApi());

        await controller.loadFromApi();

        expect(controller.scheduledOrders, isEmpty);
        expect(controller.historyOrders, isEmpty);
      },
    );

    test('daftar aktif dan riwayat awal kosong saat API terpasang', () async {
      final controller = OrderController(bookingApi: _FakeBookingApi());

      expect(controller.scheduledOrders, isEmpty);
      expect(controller.historyOrders, isEmpty);
    });

    test('gagal awal tetap kosong', () async {
      final controller = OrderController(
        bookingApi: _FakeBookingApi(fail: true),
      );

      await controller.loadFromApi();

      expect(controller.scheduledOrders, isEmpty);
      expect(controller.historyOrders, isEmpty);
    });

    test('data sukses dipertahankan saat reload gagal', () async {
      final api = _FakeBookingApi(
        bookings: [_booking(code: 'CG-1', status: 'Selesai')],
      );
      final controller = OrderController(bookingApi: api);

      await controller.loadFromApi();
      expect(controller.historyOrders, hasLength(1));

      api.fail = true;
      await controller.loadFromApi();

      expect(controller.historyOrders, hasLength(1));
      expect(controller.historyOrders.first.orderId, '#CG-1');
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
