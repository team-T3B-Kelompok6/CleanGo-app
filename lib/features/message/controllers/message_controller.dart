import 'package:flutter/foundation.dart';

import '../data/message_data.dart';
import '../domain/models/message_notification_model.dart';

enum MessageTab { all, orders, promo }

class MessageController extends ChangeNotifier {
  MessageController({List<MessageNotificationModel>? initialMessages})
    : _messages = List<MessageNotificationModel>.from(
        initialMessages ?? MessageData.notifications,
      );

  MessageTab _selectedTab = MessageTab.all;
  final List<MessageNotificationModel> _messages;

  MessageTab get selectedTab => _selectedTab;
  int get unreadCount => _messages.where((message) => message.isUnread).length;

  List<MessageNotificationModel> get visibleMessages {
    final messages = switch (_selectedTab) {
      MessageTab.all => _messages,
      MessageTab.orders => _messages.where(
        (message) => message.category == MessageCategory.order,
      ),
      MessageTab.promo => _messages.where(
        (message) => message.category == MessageCategory.promo,
      ),
    };

    return List<MessageNotificationModel>.unmodifiable(messages);
  }

  void selectTab(MessageTab tab) {
    if (tab == _selectedTab) return;
    _selectedTab = tab;
    notifyListeners();
  }

  void markAsRead(String id) {
    final index = _messages.indexWhere((message) => message.id == id);
    if (index == -1 || !_messages[index].isUnread) return;

    _messages[index] = _messages[index].copyWith(isUnread: false);
    notifyListeners();
  }
}
