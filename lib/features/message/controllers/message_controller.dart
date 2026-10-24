import 'package:flutter/foundation.dart';

import '../data/customer_notification_api.dart';
import '../data/message_data.dart';
import '../domain/models/message_notification_model.dart';

enum MessageTab { all, orders, promo }

class MessageController extends ChangeNotifier {
  MessageController({
    List<MessageNotificationModel>? initialMessages,
    CustomerNotificationApi? notificationApi,
  })  : _notificationApi = notificationApi,
        _messages = List<MessageNotificationModel>.from(
          initialMessages ?? MessageData.notifications,
        );

  final CustomerNotificationApi? _notificationApi;

  /// Loads the inbox from the backend; keeps the demo list on failure/empty.
  Future<void> loadFromApi() async {
    final api = _notificationApi;
    if (api == null) return;
    try {
      final rows = await api.fetchNotifications();
      if (rows.isEmpty) return;
      _messages
        ..clear()
        ..addAll(rows.map(MessageNotificationModel.fromApiJson));
      notifyListeners();
    } catch (_) {
      // offline / no session: keep the bundled demo notifications
    }
  }

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
    final api = _notificationApi;
    if (api != null) {
      // Fire and forget: the local state is already updated.
      api.markRead(id).catchError((_) {});
    }
  }
}
