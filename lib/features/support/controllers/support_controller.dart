import 'package:flutter/foundation.dart';
import '../data/faq_data.dart';
import '../models/faq_item_model.dart';

class SupportController extends ChangeNotifier {
  SupportController() {
    _faqs = List<FaqItemModel>.from(FaqData.initialFaqs);
  }

  late List<FaqItemModel> _faqs;
  String _searchQuery = '';

  List<FaqItemModel> get allFaqs => List.unmodifiable(_faqs);
  String get searchQuery => _searchQuery;
  int get totalTopicsCount => _faqs.length;

  List<FaqItemModel> get filteredFaqs {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return List.unmodifiable(_faqs);
    }

    return _faqs.where((faq) {
      final matchQuestion = faq.question.toLowerCase().contains(query);
      final matchAnswer = faq.answer.toLowerCase().contains(query);
      final matchHighlight = faq.highlight?.toLowerCase().contains(query) ?? false;
      return matchQuestion || matchAnswer || matchHighlight;
    }).toList();
  }

  bool get hasSearchResults => filteredFaqs.isNotEmpty;

  void search(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    notifyListeners();
  }

  void toggleExpand(String id) {
    final index = _faqs.indexWhere((faq) => faq.id == id);
    if (index == -1) return;

    final current = _faqs[index];
    _faqs[index] = current.copyWith(isExpanded: !current.isExpanded);
    notifyListeners();
  }

  void setExpanded(String id, bool isExpanded) {
    final index = _faqs.indexWhere((faq) => faq.id == id);
    if (index == -1) return;

    if (_faqs[index].isExpanded != isExpanded) {
      _faqs[index] = _faqs[index].copyWith(isExpanded: isExpanded);
      notifyListeners();
    }
  }

  void resetSearch() {
    if (_searchQuery.isNotEmpty) {
      _searchQuery = '';
      notifyListeners();
    }
  }
}
