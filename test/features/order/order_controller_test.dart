import 'package:flutter_test/flutter_test.dart';
import 'package:cleango_app/features/order/controllers/order_controller.dart';
import 'package:cleango_app/features/order/domain/models/order_model.dart';
import 'package:cleango_app/features/service/data/service_data.dart';
import 'package:cleango_app/features/service/domain/models/service_model.dart';

void main() {
  group('OrderController Tests', () {
    late OrderController controller;

    setUp(() {
      controller = OrderController();
    });

    test('Initial stage is dalamPerjalanan and step number is 3 of 5', () {
      expect(controller.currentStage, OrderStatusStage.dalamPerjalanan);
      expect(controller.currentStepNumber, 3);
      expect(controller.currentStepLabel, 'Langkah 3 dari 5');
      expect(controller.scheduledOrder.orderNumber, '#CG-82910');
      expect(controller.scheduledOrder.cleanerName, 'Siti Rahmawati');
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

    test('submitReview records review data and sets canReview to false on matching history item', () {
      final initialReviewable = controller.historyOrders.firstWhere((o) => o.canReview);
      expect(initialReviewable.canReview, true);

      controller.submitReview(
        orderId: initialReviewable.orderId,
        rating: 5,
        tags: ['Bersih Maksimal ✨', 'Tepat Waktu ⏰'],
        comment: 'Sangat bersih dan rapi!',
      );

      final updatedOrders = controller.historyOrders;
      final target = updatedOrders.firstWhere((o) => o.serviceName == initialReviewable.serviceName);
      expect(target.canReview, false);
      expect(target.rating, 5.0);
      expect(target.review, isNotNull);
      expect(target.review?.rating, 5);
      expect(target.review?.satisfactionTags, contains('Bersih Maksimal ✨'));
      expect(target.review?.comment, 'Sangat bersih dan rapi!');
    });

    test('Cuci AC history item is initially unreviewed (canReview == true, rating == null)', () {
      final cuciAc = controller.historyOrders.firstWhere((o) => o.serviceName == 'Cuci AC');
      expect(cuciAc.canReview, true);
      expect(cuciAc.rating, isNull);
      expect(cuciAc.orderId, '#CG-99012');
    });

    test('submitReview on scheduled order (#CG-82910) does NOT overwrite Cuci AC review status', () {
      controller.submitReview(
        orderId: '#CG-82910',
        rating: 5,
        tags: ['Bersih Maksimal ✨'],
        comment: 'Deep cleaning luar biasa!',
      );

      final cuciAc = controller.historyOrders.firstWhere((o) => o.serviceName == 'Cuci AC');
      expect(cuciAc.canReview, true);
      expect(cuciAc.rating, isNull);

      final scheduledHistory = controller.historyOrders.firstWhere((o) => o.orderId == '#CG-82910');
      expect(scheduledHistory.canReview, false);
      expect(scheduledHistory.rating, 5.0);
    });
  });

  group('Service Mapping for Reorder Tests', () {
    ServiceModel findServiceForHistory(String historyServiceName) {
      final cleanName = historyServiceName.toLowerCase();
      if (cleanName.contains('ac') || cleanName.contains('cuci ac')) {
        return ServiceData.services.firstWhere(
          (s) => s.id == 'ac-care',
          orElse: () => ServiceData.services.first,
        );
      } else if (cleanName.contains('deep') || cleanName.contains('cleaning')) {
        return ServiceData.services.firstWhere(
          (s) => s.id == 'deep-cleaning',
          orElse: () => ServiceData.services.first,
        );
      } else if (cleanName.contains('sofa') || cleanName.contains('kasur')) {
        return ServiceData.services.firstWhere(
          (s) => s.id == 'sofa-mattress',
          orElse: () => ServiceData.services.first,
        );
      } else if (cleanName.contains('kantor') || cleanName.contains('usaha')) {
        return ServiceData.services.firstWhere(
          (s) => s.id == 'office-cleaning',
          orElse: () => ServiceData.services.first,
        );
      }
      return ServiceData.services.firstWhere(
        (s) => s.title.toLowerCase().contains(cleanName),
        orElse: () => ServiceData.services.first,
      );
    }

    test('Maps history "Cuci AC" correctly to "Cuci & Perawatan AC" (ac-care)', () {
      final mappedService = findServiceForHistory('Cuci AC');
      expect(mappedService.id, 'ac-care');
      expect(mappedService.title, 'Cuci & Perawatan AC');
      expect(mappedService.category, 'AC');
    });

    test('Maps history "Deep Cleaning" correctly to "Deep Cleaning" (deep-cleaning)', () {
      final mappedService = findServiceForHistory('Deep Cleaning');
      expect(mappedService.id, 'deep-cleaning');
      expect(mappedService.title, 'Deep Cleaning');
    });
  });
}
