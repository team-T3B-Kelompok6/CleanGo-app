import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/storage/token_storage.dart';
import '../models/chat_message.dart';

class ChatHistoryStore {
  ChatHistoryStore({FlutterSecureStorage? storage, TokenStorage? tokens})
    : _storage = storage ?? const FlutterSecureStorage(),
      _tokens = tokens ?? SecureTokenStorage();

  final FlutterSecureStorage _storage;
  final TokenStorage _tokens;
  String? _session;
  bool _loaded = false;

  Future<List<ChatMessage>> load() async {
    _session = await _tokens.readAccessToken();
    final raw = await _storage.read(key: booChatHistoryStorageKey);
    if (raw == null) {
      _loaded = true;
      return [];
    }
    final value = jsonDecode(raw);
    if (value is! Map || value['messages'] is! List) {
      throw const FormatException('Invalid chat history');
    }
    // shortcut: history is local to one login session; use server account history when auth integration is ready.
    if (value['session'] != _session) {
      _loaded = true;
      return [];
    }
    final entries = value['messages'] as List;
    final messages = entries
        .skip(entries.length > 60 ? entries.length - 60 : 0)
        .map((entry) {
          if (entry is! Map ||
              entry['content'] is! String ||
              (entry['content'] as String).length > 2500 ||
              entry['isUser'] is! bool ||
              entry['failed'] is! bool) {
            throw const FormatException('Invalid chat message');
          }
          return ChatMessage(
            content: entry['content'],
            isUser: entry['isUser'],
            failed: entry['failed'],
          );
        })
        .toList();
    _loaded = true;
    return messages;
  }

  Future<void> save(List<ChatMessage> messages) async {
    if (!_loaded || await _tokens.readAccessToken() != _session) {
      throw StateError('Chat session changed');
    }
    final recent = messages.skip(
      messages.length > 60 ? messages.length - 60 : 0,
    );
    await _storage.write(
      key: booChatHistoryStorageKey,
      value: jsonEncode({
        'session': _session,
        'messages': recent
            .map(
              (message) => {
                'content': message.content,
                'isUser': message.isUser,
                'failed': message.failed,
              },
            )
            .toList(),
      }),
    );
  }
}
