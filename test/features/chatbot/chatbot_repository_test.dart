import 'dart:convert';

import 'package:cleango_app/core/network/api_client.dart';
import 'package:cleango_app/core/network/api_exception.dart';
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
  for (final source in ['groq', 'faq', 'order', 'support']) {
    test('keeps the backend answer intact for response source $source', () async {
      const answer =
          'Berikut informasi layanan, ya:\n• Harga katalog Rp150.000.\n• Promo belum tersedia.\n\nSilakan cek checkout.';
      final repository = ChatbotRepository(
        tokens: FakeTokens(null),
        client: ApiClient(
          baseUrl: 'http://localhost:3001/api',
          client: MockClient((request) async {
            expect(request.method, 'POST');
            expect(jsonDecode(request.body)['message'], 'harga dan promo?');
            return http.Response(
              jsonEncode({
                'data': {
                  'answer': answer,
                  'source': source,
                  'sources': [
                    {'id': 'test:public', 'title': 'Data uji'},
                  ],
                  'model': source == 'groq' ? 'test-model' : null,
                  'usage': null,
                  'attempts': source == 'groq' ? 1 : 0,
                  'latencyMs': 10,
                },
              }),
              200,
              headers: {'content-type': 'application/json; charset=utf-8'},
            );
          }),
        ),
      );
      addTearDown(repository.close);
      expect(await repository.reply('harga dan promo?', []), answer);
    });
  }
  for (final status in [400, 401, 429, 503]) {
    test('forwards a useful backend error for HTTP $status', () async {
      const message = 'Pesan belum dapat diproses. Silakan coba lagi, ya.';
      final repository = ChatbotRepository(
        tokens: FakeTokens(null),
        client: ApiClient(
          baseUrl: 'http://localhost:3001/api',
          client: MockClient(
            (_) async =>
                http.Response(jsonEncode({'message': message}), status),
          ),
        ),
      );
      addTearDown(repository.close);
      await expectLater(
        repository.reply('halo', []),
        throwsA(
          isA<ApiException>().having(
            (error) => error.message,
            'message',
            message,
          ),
        ),
      );
    });
  }
  test('does not forward failed replies as conversation context', () async {
    final repository = ChatbotRepository(
      tokens: FakeTokens(null),
      client: ApiClient(
        baseUrl: 'http://localhost:3001/api',
        client: MockClient((request) async {
          final body = jsonDecode(request.body) as Map;
          expect(body['history'], [
            {'role': 'user', 'content': 'Deep Cleaning'},
            {'role': 'assistant', 'content': 'Harga mengikuti katalog.'},
          ]);
          return http.Response(
            '{"data":{"answer":"Durasi mengikuti katalog."}}',
            200,
          );
        }),
      ),
    );
    addTearDown(repository.close);
    await repository.reply('berapa lama?', const [
      ChatMessage(content: 'Deep Cleaning', isUser: true),
      ChatMessage(content: 'Harga mengikuti katalog.', isUser: false),
      ChatMessage(
        content: 'Boo belum dapat terhubung.',
        isUser: false,
        failed: true,
      ),
    ]);
  });
  test(
    'rejects an oversized reply before it can break stored chat history',
    () async {
      final repository = ChatbotRepository(
        tokens: FakeTokens(null),
        client: ApiClient(
          baseUrl: 'http://localhost:3001/api',
          client: MockClient(
            (_) async => http.Response(
              jsonEncode({
                'data': {'answer': 'a' * 2501},
              }),
              200,
            ),
          ),
        ),
      );
      addTearDown(repository.close);
      await expectLater(
        repository.reply('halo', []),
        throwsA(isA<ApiException>()),
      );
    },
  );
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
