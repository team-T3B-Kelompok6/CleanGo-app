import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../data/chatbot_repository.dart';
import '../data/chat_history_store.dart';
import '../models/chat_message.dart';

class ChatbotController extends ChangeNotifier {
  ChatbotController({
    ChatbotGateway? repository,
    ChatHistoryStore? history,
    DateTime Function()? now,
  }) : _repository = repository ?? ChatbotRepository(),
       _history = history ?? ChatHistoryStore(),
       _now = now ?? DateTime.now;

  final ChatbotGateway _repository;
  final ChatHistoryStore _history;
  final DateTime Function() _now;
  Future<void>? _initialization;
  bool _historyReadable = true;
  bool _historyUnavailable = false;
  final List<ChatMessage> _messages = [];
  bool _hasMessage = false;
  bool _isSending = false;
  bool _disposed = false;
  Timer? _expiryTimer;
  List<FaqChoice> _faqChoices = const [];
  int? _faqNextPage;
  DateTime? _faqExpiresAt;

  bool get _hasFaqMenu => _faqExpiresAt?.isAfter(_now()) ?? false;
  int? get faqNextPage => _hasFaqMenu ? _faqNextPage : null;

  void _clearFaqMenu() {
    _faqChoices = const [];
    _faqNextPage = null;
    _faqExpiresAt = null;
  }

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get hasMessage => _hasMessage;
  bool get isSending => _isSending;
  bool get historyUnavailable => _historyUnavailable;
  Future<List<ChatSuggestion>> loadSuggestions() => _repository.suggestions();

  Future<void> restoreHistory() => _initialization ??= _restoreHistory();

  Future<void> _restoreHistory() async {
    try {
      final saved = await _history.load();
      if (!_disposed) {
        _messages.addAll(saved.where((message) => !message.isExpired(_now())));
        _scheduleExpiry();
      }
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

  Future<void> expireHistory() async {
    if (_disposed) return;
    final now = _now();
    final previousLength = _messages.length;
    _messages.removeWhere((message) => message.isExpired(now));
    _scheduleExpiry();
    if (_messages.length != previousLength) {
      await _saveHistory();
      if (!_disposed) notifyListeners();
    }
  }

  void _scheduleExpiry() {
    _expiryTimer?.cancel();
    if (_disposed || _messages.isEmpty) return;
    final expiry = _messages
        .map((message) => message.createdAt.add(ChatMessage.retention))
        .reduce((a, b) => a.isBefore(b) ? a : b);
    final delay = expiry.difference(_now());
    _expiryTimer = Timer(delay.isNegative ? Duration.zero : delay, () {
      unawaited(expireHistory());
    });
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
    await expireHistory();
    if (_disposed) return false;
    final numeric = RegExp(r'^-?\d+(?:\.\d+)?$').hasMatch(message);
    final faqIds = numeric && _hasFaqMenu
        ? _faqChoices.map((choice) => choice.id).toList()
        : null;
    final selected = int.tryParse(message);
    final validSelection =
        faqIds != null &&
        selected != null &&
        selected > 0 &&
        selected <= faqIds.length;
    if (faqIds == null || validSelection) _clearFaqMenu();
    final history = List<ChatMessage>.of(_messages);
    _messages.add(
      ChatMessage(content: message, isUser: true, createdAt: _now()),
    );
    _hasMessage = false;
    notifyListeners();
    try {
      await _saveHistory();
      if (_disposed) return true;
      final result = await _repository.reply(message, history, faqIds: faqIds);
      if (result.faqChoices.isNotEmpty) {
        _faqChoices = result.faqChoices;
        _faqNextPage = result.faqNextPage;
        _faqExpiresAt = _now().add(const Duration(minutes: 15));
      } else if (faqIds == null || validSelection) {
        _clearFaqMenu();
      }
      _messages.add(
        ChatMessage(content: result.answer, isUser: false, createdAt: _now()),
      );
    } catch (error) {
      _clearFaqMenu();
      _messages.add(
        ChatMessage(
          content: error is ApiException ? error.message : 'Boo belum dapat terhubung. Periksa koneksi lalu kirim ulang pesan, atau buka Pusat Bantuan.',
          isUser: false,
          failed: true,
          createdAt: _now(),
        ),
      );
    } finally {
      if (_messages.length > 60) {
        _messages.removeRange(0, _messages.length - 60);
      }
      await _saveHistory();
      _isSending = false;
      _scheduleExpiry();
      if (!_disposed) notifyListeners();
    }
    return true;
  }

  @override
  void dispose() {
    _disposed = true;
    _expiryTimer?.cancel();
    _repository.close();
    super.dispose();
  }
}
