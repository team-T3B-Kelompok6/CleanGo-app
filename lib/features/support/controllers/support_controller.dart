import 'package:flutter/foundation.dart';

import '../data/faq_data.dart';
import '../models/faq_item_model.dart';

class SupportController extends ChangeNotifier {
  SupportController() {
    _faqs = List<FaqItemModel>.from(FaqData.initialFaqs);
  }

  late List<FaqItemModel> _faqs;
  bool _termsExpanded = false;

  List<FaqItemModel> get allFaqs => List.unmodifiable(_faqs);
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
}
