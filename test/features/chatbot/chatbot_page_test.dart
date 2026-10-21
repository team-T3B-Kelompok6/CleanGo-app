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
  Future<String> reply(String message, List<ChatMessage> history) {
    questions.add(message);
    return answer.future;
  }

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
      expect(find.text('Bagaimana cara booking?'), findsOneWidget);
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
    expect(find.byIcon(Icons.image_outlined), findsNothing);
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
        const ChatMessage(content: 'Percakapan tersimpan', isUser: true),
        const ChatMessage(content: 'Halo dari Boo', isUser: false),
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
