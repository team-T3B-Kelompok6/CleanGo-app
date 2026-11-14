import 'dart:async';
import 'dart:convert';

import 'package:cleango_app/core/network/api_client.dart';
import 'package:cleango_app/core/storage/token_storage.dart';
import 'package:cleango_app/features/chatbot/data/chatbot_repository.dart';
import 'package:cleango_app/features/chatbot/models/chat_message.dart';
import 'package:cleango_app/features/chatbot/pages/chatbot_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'fake_chat_history.dart';

class PendingChat implements ChatbotGateway {
  final answer = Completer<String>();
  final questions = <String>[];
  @override
  Future<ChatReply> reply(
    String message,
    List<ChatMessage> history, {
    List<String>? faqIds,
  }) async {
    questions.add(message);
    return ChatReply(answer: await answer.future);
  }

  @override
  Future<List<ChatSuggestion>> suggestions() async => const [
    ChatSuggestion(question: 'Bagaimana cara booking?', source: 'knowledge'),
  ];
  @override
  void close() {}
}

class GuestTokens implements TokenStorage {
  @override
  Future<String?> readAccessToken() async => null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets(
    'FAQ chip opens menu, numeric input sends displayed IDs, next page replaces menu',
    (tester) async {
      final calls = <Map<String, dynamic>>[];
      final repository = ChatbotRepository(
        tokens: GuestTokens(),
        client: ApiClient(
          client: MockClient((request) async {
            if (request.method == 'GET') {
              return http.Response(
                '{"data":[{"question":"FAQ","source":"faq-menu"}]}',
                200,
              );
            }
            final body = jsonDecode(request.body) as Map<String, dynamic>;
            calls.add(body);
            final menu = body['message'] == 'FAQ';
            return http.Response(
              jsonEncode({
                'data': menu
                    ? {
                        'answer': '1. Pertanyaan resmi',
                        'faqChoices': [
                          {'id': '42', 'question': 'Pertanyaan resmi'},
                        ],
                        'faqNextPage': 2,
                      }
                    : {'answer': 'Jawaban resmi'},
              }),
              200,
            );
          }),
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: ChatbotPage(repository: repository, history: FakeChatHistory()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ActionChip, 'FAQ'));
      await tester.pumpAndSettle();
      expect(find.text('1. Pertanyaan resmi'), findsOneWidget);
      expect(find.text('FAQ lainnya'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '1');
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pumpAndSettle();
      expect(calls.last['message'], '1');
      expect(calls.last['faqIds'], ['42']);
      expect(find.text('Jawaban resmi'), findsOneWidget);
      expect(find.text('FAQ lainnya'), findsNothing);
      await tester.tap(find.widgetWithText(ActionChip, 'FAQ'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('FAQ lainnya'));
      await tester.pumpAndSettle();
      expect(calls.last['message'], 'FAQ halaman 2');
      expect(calls.last.containsKey('faqIds'), isFalse);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets('opens ephemeral Boo photo flow without writing chat history', (
    tester,
  ) async {
    final store = FakeChatHistory();
    final repository = PendingChat();
    await tester.pumpWidget(
      MaterialApp(
        home: ChatbotPage(repository: repository, history: store),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Analisis foto dengan Boo'));
    await tester.pumpAndSettle();
    expect(find.text('Analisis foto'), findsOneWidget);
    expect(find.text('Kamera'), findsOneWidget);
    expect(find.text('Galeri'), findsOneWidget);
    expect(repository.questions, isEmpty);
    expect(store.saved, isEmpty);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'renders and saves an actual repository response without rewriting it',
    (tester) async {
      const answer =
          'Deep Cleaning: harga katalog Rp150.000.\n\nPromo belum dapat dipastikan. Silakan cek checkout, ya.';
      final store = FakeChatHistory();
      final repository = ChatbotRepository(
        tokens: GuestTokens(),
        client: ApiClient(
          baseUrl: 'http://localhost:3001/api',
          client: MockClient((request) async {
            expect(request.url.path, '/api/customer/chat');
            return http.Response(
              jsonEncode({
                'data': {
                  'answer': answer,
                  'source': 'faq',
                  'sources': [],
                  'model': null,
                  'usage': null,
                  'attempts': 0,
                  'latencyMs': 1,
                },
              }),
              200,
            );
          }),
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: ChatbotPage(
            initialMessage: 'Harga Deep Cleaning dan promo?',
            repository: repository,
            history: store,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(answer), findsOneWidget);
      expect(find.text('Boo · CS AI'), findsOneWidget);
      expect(find.text('Boo sedang mengetik…'), findsNothing);
      expect(store.saved.last.content, answer);
      expect(store.saved.last.failed, isFalse);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets(
    'sends the initial help question once and displays the AI answer',
    (tester) async {
      final repository = PendingChat();
      final store = FakeChatHistory();
      Widget page() => MaterialApp(
        home: ChatbotPage(
          initialMessage: '  Bagaimana cara booking?  ',
          repository: repository,
          history: store,
        ),
      );
      await tester.pumpWidget(page());
      await tester.pump();
      expect(repository.questions, ['Bagaimana cara booking?']);
      expect(find.text('Bagaimana cara booking?'), findsAtLeastNWidgets(1));
      expect(find.text('Boo sedang mengetik…'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      await tester.pumpWidget(page());
      expect(repository.questions, hasLength(1));
      repository.answer.complete('Pilih layanan lalu tentukan jadwal Anda.');
      await tester.pumpAndSettle();
      expect(
        find.text('Pilih layanan lalu tentukan jadwal Anda.'),
        findsOneWidget,
      );
      expect(store.saved.where((message) => message.isUser), hasLength(1));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('sends a selected dynamic suggestion through chat', (
    tester,
  ) async {
    final repository = PendingChat();
    await tester.pumpWidget(
      MaterialApp(
        home: ChatbotPage(repository: repository, history: FakeChatHistory()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bagaimana cara booking?'));
    await tester.pump();
    expect(repository.questions, ['Bagaimana cara booking?']);
    expect(find.text('Boo sedang mengetik…'), findsOneWidget);
    repository.answer.complete('Ikuti langkah booking di aplikasi.');
    await tester.pumpAndSettle();
    expect(find.text('Ikuti langkah booking di aplikasi.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the user message, waiting state and assistant reply', (
    tester,
  ) async {
    final repository = PendingChat();
    await tester.pumpWidget(
      MaterialApp(
        home: ChatbotPage(repository: repository, history: FakeChatHistory()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byTooltip('Analisis foto dengan Boo'), findsOneWidget);
    expect(find.byIcon(Icons.mic_none_rounded), findsNothing);
    await tester.enterText(find.byType(TextField), 'Harga layanan?');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump();
    expect(find.text('Harga layanan?'), findsOneWidget);
    expect(find.text('Boo sedang mengetik…'), findsOneWidget);
    repository.answer.complete('Harga mengikuti katalog layanan CleanGo.');
    await tester.pumpAndSettle();
    expect(find.text('Boo sedang mengetik…'), findsNothing);
    expect(
      find.text('Harga mengikuti katalog layanan CleanGo.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('shows existing conversation after reopening Boo', (
    tester,
  ) async {
    final store = FakeChatHistory()
      ..saved = [
        ChatMessage(content: 'Percakapan tersimpan', isUser: true),
        ChatMessage(content: 'Halo dari Boo', isUser: false),
      ];
    await tester.pumpWidget(
      MaterialApp(
        home: ChatbotPage(repository: PendingChat(), history: store),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Percakapan tersimpan'), findsOneWidget);
    expect(find.text('Halo dari Boo'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
