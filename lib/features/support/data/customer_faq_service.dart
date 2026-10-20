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

  FaqItemModel _fromApiJson(Map<String, dynamic> j) {
    return FaqItemModel(
      id: 'faq-${j['id'] ?? ''}',
      question: j['question'] as String? ?? '',
      answer: j['answer'] as String? ?? '',
      highlight: j['category'] as String?,
      icon: _categoryIcons[j['category']] ?? Icons.help_outline_rounded,
    );
  }
}
