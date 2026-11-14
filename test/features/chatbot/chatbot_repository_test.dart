import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';

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

class DelayedTokens extends FakeTokens {
  DelayedTokens() : super(null);
  final pending = Completer<String?>();
  @override
  Future<String?> readAccessToken() => pending.future;
}

void main() {
  test('parses FAQ choices and sends IDs only for numbering', () async {
    final repository = ChatbotRepository(
      tokens: FakeTokens(null),
      client: ApiClient(
        client: MockClient((request) async {
          final body = jsonDecode(request.body) as Map;
          expect(body['faqIds'], ['42', '7']);
          expect(body.containsKey('faqChoices'), isFalse);
          return http.Response(
            jsonEncode({
              'data': {
                'answer': '1. Resmi',
                'faqChoices': [
                  {'id': '42', 'question': 'Resmi'},
                ],
                'faqNextPage': 2,
              },
            }),
            200,
          );
        }),
      ),
    );
    addTearDown(repository.close);
    final result = await repository.reply('1', [], faqIds: ['42', '7']);
    expect(result.answer, '1. Resmi');
    expect(result.faqChoices.single.id, '42');
    expect(result.faqChoices.single.question, 'Resmi');
    expect(result.faqNextPage, 2);
  });
  for (final choices in [
    [
      {'id': '0', 'question': 'x'},
    ],
    [
      {'id': '1', 'question': 'x'},
      {'id': '1', 'question': 'y'},
    ],
    [
      {'id': '1', 'question': ''},
    ],
    List.filled(6, {'id': '1', 'question': 'x'}),
  ]) {
    test('rejects malformed menu $choices', () async {
      final repository = ChatbotRepository(
        tokens: FakeTokens(null),
        client: ApiClient(
          client: MockClient(
            (_) async => http.Response(
              jsonEncode({
                'data': {'answer': 'Menu', 'faqChoices': choices},
              }),
              200,
            ),
          ),
        ),
      );
      addTearDown(repository.close);
      await expectLater(
        repository.reply('FAQ', []),
        throwsA(isA<ApiException>()),
      );
    });
  }
  test(
    'preview disposal cannot corrupt bytes while token read is pending',
    () async {
      final tokens = DelayedTokens();
      final bytes = Uint8List.fromList([1, 2, 3]);
      final repository = ChatbotRepository(
        tokens: tokens,
        client: ApiClient(
          client: MockClient((request) async {
            expect(request.bodyBytes, [1, 2, 3]);
            return http.Response('{"message":"busy","code":"BUSY"}', 503);
          }),
        ),
      );
      addTearDown(repository.close);
      final pending = repository.analyzeImage(bytes, 'image/png');
      bytes.fillRange(0, bytes.length, 0);
      tokens.pending.complete('header.payload.signature');
      await expectLater(pending, throwsA(isA<ApiException>()));
    },
  );
  for (final status in [400, 401, 403, 413, 415, 429, 503, 504]) {
    test(
      'preserves image endpoint error $status without retry or fallback',
      () async {
        var calls = 0;
        final repository = ChatbotRepository(
          tokens: FakeTokens('header.payload.signature'),
          client: ApiClient(
            client: MockClient((request) async {
              calls++;
              expect(request.url.path, '/api/customer/chat/analyze-image');
              return http.Response(
                jsonEncode({'message': 'Foto gagal', 'code': 'TEST_ERROR'}),
                status,
              );
            }),
          ),
        );
        addTearDown(repository.close);
        await expectLater(
          repository.analyzeImage([1], 'image/png'),
          throwsA(
            isA<ApiException>()
                .having((e) => e.statusCode, 'status', status)
                .having((e) => e.code, 'code', 'TEST_ERROR'),
          ),
        );
        expect(calls, 1);
      },
    );
  }
  test('sends intact image bytes and surfaces API/auth errors', () async {
    Uint8List? uploadBody;
    final repository = ChatbotRepository(
      tokens: FakeTokens('header.payload.signature'),
      client: ApiClient(
        client: MockClient((request) async {
          uploadBody = Uint8List.fromList(request.bodyBytes);
          return http.Response(
            '{"data":{"reply":"ok","analysis":{"cleanliness":"moderate","tidiness":"unknown","observations":"Kotoran tampak pada foto.","confidence":"high"},"status":"analyzed"}}',
            200,
          );
        }),
      ),
    );
    addTearDown(repository.close);
    await repository.analyzeImage([1, 2, 3], 'image/png');
    expect(uploadBody, [1, 2, 3]);

    final delayed = Completer<http.Response>();
    final pendingRepo = ChatbotRepository(
      tokens: FakeTokens('header.payload.signature'),
      client: ApiClient(
        client: MockClient((request) async {
          uploadBody = Uint8List.fromList(request.bodyBytes);
          return delayed.future;
        }),
      ),
    );
    addTearDown(pendingRepo.close);
    final pending = pendingRepo.analyzeImage([4, 5, 6], 'image/png');
    await Future<void>.delayed(Duration.zero);
    delayed.complete(
      http.Response('{"message":"offline","code":"UNAVAILABLE"}', 503),
    );
    await expectLater(pending, throwsA(isA<ApiException>()));
    // The mock captured wire bytes; mutable request copy has been zeroed in finally.
    expect(uploadBody, [4, 5, 6]);

    final guest = ChatbotRepository(tokens: FakeTokens(null));
    addTearDown(guest.close);
    await expectLater(
      guest.analyzeImage([1], 'image/png'),
      throwsA(isA<ApiException>()),
    );
  });

  test('requires a customer token and enforces the 5 MiB limit', () async {
    var requests = 0;
    final repository = ChatbotRepository(
      tokens: FakeTokens(null),
      client: ApiClient(
        client: MockClient((_) async {
          requests++;
          return http.Response('{}', 200);
        }),
      ),
    );
    addTearDown(repository.close);
    await expectLater(
      repository.analyzeImage([1], 'image/png'),
      throwsA(
        isA<ApiException>().having((e) => e.statusCode, 'statusCode', 401),
      ),
    );
    await expectLater(
      repository.analyzeImage(List.filled(5 * 1024 * 1024 + 1, 1), 'image/png'),
      throwsA(isA<ApiException>()),
    );
    expect(requests, 0);
  });
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
      expect((await repository.reply('harga dan promo?', [])).answer, answer);
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
    await repository.reply('berapa lama?', [
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
          baseUrl: 'http://localhost:3001',
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
        (await repository.reply(
          'halo',
          List.generate(
            20,
            (i) => ChatMessage(content: 'pesan $i', isUser: true),
          ),
        )).answer,
        'Halo dari Boo',
      );
    });
  }
  test('fetches dynamic suggestions and ignores invalid items', () async {
    final repository = ChatbotRepository(
      tokens: FakeTokens('header.payload.signature'),
      client: ApiClient(
        baseUrl: 'http://localhost:3001',
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, '/api/customer/chat/suggestions');
          expect(
            request.headers['authorization'],
            'Bearer header.payload.signature',
          );
          return http.Response(
            jsonEncode({
              'data': [
                {'question': 'Apa itu CleanGo?', 'source': 'knowledge'},
                {'question': 'Bagaimana pembayaran?', 'source': 'faq'},
                {'invalid': 123},
              ],
            }),
            200,
          );
        }),
      ),
    );
    addTearDown(repository.close);
    final items = await repository.suggestions();
    expect(items.map((item) => item.question), [
      'Apa itu CleanGo?',
      'Bagaimana pembayaran?',
    ]);
  });

  test(
    'posts image bytes with MIME type and bearer token, parsing analysis',
    () async {
      final repository = ChatbotRepository(
        tokens: FakeTokens('header.payload.signature'),
        client: ApiClient(
          baseUrl: 'http://localhost:3001',
          client: MockClient((request) async {
            expect(request.url.path, '/api/customer/chat/analyze-image');
            expect(request.headers['content-type'], 'image/png');
            expect(
              request.headers['authorization'],
              'Bearer header.payload.signature',
            );
            expect(request.bodyBytes, [1, 2, 3]);
            return http.Response(
              jsonEncode({
                'data': {
                  'reply': 'Lantai perlu dibersihkan.',
                  'analysis': {
                    'cleanliness': 'moderate',
                    'tidiness': 'moderate',
                    'observations': 'Kotoran tampak pada foto.',
                    'confidence': 'high',
                  },
                  'status': 'analyzed',
                },
              }),
              200,
            );
          }),
        ),
      );
      addTearDown(repository.close);
      final result = await repository.analyzeImage([1, 2, 3], 'image/png');
      expect(result.reply, 'Lantai perlu dibersihkan.');
      expect(result.analysis['cleanliness'], 'moderate');
    },
  );

  test('rejects malformed chatbot responses', () async {
    final repository = ChatbotRepository(
      tokens: FakeTokens(null),
      client: ApiClient(
        baseUrl: 'http://localhost:3001',
        client: MockClient((_) async => http.Response('{"data":{}}', 200)),
      ),
    );
    addTearDown(repository.close);
    await expectLater(repository.reply('halo', []), throwsException);
  });
}
