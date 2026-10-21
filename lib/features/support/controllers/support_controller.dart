import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/storage/token_storage.dart';
import '../data/customer_faq_service.dart';
import '../data/faq_data.dart';
import '../models/faq_item_model.dart';

class SupportController extends ChangeNotifier {
  SupportController({
    TokenStorage? tokenStorage,
    CustomerFaqService? service,
    List<FaqItemModel>? initialFaqs,
  })  : _tokenStorage = tokenStorage,
        _service = service ?? CustomerFaqService() {
    _faqs = List<FaqItemModel>.from(initialFaqs ?? FaqData.initialFaqs);
  }

  final TokenStorage? _tokenStorage;
  final CustomerFaqService _service;
  late List<FaqItemModel> _faqs;
  String? _error;
  bool _loading = false;

  String? get error => _error;
  bool get loading => _loading;

  Future<void> loadFromApi() async {
    final token = await _tokenStorage?.readAccessToken();
    if (token == null || token.isEmpty) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final remote = await _service.fetchFaqs(token);
      if (remote.isNotEmpty) _faqs = remote;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
  bool _termsExpanded = false;

  List<FaqItemModel> get allFaqs => List.unmodifiable(_faqs);

  /// The most opened questions (top 5). Ties keep the catalogue order.
  List<FaqItemModel> get popularFaqs {
    final indexed = _faqs.indexed.toList()
      ..sort((a, b) {
        final byViews = b.$2.viewCount.compareTo(a.$2.viewCount);
        return byViews != 0 ? byViews : a.$1.compareTo(b.$1);
      });
    return indexed.take(5).map((entry) => entry.$2).toList(growable: false);
  }

  /// FAQs grouped by their admin-managed category, keeping the catalogue order.
  /// Entries without a category fall under "Umum".
  Map<String, List<FaqItemModel>> groupByCategory(List<FaqItemModel> faqs) {
    final groups = <String, List<FaqItemModel>>{};
    for (final faq in faqs) {
      final key = faq.category.trim().isEmpty ? 'Umum' : faq.category.trim();
      groups.putIfAbsent(key, () => <FaqItemModel>[]).add(faq);
    }
    return groups;
  }
  int get totalTopicsCount => _faqs.length;
  bool get termsExpanded => _termsExpanded;

  void toggleTerms() {
    _termsExpanded = !_termsExpanded;
    notifyListeners();
  }

  void toggleExpand(String id) {
    final index = _faqs.indexWhere((faq) => faq.id == id);
    if (index == -1) return;

    final current = _faqs[index];
    final opening = !current.isExpanded;
    _faqs[index] = current.copyWith(isExpanded: opening);
    notifyListeners();
    if (opening) _recordViewOnce(id);
  }

  final Set<String> _viewedIds = <String>{};

  /// Counts a read once per session so the ranking is not inflated by toggling.
  void _recordViewOnce(String id) {
    if (!_viewedIds.add(id)) return;
    unawaited(_recordView(id));
  }

  Future<void> _recordView(String id) async {
    final token = await _tokenStorage?.readAccessToken();
    if (token == null || token.isEmpty) return;
    try {
      await _service.recordView(token, id);
    } catch (_) {
      // Counting a read must never break the screen.
    }
  }

  void setExpanded(String id, bool isExpanded) {
    final index = _faqs.indexWhere((faq) => faq.id == id);
    if (index == -1) return;

    if (_faqs[index].isExpanded != isExpanded) {
      _faqs[index] = _faqs[index].copyWith(isExpanded: isExpanded);
      notifyListeners();
    }
  }
}
