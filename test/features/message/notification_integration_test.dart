import 'package:cleango_app/features/message/controllers/message_controller.dart';
import 'package:cleango_app/features/message/data/customer_notification_api.dart';
import 'package:cleango_app/features/message/data/message_data.dart';
import 'package:cleango_app/features/message/domain/models/message_notification_model.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeNotificationApi extends CustomerNotificationApi {
  _FakeNotificationApi({this.rows = const [], this.fail = false});

  final List<Map<String, dynamic>> rows;
  final bool fail;
  int listCalls = 0;
  final List<String> readIds = [];

  @override
  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    listCalls++;
    if (fail) throw StateError('jaringan mati');
    return rows;
  }

  @override
  Future<void> markRead(String id) async => readIds.add(id);
}

void main() {
  group('MessageNotificationModel.fromApiJson', () {
    test('maps an order notification', () {
      final model = MessageNotificationModel.fromApiJson({
        'id': 12,
        'type': 'order',
        'title': 'Pesanan Dikonfirmasi',
        'message': 'Pesanan CG-1 telah dibuat.',
        'isRead': false,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      });

      expect(model.id, '12');
      expect(model.title, 'Pesanan Dikonfirmasi');
      expect(model.category, MessageCategory.order);
      expect(model.iconType, MessageIconType.confirmed);
      expect(model.isUnread, isTrue);
      expect(model.isWarning, isFalse);
      expect(model.timeLabel, 'Baru saja');
    });

    test('maps promo and risk notifications', () {
      final promo = MessageNotificationModel.fromApiJson({
        'id': 1,
        'type': 'promo',
        'title': 'Promo',
        'message': 'Diskon 20%',
      });
      final risk = MessageNotificationModel.fromApiJson({
        'id': 2,
        'type': 'risk_alert',
        'title': 'Terlambat',
        'message': 'Cleaner terlambat',
      });

      expect(promo.category, MessageCategory.promo);
      expect(promo.iconType, MessageIconType.promo);
      expect(risk.isWarning, isTrue);
      expect(risk.iconType, MessageIconType.delayed);
    });

    test('treats a read notification as read', () {
      final model = MessageNotificationModel.fromApiJson({
        'id': 3,
        'type': 'system',
        'title': 'Info',
        'message': 'Pesan',
        'isRead': true,
      });

      expect(model.isUnread, isFalse);
    });
  });

  group('MessageNotificationModel.relativeLabel', () {
    final now = DateTime.utc(2026, 10, 20, 12, 0);

    test('formats recent windows', () {
      String label(Duration ago) => MessageNotificationModel.relativeLabel(
        now.subtract(ago).toIso8601String(),
        now: now,
      );

      expect(label(const Duration(seconds: 20)), 'Baru saja');
      expect(label(const Duration(minutes: 5)), '5 menit lalu');
      expect(label(const Duration(hours: 3)), '3 jam lalu');
      expect(label(const Duration(days: 2)), '2 hari lalu');
      expect(label(const Duration(days: 14)), '2 minggu lalu');
    });

    test('returns an empty label for a missing date', () {
      expect(MessageNotificationModel.relativeLabel(null), '');
      expect(MessageNotificationModel.relativeLabel('bukan-tanggal'), '');
    });
  });

  group('MessageController.loadFromApi', () {
    test('replaces the demo inbox with backend notifications', () async {
      final api = _FakeNotificationApi(
        rows: [
          {
            'id': 1,
            'type': 'order',
            'title': 'Pesanan Dikonfirmasi',
            'message': 'Pesanan CG-1 dibuat.',
            'isRead': false,
          },
        ],
      );
      final controller = MessageController(notificationApi: api);

      await controller.loadFromApi();

      expect(api.listCalls, 1);
      expect(controller.visibleMessages.length, 1);
      expect(controller.visibleMessages.single.title, 'Pesanan Dikonfirmasi');
      expect(controller.unreadCount, 1);
    });

    test('keeps the demo inbox when the backend is empty or fails', () async {
      final empty = MessageController(notificationApi: _FakeNotificationApi());
      await empty.loadFromApi();
      expect(empty.visibleMessages.length, MessageData.notifications.length);

      final failing = MessageController(
        notificationApi: _FakeNotificationApi(fail: true),
      );
      await failing.loadFromApi();
      expect(failing.visibleMessages.length, MessageData.notifications.length);
    });

    test('marks a notification read locally and on the backend', () async {
      final api = _FakeNotificationApi(
        rows: [
          {
            'id': 7,
            'type': 'order',
            'title': 'Pesanan',
            'message': 'Pesan',
            'isRead': false,
          },
        ],
      );
      final controller = MessageController(notificationApi: api);
      await controller.loadFromApi();

      controller.markAsRead('7');

      expect(controller.unreadCount, 0);
      expect(api.readIds, ['7']);
    });
  });
}
