import 'package:cleango_app/core/network/api_client.dart';
import 'package:cleango_app/core/storage/token_storage.dart';
import 'package:cleango_app/features/chatbot/controllers/chatbot_controller.dart';
import 'package:cleango_app/features/chatbot/data/chatbot_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_chat_history.dart';

class _GuestTokens implements TokenStorage {
  @override
  Future<String?> readAccessToken() async => null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const baseUrl = String.fromEnvironment('CHATBOT_TEST_API_URL');

  test(
    'Flutter exchanges public messages with the real Express chat route',
    () async {
      final uri = Uri.parse(baseUrl);
      expect(
        ['127.0.0.1', 'localhost', '::1'],
        contains(uri.host),
        reason: 'Run this check only against an isolated local backend.',
      );
      final store = FakeChatHistory();
      final controller = ChatbotController(
        repository: ChatbotRepository(
          tokens: _GuestTokens(),
          client: ApiClient(baseUrl: baseUrl),
        ),
        history: store,
      );
      addTearDown(controller.dispose);
      // Run the isolated backend with CHATBOT_DATABASE_ENABLED=false; no customer data is needed.
      for (final entry in {
        'bhai': 'Halo',
        'Bagaimana cara booking layanan?': 'checkout',
        'bagaimana cara bayar layanan?': 'checkout',
        'Refund dijamin gratis?': 'belum dipastikan',
        'Harga Deep Cleaning dan promo?': 'menunggu integrasi',
      }.entries) {
        expect(await controller.sendMessage(entry.key), isTrue);
        final reply = controller.messages.last;
        expect(reply.failed, isFalse, reason: reply.content);
        expect(reply.isUser, isFalse);
        expect(
          reply.content.toLowerCase(),
          contains(entry.value.toLowerCase()),
        );
        expect(store.saved.last.content, reply.content);
        expect(controller.isSending, isFalse);
      }
    },
    skip: baseUrl.isEmpty
        ? 'Set CHATBOT_TEST_API_URL for the optional local Express integration check.'
        : false,
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
