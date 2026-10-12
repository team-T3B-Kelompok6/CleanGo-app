import 'package:flutter/foundation.dart';

class ChatbotController extends ChangeNotifier {
  final List<String> _messages = [];
  bool _hasMessage = false;

  List<String> get messages => List.unmodifiable(_messages);
  bool get hasMessage => _hasMessage;

  void updateDraft(String value) {
    final hasMessage = value.trim().isNotEmpty;
    if (hasMessage == _hasMessage) return;
    _hasMessage = hasMessage;
    notifyListeners();
  }

  bool sendMessage(String value) {
    final message = value.trim();
    if (message.isEmpty) return false;

    _messages.add(message);
    _hasMessage = false;
    notifyListeners();
    return true;
  }
}
