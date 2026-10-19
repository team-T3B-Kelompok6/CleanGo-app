import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../data/chatbot_repository.dart';
import '../data/chat_history_store.dart';
import '../models/chat_message.dart';

class ChatbotController extends ChangeNotifier {
  ChatbotController({ChatbotGateway? repository, ChatHistoryStore? history})
    : _repository = repository ?? ChatbotRepository(),
      _history = history ?? ChatHistoryStore();

  final ChatbotGateway _repository;
  final ChatHistoryStore _history;
  Future<void>? _initialization;
  bool _historyReadable = true;
  bool _historyUnavailable = false;
  final List<ChatMessage> _messages = [];
  bool _hasMessage = false;
  bool _isSending = false;
  bool _disposed = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get hasMessage => _hasMessage;
  bool get isSending => _isSending;
  bool get historyUnavailable => _historyUnavailable;

  Future<void> restoreHistory() => _initialization ??= _restoreHistory();

  Future<void> _restoreHistory() async {
    try {
      final saved = await _history.load();
      if (!_disposed) _messages.addAll(saved);
    } catch (_) {
      // Do not overwrite history that could not be read.
      _historyReadable = false;
      _historyUnavailable = true;
    }
    if (!_disposed) notifyListeners();
  }

  Future<void> _saveHistory() async {
    if (!_historyReadable) return;
    try {
      await _history.save(List.of(_messages));
      _historyUnavailable = false;
    } catch (_) {
      _historyUnavailable = true;
    }
  }

  void updateDraft(String value) {
    final hasMessage = value.trim().isNotEmpty;
    if (hasMessage == _hasMessage) return;
    _hasMessage = hasMessage;
    notifyListeners();
  }

  Future<bool> sendMessage(String value) async {
    final message = value.trim();
    if (message.isEmpty || _isSending || _disposed) return false;
    if (message.length > 2000) return false;

    _isSending = true;
    await restoreHistory();
    if (_disposed) return false;
    final history = List<ChatMessage>.of(_messages);
    _messages.add(ChatMessage(content: message, isUser: true));
    _hasMessage = false;
    notifyListeners();
    try {
      await _saveHistory();
      if (_disposed) return true;
      final answer = await _repository.reply(message, history);
      _messages.add(ChatMessage(content: answer, isUser: false));
    } catch (error) {
      _messages.add(
        ChatMessage(
          content: error is ApiException ? error.message : 'Boo belum dapat terhubung. Periksa koneksi lalu kirim ulang pesan, atau buka Pusat Bantuan.',
          isUser: false,
          failed: true,
        ),
      );
    } finally {
      if (_messages.length > 60) {
        _messages.removeRange(0, _messages.length - 60);
      }
      await _saveHistory();
      _isSending = false;
      if (!_disposed) notifyListeners();
    }
    return true;
  }

  @override
  void dispose() {
    _disposed = true;
    _repository.close();
    super.dispose();
  }
}
