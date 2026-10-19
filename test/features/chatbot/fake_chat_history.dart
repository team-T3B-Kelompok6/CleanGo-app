import 'package:cleango_app/features/chatbot/data/chat_history_store.dart';
import 'package:cleango_app/features/chatbot/models/chat_message.dart';

class FakeChatHistory extends ChatHistoryStore {
  List<ChatMessage> saved = [];
  bool failLoad = false;
  bool failSave = false;
  @override
  Future<List<ChatMessage>> load() async {
    if (failLoad) throw StateError('storage unavailable');
    return List.of(saved);
  }

  @override
  Future<void> save(List<ChatMessage> messages) async {
    if (failSave) throw StateError('storage unavailable');
    saved = List.of(messages);
  }
}
