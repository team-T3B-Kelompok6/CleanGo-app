import 'package:flutter/foundation.dart';

import '../data/customer_notification_api.dart';
import '../data/message_data.dart';
import '../domain/models/message_notification_model.dart';

enum MessageTab { all, orders, promo }

class MessageController extends ChangeNotifier {
  MessageController({
    List<MessageNotificationModel>? initialMessages,
    CustomerNotificationApi? notificationApi,
  }) : _notificationApi = notificationApi,
       _messages = List<MessageNotificationModel>.from(
         initialMessages ??
             (notificationApi == null
                 ? MessageData.notifications
                 : <MessageNotificationModel>[]),
       );

  final CustomerNotificationApi? _notificationApi;
  final Map<String, Future<bool>> _pendingReads = {};
  int _readRevision = 0;
  int _loadRevision = 0;
  bool _disposed = false;

  /// Loads the inbox from the backend; keeps the demo list on failure/empty.
  Future<void> loadFromApi() async {
    final api = _notificationApi;
    if (api == null) return;
    final loadRevision = ++_loadRevision;
    final readRevision = _readRevision;
    try {
      final rows = await api.fetchNotifications();
      if (_disposed ||
          loadRevision != _loadRevision ||
          readRevision != _readRevision) {
        return;
      }
      _messages
        ..clear()
        ..addAll(
          rows.map((row) {
            final message = MessageNotificationModel.fromApiJson(row);
            return _pendingReads.containsKey(message.id)
                ? message.copyWith(isUnread: false)
                : message;
          }),
        );
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

  Future<bool> markAsRead(String id) {
    if (_disposed) return Future.value(false);
    final pending = _pendingReads[id];
    if (pending != null) return pending;
    final index = _messages.indexWhere((message) => message.id == id);
    if (index == -1 || !_messages[index].isUnread) return Future.value(true);

    _messages[index] = _messages[index].copyWith(isUnread: false);
    _readRevision++;
    final result = _saveRead(id);
    _pendingReads[id] = result;
    notifyListeners();
    return result;
  }

  Future<bool> _saveRead(String id) async {
    try {
      await _notificationApi?.markRead(id);
      return true;
    } catch (_) {
      if (!_disposed) {
        final index = _messages.indexWhere((message) => message.id == id);
        if (index != -1) {
          _messages[index] = _messages[index].copyWith(isUnread: true);
        }
      }
      return false;
    } finally {
      _pendingReads.remove(id);
      _readRevision++;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
