import 'dart:typed_data';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/token_storage.dart';
import '../models/chat_message.dart';
import '../models/image_analysis.dart';

class ChatSuggestion {
  const ChatSuggestion({required this.question, required this.source});
  final String question;
  final String source;
}

class FaqChoice {
  const FaqChoice({required this.id, required this.question});
  final String id;
  final String question;
}

class ChatReply {
  const ChatReply({
    required this.answer,
    this.faqChoices = const [],
    this.faqNextPage,
  });
  final String answer;
  final List<FaqChoice> faqChoices;
  final int? faqNextPage;
}

abstract interface class ChatbotGateway {
  Future<ChatReply> reply(
    String message,
    List<ChatMessage> history, {
    List<String>? faqIds,
  });
  Future<List<ChatSuggestion>> suggestions();
  void close();
}

class ChatbotRepository implements ChatbotGateway, ImageAnalysisGateway {
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
  Future<ChatReply> reply(
    String message,
    List<ChatMessage> history, {
    List<String>? faqIds,
  }) async {
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
        'faqIds': ?faqIds,
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
    final rawChoices = data['faqChoices'];
    final choices = <FaqChoice>[];
    if (rawChoices != null) {
      if (rawChoices is! List || rawChoices.length > 5) {
        throw const ApiException.simple(
          'Daftar FAQ tidak valid. Buka FAQ kembali.',
        );
      }
      for (final choice in rawChoices) {
        if (choice is! Map<String, dynamic> ||
            choice['id'] is! String ||
            !RegExp(r'^[1-9]\d*$').hasMatch(choice['id'] as String) ||
            (int.tryParse(choice['id'] as String) ?? 9007199254740992) >
                9007199254740991 ||
            choices.any((item) => item.id == choice['id']) ||
            choice['question'] is! String ||
            (choice['question'] as String).trim().isEmpty ||
            (choice['question'] as String).length > 255) {
          throw const ApiException.simple(
            'Daftar FAQ tidak valid. Buka FAQ kembali.',
          );
        }
        choices.add(
          FaqChoice(
            id: choice['id'] as String,
            question: choice['question'] as String,
          ),
        );
      }
    }
    final nextPage = data['faqNextPage'];
    if (nextPage != null &&
        (choices.isEmpty ||
            nextPage is! int ||
            nextPage < 2 ||
            nextPage > 9007199254740991)) {
      throw const ApiException.simple(
        'Halaman FAQ tidak valid. Buka FAQ kembali.',
      );
    }
    return ChatReply(
      answer: (data['answer'] as String).trim(),
      faqChoices: List.unmodifiable(choices),
      faqNextPage: nextPage as int?,
    );
  }

  @override
  Future<ImageAnalysis> analyzeImage(
    List<int> bytes,
    String contentType,
  ) async {
    if (!const [
          'image/jpeg',
          'image/png',
          'image/webp',
        ].contains(contentType) ||
        bytes.isEmpty ||
        bytes.length > 5 * 1024 * 1024) {
      throw const ApiException.simple(
        'Foto harus JPEG, PNG, atau WebP dan maksimal 5 MB.',
      );
    }
    // Copy before first await: route disposal may wipe its preview while auth loads.
    final upload = Uint8List.fromList(bytes);
    try {
      final token = await _tokens.readAccessToken();
      if (token == null || token.split('.').length != 3) {
        throw const ApiException(
          statusCode: 401,
          message: 'Masuk sebagai customer untuk menganalisis foto.',
        );
      }
      final response = await _client.postBytes(
        '${ApiConfig.customerChat}/analyze-image',
        bytes: upload,
        contentType: contentType,
        token: token,
        timeout: const Duration(seconds: 45),
      );
      final data = response['data'];
      if (data is! Map<String, dynamic>) {
        throw const ApiException.simple('Hasil analisis foto tidak valid.');
      }
      return ImageAnalysis.fromJson(data);
    } finally {
      upload.fillRange(0, upload.length, 0);
    }
  }

  @override
  void close() => _client.close();
}
