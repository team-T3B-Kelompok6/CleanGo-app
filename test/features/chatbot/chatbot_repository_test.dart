import 'dart:convert';

import 'package:cleango_app/core/network/api_client.dart';
import 'package:cleango_app/core/storage/token_storage.dart';
import 'package:cleango_app/features/chatbot/data/chatbot_repository.dart';
import 'package:cleango_app/features/chatbot/models/chat_message.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class FakeTokens implements TokenStorage {
  FakeTokens(this.token);
  final String? token;
  @override
  Future<String?> readAccessToken() async => token;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  for (final token in ['dummy-session', 'header.payload.signature']) {
    test('chat request minimizes history and handles token $token', () async {
      final repository = ChatbotRepository(
        tokens: FakeTokens(token),
        client: ApiClient(
          baseUrl: 'http://localhost:3001/api',
          client: MockClient((request) async {
            expect(request.url.path, '/api/customer/chat');
            expect(
              request.headers['authorization'],
              token.contains('.') ? 'Bearer $token' : isNull,
            );
            final body = jsonDecode(request.body) as Map;
            expect(body['history'].length, 8);
            expect(body.containsKey('customerId'), isFalse);
            return http.Response('{"data":{"answer":"Halo dari Boo"}}', 200);
          }),
        ),
      );
      addTearDown(repository.close);
      expect(
        await repository.reply(
          'halo',
          List.generate(
            20,
            (i) => ChatMessage(content: 'pesan $i', isUser: true),
          ),
        ),
        'Halo dari Boo',
      );
    });
  }
  test('rejects malformed chatbot responses', () async {
    final repository = ChatbotRepository(
      tokens: FakeTokens(null),
      client: ApiClient(
        baseUrl: 'http://localhost:3001/api',
        client: MockClient((_) async => http.Response('{"data":{}}', 200)),
      ),
    );
    addTearDown(repository.close);
    await expectLater(repository.reply('halo', []), throwsException);
  });
}
