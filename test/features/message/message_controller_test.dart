import 'package:cleango_app/features/message/controllers/message_controller.dart';
import 'package:cleango_app/features/message/domain/models/message_notification_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const orderMessage = MessageNotificationModel(
    id: 'order',
    title: 'Pesanan',
    description: 'Pesanan diperbarui',
    timeLabel: 'Sekarang',
    category: MessageCategory.order,
    iconType: MessageIconType.confirmed,
    isUnread: true,
  );
  const promoMessage = MessageNotificationModel(
    id: 'promo',
    title: 'Promo',
    description: 'Promo tersedia',
    timeLabel: 'Kemarin',
    category: MessageCategory.promo,
    iconType: MessageIconType.promo,
  );

  group('MessageController', () {
    late MessageController controller;

    setUp(() {
      controller = MessageController(
        initialMessages: const [orderMessage, promoMessage],
      );
    });

    tearDown(() => controller.dispose());

    test('starts on all tab and reports unread messages', () {
      expect(controller.selectedTab, MessageTab.all);
      expect(controller.visibleMessages, hasLength(2));
      expect(controller.unreadCount, 1);
    });

    test('filters order and promo messages by selected tab', () {
      controller.selectTab(MessageTab.orders);
      expect(controller.visibleMessages, [orderMessage]);

      controller.selectTab(MessageTab.promo);
      expect(controller.visibleMessages, [promoMessage]);
    });

    test('markAsRead updates only the matching unread message', () {
      controller.markAsRead(orderMessage.id);

      expect(controller.unreadCount, 0);
      expect(controller.visibleMessages.first.isUnread, isFalse);
    });
  });
}
