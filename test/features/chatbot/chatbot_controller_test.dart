import 'package:cleango_app/features/chatbot/controllers/chatbot_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import 'dart:async';

import 'package:cleango_app/features/chatbot/data/chatbot_repository.dart';
import 'package:cleango_app/features/chatbot/models/chat_message.dart';

import 'fake_chat_history.dart';

class FakeChatbot implements ChatbotGateway {
  Completer<String>? pending;
  List<ChatMessage> lastHistory = [];
  bool closed = false;
  bool fail = false;
  @override
  Future<String> reply(String message, List<ChatMessage> history) async {
    lastHistory = List.of(history);
    if (fail) throw Exception('offline');
    return pending == null ? 'Halo, saya Boo.' : pending!.future;
  }

  @override
  void close() => closed = true;
}

void main() {
  group('ChatbotController', () {
    late ChatbotController controller;
    late FakeChatbot repository;

    setUp(() {
      repository = FakeChatbot();
      controller = ChatbotController(
        repository: repository,
        history: FakeChatHistory(),
      );
    });
    tearDown(() => controller.dispose());

    test('draft state follows trimmed input', () {
      controller.updateDraft('   ');
      expect(controller.hasMessage, isFalse);

      controller.updateDraft('Halo');
      expect(controller.hasMessage, isTrue);
    });

    test(
      'sends trimmed messages, receives Boo reply and clears draft',
      () async {
        controller.updateDraft('  Halo Boo  ');

        expect(await controller.sendMessage('  Halo Boo  '), isTrue);
        expect(controller.messages.map((message) => message.content), [
          'Halo Boo',
          'Halo, saya Boo.',
        ]);
        expect(controller.messages.last.isUser, isFalse);
        expect(controller.hasMessage, isFalse);
      },
    );

    test('ignores empty messages', () async {
      expect(await controller.sendMessage('   '), isFalse);
      expect(controller.messages, isEmpty);
    });
    test('prevents duplicate submission while a reply is pending', () async {
      repository.pending = Completer<String>();
      final pending = controller.sendMessage('halo');
      expect(controller.isSending, isTrue);
      expect(await controller.sendMessage('duplikat'), isFalse);
      repository.pending!.complete('Jawaban');
      await pending;
      expect(controller.messages.length, 2);
      expect(controller.isSending, isFalse);
    });
    test(
      'shows a useful connection error and permits another message',
      () async {
        repository.fail = true;
        await controller.sendMessage('halo');
        expect(controller.messages.last.failed, isTrue);
        expect(controller.messages.last.content, contains('Pusat Bantuan'));
        expect(controller.isSending, isFalse);
      },
    );
    test(
      'rejects oversized requests before contacting the repository',
      () async {
        expect(await controller.sendMessage('a' * 2001), isFalse);
        expect(controller.messages, isEmpty);
      },
    );
  });
  test(
    'disposing during a request closes resources without notifying later',
    () async {
      final repository = FakeChatbot()..pending = Completer<String>();
      final store = FakeChatHistory();
      final controller = ChatbotController(
        repository: repository,
        history: store,
      );
      await controller.restoreHistory();
      final pending = controller.sendMessage('halo');
      await Future<void>.delayed(Duration.zero);
      controller.dispose();
      repository.pending!.complete('selesai');
      await pending;
      expect(repository.closed, isTrue);
      expect(store.saved.last.content, 'selesai');
    },
  );
  test(
    'restores saved conversation in a new controller and sends it as context',
    () async {
      final store = FakeChatHistory();
      final first = ChatbotController(
        repository: FakeChatbot(),
        history: store,
      );
      await first.sendMessage('Harga home cleaning?');
      first.dispose();
      final repository = FakeChatbot();
      final second = ChatbotController(repository: repository, history: store);
      addTearDown(second.dispose);
      await second.restoreHistory();
      await second.restoreHistory();
      expect(second.messages.map((message) => message.content), [
        'Harga home cleaning?',
        'Halo, saya Boo.',
      ]);
      await second.sendMessage('Luasnya berapa?');
      expect(repository.lastHistory.length, 2);
      expect(store.saved.length, 4);
    },
  );
  test(
    'storage failure does not prevent chatting or overwrite unread history',
    () async {
      final store = FakeChatHistory()..failLoad = true;
      store.saved = [
        const ChatMessage(content: 'Jangan tertimpa', isUser: true),
      ];
      final controller = ChatbotController(
        repository: FakeChatbot(),
        history: store,
      );
      addTearDown(controller.dispose);
      await controller.sendMessage('Halo');
      expect(controller.historyUnavailable, isTrue);
      expect(controller.messages.last.content, 'Halo, saya Boo.');
      expect(store.saved.single.content, 'Jangan tertimpa');
    },
  );
  test(
    'failed save is visible without replacing a successful server reply',
    () async {
      final controller = ChatbotController(
        repository: FakeChatbot(),
        history: FakeChatHistory()..failSave = true,
      );
      addTearDown(controller.dispose);
      await controller.sendMessage('Halo');
      expect(controller.historyUnavailable, isTrue);
      expect(controller.messages.last.failed, isFalse);
    },
  );
}
