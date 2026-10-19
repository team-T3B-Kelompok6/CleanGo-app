import 'package:cleango_app/core/storage/token_storage.dart';
import 'package:cleango_app/features/chatbot/data/chat_history_store.dart';
import 'package:cleango_app/features/chatbot/models/chat_message.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

class SessionTokens implements TokenStorage {
  String? token = 'session-one';
  @override
  Future<String?> readAccessToken() async => token;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  test('encrypted-store adapter restores the last 60 messages including error flags', () async {
    final tokens = SessionTokens();
    final store = ChatHistoryStore(tokens: tokens);
    await store.load();
    await store.save(
      List.generate(
        70,
        (i) =>
            ChatMessage(content: 'Pesan $i', isUser: i.isEven, failed: i == 69),
      ),
    );
    final restored = await ChatHistoryStore(tokens: tokens).load();
    expect(restored.length, 60);
    expect(restored.first.content, 'Pesan 10');
    expect(restored.last.failed, isTrue);
  });
  test(
    'a different login or guest cannot read the previous session history',
    () async {
      final tokens = SessionTokens();
      final store = ChatHistoryStore(tokens: tokens);
      await store.load();
      await store.save([
        const ChatMessage(content: 'Pesanan pribadi', isUser: true),
      ]);
      tokens.token = 'session-two';
      expect(await ChatHistoryStore(tokens: tokens).load(), isEmpty);
      await expectLater(store.save([]), throwsStateError);
      tokens.token = null;
      expect(await ChatHistoryStore(tokens: tokens).load(), isEmpty);
    },
  );
  test('malformed history is reported rather than silently deleted', () async {
    FlutterSecureStorage.setMockInitialValues({
      'cleango_boo_history_v1': 'invalid json',
    });
    final store = ChatHistoryStore(tokens: SessionTokens());
    await expectLater(store.load(), throwsFormatException);
    await expectLater(store.save([]), throwsStateError);
  });
}
