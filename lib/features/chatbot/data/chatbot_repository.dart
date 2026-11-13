import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/token_storage.dart';
import '../models/chat_message.dart';

class ChatSuggestion {
  const ChatSuggestion({required this.question, required this.source});
  final String question;
  final String source;
}

abstract interface class ChatbotGateway {
  Future<String> reply(String message, List<ChatMessage> history);
  Future<List<ChatSuggestion>> suggestions();
  void close();
}

class ChatbotRepository implements ChatbotGateway {
  ChatbotRepository({
    ApiClient? client,
    TokenStorage? tokens,
    DateTime Function()? now,
  }) : _client = client ?? ApiClient(),
       _tokens = tokens ?? SecureTokenStorage(),
       _now = now ?? DateTime.now;

  final ApiClient _client;
  final TokenStorage _tokens;
  final DateTime Function() _now;

  @override
  Future<List<ChatSuggestion>> suggestions() async {
    final token = await _tokens.readAccessToken();
    final response = await _client.get(
      '${ApiConfig.customerChat}/suggestions',
      token: token != null && token.split('.').length == 3 ? token : null,
    );
    final data = response['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .where((item) => item['question'] is String && item['source'] is String)
        .map(
          (item) => ChatSuggestion(
            question: item['question'] as String,
            source: item['source'] as String,
          ),
        )
        .toList();
  }

  @override
  Future<String> reply(String message, List<ChatMessage> history) async {
    final token = await _tokens.readAccessToken();
    // Local demo sessions are not server JWTs; public help remains available.
    final serverToken = token != null && token.split('.').length == 3;
    final now = _now();
    final context = history
        .where((entry) => !entry.failed && !entry.isExpired(now))
        .toList();
    final response = await _client.post(
      ApiConfig.customerChat,
      body: {
        'message': message,
        'history': context
            .skip(context.length > 8 ? context.length - 8 : 0)
            .map((entry) => entry.toJson())
            .toList(),
      },
      token: serverToken ? token : null,
      timeout: const Duration(seconds: 25),
    );
    final data = response['data'];
    if (data is! Map<String, dynamic> ||
        data['answer'] is! String ||
        (data['answer'] as String).length > 2500 ||
        (data['answer'] as String).trim().isEmpty) {
      throw const ApiException.simple(
        'Jawaban Boo belum tersedia. Silakan coba lagi.',
      );
    }
    return (data['answer'] as String).trim();
  }

  @override
  void close() => _client.close();
}
