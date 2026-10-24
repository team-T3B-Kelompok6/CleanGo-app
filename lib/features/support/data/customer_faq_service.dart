import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../models/faq_item_model.dart';

class CustomerFaqService {
  CustomerFaqService({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;

  static const _categoryIcons = {
    'Layanan': Icons.cleaning_services_outlined,
    'Pembayaran': Icons.payments_outlined,
    'Jadwal': Icons.edit_calendar_outlined,
    'SOP': Icons.rule_outlined,
  };

  Future<List<FaqItemModel>> fetchFaqs(String token) async {
    final res = await _client.get(ApiConfig.customerFaqs, token: token);
    final list = res['data'] as List<dynamic>? ?? [];
    return list.map((e) => _fromApiJson(e as Map<String, dynamic>)).toList();
  }

  /// Records one read so the backend can rank popular questions.
  Future<void> recordView(String token, String faqId) async {
    final id = faqId.replaceFirst('faq-', '');
    await _client.post('${ApiConfig.customerFaqs}/$id/view', token: token);
  }

  FaqItemModel _fromApiJson(Map<String, dynamic> j) {
    final category = j['category'] as String? ?? '';
    return FaqItemModel(
      id: 'faq-${j['id'] ?? ''}',
      question: j['question'] as String? ?? '',
      answer: j['answer'] as String? ?? '',
      category: category,
      viewCount: (j['viewCount'] as num?)?.toInt() ?? 0,
      icon: _categoryIcons[category] ?? Icons.help_outline_rounded,
    );
  }
}
