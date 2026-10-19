import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/token_storage.dart';
import '../models/chat_message.dart';

abstract interface class ChatbotGateway {
  Future<String> reply(String message, List<ChatMessage> history);
  void close();
}

class ChatbotRepository implements ChatbotGateway {
  ChatbotRepository({ApiClient? client, TokenStorage? tokens})
    : _client = client ?? ApiClient(),
      _tokens = tokens ?? SecureTokenStorage();

  final ApiClient _client;
  final TokenStorage _tokens;

  @override
  Future<String> reply(String message, List<ChatMessage> history) async {
    final token = await _tokens.readAccessToken();
    // Local demo sessions are not server JWTs; public help remains available.
    final serverToken = token != null && token.split('.').length == 3;
    final context = history.where((entry) => !entry.failed).toList();
    final response = await _client.post(
      '/customer/chat',
      {
        'message': message,
        'history': context
            .skip(context.length > 8 ? context.length - 8 : 0)
            .map((entry) => entry.toJson())
            .toList(),
      },
      headers: {if (serverToken) 'Authorization': 'Bearer $token'},
      timeout: const Duration(seconds: 25),
    );
    final data = response['data'];
    if (data is! Map<String, dynamic> ||
        data['answer'] is! String ||
        (data['answer'] as String).trim().isEmpty) {
      throw const ApiException(
        'Jawaban Boo belum tersedia. Silakan coba lagi.',
      );
    }
    return (data['answer'] as String).trim();
  }

  @override
  void close() => _client.close();
}
