import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:cleango_app/features/order/controllers/order_controller.dart';
import 'package:cleango_app/features/order/data/eta_repository.dart';
import 'package:cleango_app/features/order/domain/models/order_model.dart';
import 'package:cleango_app/features/service/controllers/service_controller.dart';

class FakeEtaRepository extends EtaRepository {
  int calls = 0;
  Future<EtaEstimate>? pendingResult;

  @override
  Future<EtaEstimate> calculate({
    required double cleanerLatitude,
    required double cleanerLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
  }) async {
    calls += 1;
    if (pendingResult != null) return pendingResult!;
    return EtaEstimate(
      distanceMeters: calls == 1 ? 4200 : 2100,
      baselineEtaSeconds: calls == 1 ? 720 : 360,
      etaSeconds: calls == 1 ? 720 : 360,
      etaMinutes: calls == 1 ? 12 : 6,
      source: 'osrm',
      modelVersion: null,
      updatedAt: DateTime(2026, 10, 16, 9),
      path: const [
        RoutePoint(latitude: -7.97, longitude: 112.61),
        RoutePoint(latitude: -7.94, longitude: 112.62),
      ],
    );
  }

  @override
  void dispose() {}
}

void main() {
  group('OrderController Tests', () {
    test('work completion uses actual start plus service duration without marking the order finished', () {
      final tracking = OrderController(etaRepository: FakeEtaRepository());
      addTearDown(tracking.dispose);
      tracking.createOrderFromBooking(
        serviceName: 'Layanan uji',
        serviceImagePath: 'assets/images/service_deep_cleaning.jpeg',
        price: 'Rp100.000',
        address: 'Alamat uji',
        serviceDurationMinutes: 120,
      );
      expect(tracking.estimatedWorkCompletedAt, isNull);
      tracking.setStage(OrderStatusStage.sedangDikerjakan);
      final start = tracking.scheduledOrder.workStartedAt!;
      expect(
        tracking.estimatedWorkCompletedAt,
        start.add(const Duration(minutes: 120)),
      );
      expect(tracking.etaCardTitle, 'Perkiraan Selesai');
      expect(
        tracking.stageTimeLabel(OrderStatusStage.selesai),
        startsWith('Estimasi'),
      );
      expect(tracking.currentStage, OrderStatusStage.sedangDikerjakan);
      tracking.setStage(OrderStatusStage.selesai);
      expect(tracking.estimatedWorkCompletedAt, isNull);
    });
    test('does not invent a duration for a service without SOP', () {
      final tracking = OrderController(etaRepository: FakeEtaRepository());
      addTearDown(tracking.dispose);
      tracking.setStage(OrderStatusStage.sedangDikerjakan);
      expect(tracking.estimatedWorkCompletedAt, isNull);
      expect(tracking.etaMinutesLabel, 'Belum tersedia');
    });
    late OrderController controller;

    setUp(() {
      controller = OrderController();
    });

    tearDown(() => controller.dispose());

    String addOrder(String serviceName, {int days = 3}) {
      controller.createOrderFromBooking(
        serviceName: serviceName,
        serviceImagePath: 'assets/images/service_deep_cleaning.jpeg',
        price: 'Rp155.000',
        address: 'Alamat $serviceName',
        scheduledAt: DateTime.now().add(Duration(days: days)),
        note: 'Catatan $serviceName',
      );
      return controller.scheduledOrder.orderNumber;
    }

    test(
      'keeps multiple active orders with unique IDs and independent stages',
      () {
        controller.completeScheduledOrder();
        final firstId = addOrder('Pesanan pertama');
        controller.setStage(OrderStatusStage.ditugaskan);
        final departureTime = controller.stageTimeLabel(
          OrderStatusStage.ditugaskan,
        );
        final secondId = addOrder('Pesanan kedua', days: 4);

        expect(firstId, isNot(secondId));
        expect(controller.scheduledOrders.map((order) => order.orderNumber), [
          secondId,
          firstId,
        ]);
        expect(controller.currentStage, OrderStatusStage.dikonfirmasi);
        expect(controller.selectScheduledOrder(firstId), isTrue);
        expect(controller.currentStage, OrderStatusStage.ditugaskan);
        expect(controller.scheduledOrder.note, 'Catatan Pesanan pertama');
        expect(
          controller.stageTimeLabel(OrderStatusStage.ditugaskan),
          departureTime,
        );
        expect(controller.selectScheduledOrder('unknown'), isFalse);
        expect(controller.scheduledOrder.orderNumber, firstId);
        expect(controller.selectScheduledOrder(secondId), isTrue);
        expect(controller.currentStage, OrderStatusStage.dikonfirmasi);
        expect(
          controller.stageTimeLabel(OrderStatusStage.ditugaskan),
          'Menunggu',
        );
      },
    );

    test('rescheduling and cancelling one order preserves the others', () {
      controller.completeScheduledOrder();
      final firstId = addOrder('Pesanan pertama');
      final secondId = addOrder('Pesanan kedua', days: 4);
      final secondSchedule = controller.scheduledOrder.scheduledAt;

      controller.selectScheduledOrder(firstId);
      final newSchedule = DateTime.now().add(const Duration(days: 7));
      expect(controller.rescheduleOrder(newSchedule), isTrue);
      expect(controller.scheduledOrder.scheduledAt, newSchedule);
      expect(controller.cancelScheduledOrder(), isTrue);
      expect(controller.hasScheduledOrder, isTrue);
      expect(controller.scheduledOrders.single.orderNumber, secondId);
      expect(controller.selectScheduledOrder(firstId), isFalse);
      expect(controller.historyOrders.first.orderId, firstId);
      expect(controller.historyOrders.first.status, 'DIBATALKAN');
      expect(controller.historyOrders.first.canReview, isFalse);
      expect(controller.selectScheduledOrder(secondId), isTrue);
      expect(controller.scheduledOrder.scheduledAt, secondSchedule);
    });

    test('completing and reviewing one order leaves the other active', () {
      controller.completeScheduledOrder();
      final firstId = addOrder('Pesanan pertama');
      final secondId = addOrder('Pesanan kedua');
      controller.selectScheduledOrder(firstId);
      controller.completeScheduledOrder();
      controller.completeScheduledOrder();

      expect(controller.scheduledOrder.orderNumber, firstId);
      expect(controller.currentStage, OrderStatusStage.selesai);
      expect(controller.scheduledOrders.single.orderNumber, secondId);
      expect(controller.hasScheduledOrder, isTrue);
      expect(
        controller.historyOrders.where((order) => order.orderId == firstId),
        hasLength(1),
      );
      expect(
        controller.submitReview(
          orderId: firstId,
          rating: 4,
          tags: [],
          comment: 'Pekerjaan rapi',
        ),
        isTrue,
      );
      expect(controller.selectScheduledOrder(secondId), isTrue);
      expect(controller.currentStage, OrderStatusStage.dikonfirmasi);
      expect(controller.scheduledOrder.note, 'Catatan Pesanan kedua');
    });

    test('a late ETA response cannot update another selected order', () async {
      final repository = FakeEtaRepository();
      final pending = Completer<EtaEstimate>();
      repository.pendingResult = pending.future;
      final tracking = OrderController(etaRepository: repository);
      addTearDown(tracking.dispose);
      tracking.setStage(OrderStatusStage.ditugaskan);
      final firstId = tracking.scheduledOrder.orderNumber;
      final request = tracking.refreshEta();

      tracking.createOrderFromBooking(
        serviceName: 'Pesanan kedua',
        serviceImagePath: 'assets/images/service_deep_cleaning.jpeg',
        price: 'Rp155.000',
        address: 'Alamat kedua',
        destinationLatitude: -7.94,
        destinationLongitude: 112.62,
      );
      tracking.setStage(OrderStatusStage.ditugaskan);
      pending.complete(
        EtaEstimate(
          distanceMeters: 4200,
          baselineEtaSeconds: 900,
          etaSeconds: 720,
          etaMinutes: 12,
          source: 'osrm',
          modelVersion: null,
          updatedAt: DateTime.now(),
          path: const [],
        ),
      );
      await request;

      expect(tracking.scheduledOrder.estimatedMinutes, 'Belum tersedia');
      expect(tracking.etaLoading, isFalse);
      expect(tracking.selectScheduledOrder(firstId), isTrue);
      expect(tracking.currentStage, OrderStatusStage.ditugaskan);
      expect(tracking.etaLoading, isFalse);
    });

    test('initial scheduled order waits for departure without a dummy ETA', () {
      expect(controller.currentStage, OrderStatusStage.dikonfirmasi);
      expect(controller.currentStepNumber, 1);
      expect(controller.currentStepLabel, 'Langkah 1 dari 5');
      expect(controller.scheduledOrder.orderNumber, '#CG-82910');
      expect(controller.scheduledOrder.cleanerName, 'Siti Rahmawati');
      expect(controller.etaAvailable, isFalse);
      expect(controller.scheduledOrder.estimatedMinutes, 'Belum tersedia');
      expect(
        controller.stageTimeLabel(OrderStatusStage.ditugaskan),
        'Menunggu',
      );
    });

    test('setStage updates progress, status text, and step label correctly across all 5 stages', () {
      // 1. Dikonfirmasi
      controller.setStage(OrderStatusStage.dikonfirmasi);
      expect(controller.currentStage, OrderStatusStage.dikonfirmasi);
      expect(controller.currentStepNumber, 1);
      expect(controller.currentStepLabel, 'Langkah 1 dari 5');
      expect(controller.scheduledOrder.progress, 0.2);

      // 2. Ditugaskan & Berangkat
      controller.setStage(OrderStatusStage.ditugaskan);
      expect(controller.currentStage, OrderStatusStage.ditugaskan);
      expect(controller.currentStepNumber, 2);
      expect(controller.currentStepLabel, 'Langkah 2 dari 5');
      expect(controller.scheduledOrder.progress, 0.4);

      // 3. Dalam Perjalanan
      controller.setStage(OrderStatusStage.dalamPerjalanan);
      expect(controller.currentStage, OrderStatusStage.dalamPerjalanan);
      expect(controller.currentStepNumber, 3);
      expect(controller.scheduledOrder.progress, 0.66);

      // 4. Sedang Dikerjakan
      controller.setStage(OrderStatusStage.sedangDikerjakan);
      expect(controller.currentStage, OrderStatusStage.sedangDikerjakan);
      expect(controller.currentStepNumber, 4);
      expect(controller.scheduledOrder.progress, 0.85);

      // 5. Selesai
      controller.setStage(OrderStatusStage.selesai);
      expect(controller.currentStage, OrderStatusStage.selesai);
      expect(controller.currentStepNumber, 5);
      expect(controller.currentStepLabel, 'Langkah 5 dari 5');
      expect(controller.scheduledOrder.progress, 1.0);
      expect(
        controller.stageTimeLabel(OrderStatusStage.selesai),
        startsWith('Selesai '),
      );
    });

    test('nextStage advances step sequentially and stops at selesai', () {
      controller.setStage(OrderStatusStage.dikonfirmasi);
      expect(controller.currentStepNumber, 1);

      controller.nextStage();
      expect(controller.currentStepNumber, 2);

      controller.nextStage();
      expect(controller.currentStepNumber, 3);

      controller.nextStage();
      expect(controller.currentStepNumber, 4);

      controller.nextStage();
      expect(controller.currentStepNumber, 5);
      expect(controller.currentStage, OrderStatusStage.selesai);

      // Should remain at stage 5 when nextStage called at the end
      controller.nextStage();
      expect(controller.currentStepNumber, 5);
      expect(controller.currentStage, OrderStatusStage.selesai);
    });

    test('createOrderFromBooking updates scheduled order data and resets stage to dikonfirmasi', () {
      controller.createOrderFromBooking(
        serviceName: 'Cuci & Perawatan AC',
        serviceImagePath: 'assets/images/service_ac_care.jpeg',
        price: 'Rp75.000',
        address: 'Jl. Sigura - Gura No. 12, Malang',
      );

      final order = controller.scheduledOrder;
      expect(order.serviceName, 'Cuci & Perawatan AC');
      expect(order.price, 'Rp75.000');
      expect(order.destinationAddress, 'Jl. Sigura - Gura No. 12, Malang');
      expect(order.stage, OrderStatusStage.dikonfirmasi);
      expect(controller.currentStepNumber, 1);
    });

    test(
      'ETA starts only after departure and updates from cleaner coordinates',
      () async {
        final repository = FakeEtaRepository();
        final trackingController = OrderController(etaRepository: repository);

        trackingController.setStage(OrderStatusStage.dikonfirmasi);
        await trackingController.refreshEta();
        expect(repository.calls, 0);
        expect(trackingController.etaAvailable, isFalse);
        expect(
          trackingController.etaHeadline,
          'ETA tersedia setelah cleaner berangkat',
        );

        trackingController.setStage(OrderStatusStage.ditugaskan);
        await trackingController.refreshEta();
        expect(repository.calls, 1);
        expect(trackingController.etaAvailable, isTrue);
        expect(trackingController.scheduledOrder.routePoints, hasLength(2));

        await trackingController.updateCleanerLocation(-7.95, 112.62);
        expect(repository.calls, 2);
        expect(trackingController.scheduledOrder.estimatedMinutes, '±6 menit');
        expect(trackingController.scheduledOrder.cleanerLatitude, -7.95);
        trackingController.dispose();
      },
    );

    test(
      'ETA stays unavailable when the selected address has no map point',
      () async {
        final repository = FakeEtaRepository();
        final trackingController = OrderController(etaRepository: repository);
        trackingController.createOrderFromBooking(
          serviceName: 'Deep Cleaning',
          serviceImagePath: 'assets/images/deep_cleaning.jpeg',
          price: 'Rp155.000',
          address: 'Alamat tanpa titik peta',
        );

        trackingController.setStage(OrderStatusStage.ditugaskan);
        await trackingController.refreshEta();

        expect(
          trackingController.scheduledOrder.hasDestinationCoordinates,
          isFalse,
        );
        expect(trackingController.canCalculateEta, isFalse);
        expect(repository.calls, 0);
        expect(trackingController.etaHeadline, 'Titik tujuan belum tersedia');
        trackingController.dispose();
      },
    );

    test('submitReview records review data and sets canReview to false on matching history item', () {
      final initialReviewable = controller.historyOrders.firstWhere(
        (o) => o.canReview,
      );
      expect(initialReviewable.canReview, true);

      controller.submitReview(
        orderId: initialReviewable.orderId,
        rating: 5,
        tags: ['Bersih Maksimal ✨', 'Tepat Waktu ⏰'],
        comment: 'Sangat bersih dan rapi!',
      );

      final updatedOrders = controller.historyOrders;
      final target = updatedOrders.firstWhere(
        (o) => o.serviceName == initialReviewable.serviceName,
      );
      expect(target.canReview, false);
      expect(target.rating, 5.0);
      expect(target.review, isNotNull);
      expect(target.review?.rating, 5);
      expect(target.review?.satisfactionTags, contains('Bersih Maksimal ✨'));
      expect(target.review?.comment, 'Sangat bersih dan rapi!');
    });

    test('Cuci AC history item is initially unreviewed (canReview == true, rating == null)', () {
      final cuciAc = controller.historyOrders.firstWhere(
        (o) => o.serviceName == 'Cuci AC',
      );
      expect(cuciAc.canReview, true);
      expect(cuciAc.rating, isNull);
      expect(cuciAc.orderId, '#CG-99012');
    });

    test(
      'review rejects unknown orders, invalid ratings and repeated submissions',
      () {
        expect(
          controller.submitReview(
            orderId: 'unknown',
            rating: 5,
            tags: [],
            comment: '',
          ),
          isFalse,
        );
        expect(
          controller.submitReview(
            orderId: '#CG-82910',
            rating: 5,
            tags: [],
            comment: '',
          ),
          isFalse,
        );
        final order = controller.historyOrders.firstWhere(
          (item) => item.canReview,
        );
        expect(
          controller.submitReview(
            orderId: order.orderId,
            rating: 0,
            tags: [],
            comment: '',
          ),
          isFalse,
        );
        expect(
          controller.submitReview(
            orderId: order.orderId,
            rating: 5,
            tags: [],
            comment: '',
          ),
          isTrue,
        );
        expect(
          controller.submitReview(
            orderId: order.orderId,
            rating: 4,
            tags: [],
            comment: 'Kedua',
          ),
          isFalse,
        );
        final review = controller.historyOrders
            .firstWhere((item) => item.orderId == order.orderId)
            .review!;
        expect(review.rating, 5);
        expect(review.comment, isEmpty);
      },
    );

    test('submitReview on scheduled order (#CG-82910) does NOT overwrite Cuci AC review status', () {
      controller.completeScheduledOrder();
      controller.submitReview(
        orderId: '#CG-82910',
        rating: 5,
        tags: ['Bersih Maksimal ✨'],
        comment: 'Deep cleaning luar biasa!',
      );

      final cuciAc = controller.historyOrders.firstWhere(
        (o) => o.serviceName == 'Cuci AC',
      );
      expect(cuciAc.canReview, true);
      expect(cuciAc.rating, isNull);

      final scheduledHistory = controller.historyOrders.firstWhere(
        (o) => o.orderId == '#CG-82910',
      );
      expect(scheduledHistory.canReview, false);
      expect(scheduledHistory.rating, 5.0);
    });
  });

  group('Service Mapping for Reorder Tests', () {
    late ServiceController serviceController;

    setUp(() => serviceController = ServiceController());

    test(
      'Maps history "Cuci AC" correctly to "Cuci & Perawatan AC" (ac-care)',
      () {
        final mappedService = serviceController.findServiceForHistory(
          'Cuci AC',
        );
        expect(mappedService.id, 'ac-care');
        expect(mappedService.title, 'Cuci & Perawatan AC');
        expect(mappedService.category, 'AC');
      },
    );

    test('Maps history "Deep Cleaning" correctly to "Deep Cleaning" (deep-cleaning)', () {
      final mappedService = serviceController.findServiceForHistory(
        'Deep Cleaning',
      );
      expect(mappedService.id, 'deep-cleaning');
      expect(mappedService.title, 'Deep Cleaning');
    });

    test('maps office and daily cleaning to their matching services', () {
      expect(
        serviceController.findServiceForHistory('Cleaning Kantor & Usaha').id,
        'office-cleaning',
      );
      expect(
        serviceController.findServiceForHistory('Cleaning Harian (Reguler)').id,
        'daily-cleaning',
      );
    });
  });
}
