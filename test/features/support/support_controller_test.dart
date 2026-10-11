import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cleango_app/features/support/controllers/support_controller.dart';
import 'package:cleango_app/features/support/models/faq_item_model.dart';

void main() {
  group('FaqItemModel Tests', () {
    test('copyWith updates specified fields correctly', () {
      const model = FaqItemModel(
        id: 'faq-1',
        question: 'Bagaimana cara menjadwalkan ulang pesanan?',
        answer: 'Maksimal 3 jam sebelum jadwal pengerjaan.',
        highlight: 'Perubahan jadwal pertama kali bebas biaya.',
        icon: Icons.edit_calendar_outlined,
        isExpanded: false,
      );

      final updated = model.copyWith(isExpanded: true);
      expect(updated.isExpanded, true);
      expect(updated.id, 'faq-1');
      expect(updated.question, model.question);
      expect(updated.highlight, model.highlight);
    });
  });

  group('SupportController Tests', () {
    late SupportController controller;

    setUp(() {
      controller = SupportController();
    });

    test('Initial state contains 5 FAQs and first item is expanded', () {
      expect(controller.allFaqs.length, 5);
      expect(controller.totalTopicsCount, 5);
      expect(controller.searchQuery, '');
      expect(controller.filteredFaqs.length, 5);
      expect(controller.allFaqs.first.isExpanded, true);
    });

    test('search filters FAQs by question or answer keyword', () {
      var notified = false;
      controller.addListener(() {
        notified = true;
      });

      controller.search('jadwal');
      expect(notified, true);
      expect(controller.searchQuery, 'jadwal');
      expect(controller.filteredFaqs.isNotEmpty, true);
      expect(controller.filteredFaqs.any((f) => f.question.toLowerCase().contains('jadwal')), true);

      // Search non-existent
      controller.search('xyz999tidakada');
      expect(controller.filteredFaqs.isEmpty, true);
      expect(controller.hasSearchResults, false);
    });

    test('resetSearch clears search query and restores all FAQs', () {
      controller.search('bayar');
      expect(controller.searchQuery, 'bayar');

      controller.resetSearch();
      expect(controller.searchQuery, '');
      expect(controller.filteredFaqs.length, 5);
    });

    test('toggleExpand flips isExpanded state of target FAQ', () {
      final targetId = controller.allFaqs[1].id;
      final initialExpanded = controller.allFaqs[1].isExpanded;

      controller.toggleExpand(targetId);
      final updated = controller.allFaqs.firstWhere((f) => f.id == targetId);
      expect(updated.isExpanded, !initialExpanded);

      controller.toggleExpand(targetId);
      final reverted = controller.allFaqs.firstWhere((f) => f.id == targetId);
      expect(reverted.isExpanded, initialExpanded);
    });

    test('setExpanded sets exact expansion state', () {
      final targetId = controller.allFaqs[0].id;
      controller.setExpanded(targetId, false);
      expect(controller.allFaqs.firstWhere((f) => f.id == targetId).isExpanded, false);

      controller.setExpanded(targetId, true);
      expect(controller.allFaqs.firstWhere((f) => f.id == targetId).isExpanded, true);
    });
  });
}
