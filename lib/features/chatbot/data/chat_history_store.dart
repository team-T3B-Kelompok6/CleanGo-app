import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/storage/token_storage.dart';
import '../models/chat_message.dart';

class ChatHistoryStore {
  ChatHistoryStore({
    FlutterSecureStorage? storage,
    TokenStorage? tokens,
    DateTime Function()? now,
  }) : _storage = storage ?? const FlutterSecureStorage(),
       _tokens = tokens ?? SecureTokenStorage(),
       _now = now ?? DateTime.now;

  final FlutterSecureStorage _storage;
  final TokenStorage _tokens;
  final DateTime Function() _now;
  String? _session;
  bool _loaded = false;
  Future<void> _pendingSave = Future.value();

  Future<List<ChatMessage>> load() async {
    _loaded = false;
    _session = await _tokens.readAccessToken();
    await _storage.delete(key: booChatHistoryStorageKeyLegacy);
    final raw = await _storage.read(key: booChatHistoryStorageKey);
    if (await _tokens.readAccessToken() != _session) {
      throw StateError('Chat session changed');
    }
    if (raw == null) {
      _loaded = true;
      return [];
    }
    final value = jsonDecode(raw);
    if (value is! Map || value['messages'] is! List) {
      throw const FormatException('Invalid chat history');
    }
    if (value['session'] != _session) {
      _loaded = true;
      return [];
    }
    final entries = value['messages'] as List;
    final now = _now();
    final messages = entries.map((entry) {
      if (entry is! Map ||
          entry['content'] is! String ||
          (entry['content'] as String).length > 2500 ||
          entry['isUser'] is! bool ||
          entry['failed'] is! bool ||
          entry['createdAt'] is! String) {
        throw const FormatException('Invalid chat message');
      }
      final createdAt = DateTime.tryParse(entry['createdAt']);
      if (createdAt == null) {
        throw const FormatException('Invalid chat timestamp');
      }
      return ChatMessage(
        content: entry['content'],
        isUser: entry['isUser'],
        failed: entry['failed'],
        createdAt: createdAt,
      );
    }).where((message) => !message.isExpired(now)).toList();
    final recent = messages.skip(messages.length > 60 ? messages.length - 60 : 0).toList();
    if (recent.length != entries.length) await _persist(recent);
    _loaded = true;
    return recent;
  }

  Future<void> save(List<ChatMessage> messages) {
    final snapshot = List<ChatMessage>.of(messages);
    final saved = _pendingSave.then((_) async {
      if (!_loaded || await _tokens.readAccessToken() != _session) {
        throw StateError('Chat session changed');
      }
      final now = _now();
      final recent = snapshot.where((message) => !message.isExpired(now)).toList();
      await _persist(recent.skip(recent.length > 60 ? recent.length - 60 : 0));
    });
    _pendingSave = saved.catchError((Object _) {});
    return saved;
  }

  Future<void> _persist(Iterable<ChatMessage> messages) async {
    if (await _tokens.readAccessToken() != _session) {
      throw StateError('Chat session changed');
    }
    await _storage.write(
      key: booChatHistoryStorageKey,
      value: jsonEncode({
        'session': _session,
        'messages': messages.map((message) => {
          'content': message.content,
          'isUser': message.isUser,
          'failed': message.failed,
          'createdAt': message.createdAt.toIso8601String(),
        }).toList(),
      }),
    );
  }
}
