import 'package:cleango_app/core/constants/app_routes.dart';
import 'package:cleango_app/core/theme/app_theme.dart';
import 'package:cleango_app/features/message/controllers/message_controller.dart';
import 'package:cleango_app/features/message/domain/models/message_notification_model.dart';
import 'package:cleango_app/features/message/pages/messages_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

List<MessageNotificationModel> _messages() => [
  for (final type in MessageIconType.values)
    MessageNotificationModel(
      id: type.name,
      title: 'Notifikasi ${type.name}',
      description: 'Informasi ${type.name} untuk Anda.',
      timeLabel: 'Baru saja',
      category: type == MessageIconType.promo
          ? MessageCategory.promo
          : MessageCategory.order,
      iconType: type,
      isUnread: true,
    ),
];

Future<void> _finishTransition(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  testWidgets(
    'unread backgrounds follow each notification type and clear after reading',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final controller = MessageController(initialMessages: _messages());
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: controller,
          child: MaterialApp(theme: AppTheme.light, home: const MessagesPage()),
        ),
      );
      const colors = {
        MessageIconType.delivery: AppColors.primary,
        MessageIconType.confirmed: AppColors.primary,
        MessageIconType.delayed: AppColors.notification,
        MessageIconType.payment: Color(0xFF2563EB),
        MessageIconType.promo: Color(0xFF7C3AED),
        MessageIconType.rating: Color(0xFFA16207),
      };
      expect(find.text('6 Baru'), findsOneWidget);
      expect(find.text('Notifikasi Pesan'), findsNothing);
      expect(find.text('Pesan'), findsNothing);
      for (final type in MessageIconType.values) {
        final card = find.byKey(ValueKey('notification-${type.name}'));
        await tester.scrollUntilVisible(
          card,
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pump();
        expect(
          tester.widget<Material>(card).color,
          Color.alphaBlend(colors[type]!.withValues(alpha: 0.08), Colors.white),
        );
        await tester.ensureVisible(card);
        await tester.pump();
        await tester.tap(card);
        await tester.pump();
        expect(tester.widget<Material>(card).color, Colors.white);
      }
      expect(controller.unreadCount, 0);
      expect(find.text('6 Baru'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'read state stays read when leaving and reopening notifications',
    (tester) async {
      final controller = MessageController(
        initialMessages: [_messages().first],
      );
      addTearDown(controller.dispose);
      // The app registers AppRoutes.home; mirror it so the Beranda button in the
      // bottom navigation resolves (it replaces the stack with Home).
      Widget openNotifications() => Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const MessagesPage()),
              ),
              child: const Text('Buka Notifikasi'),
            ),
          ),
        ),
      );
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: controller,
          child: MaterialApp(
            theme: AppTheme.light,
            home: openNotifications(),
            routes: {AppRoutes.home: (_) => openNotifications()},
          ),
        ),
      );
      await tester.tap(find.text('Buka Notifikasi'));
      await _finishTransition(tester);
      final card = find.byKey(const ValueKey('notification-delivery'));
      await tester.tap(card);
      await tester.pump();
      expect(controller.unreadCount, 0);
      await tester.tap(find.text('Beranda'));
      await _finishTransition(tester);
      await tester.tap(find.text('Buka Notifikasi'));
      await _finishTransition(tester);
      expect(tester.widget<Material>(card).color, Colors.white);
      expect(find.text('1 Baru'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'notification labels and cards fit a narrow screen with larger text',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final controller = MessageController(initialMessages: _messages());
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: controller,
          child: MaterialApp(
            theme: AppTheme.light,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.4)),
              child: child!,
            ),
            home: const MessagesPage(),
          ),
        ),
      );
      expect(find.text('Notifikasi'), findsNWidgets(2));
      await tester.tap(find.text('Promo'));
      await _finishTransition(tester);
      expect(find.byKey(const ValueKey('notification-promo')), findsOneWidget);
      expect(find.byKey(const ValueKey('notification-delivery')), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
