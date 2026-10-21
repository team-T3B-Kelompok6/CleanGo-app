import 'package:cleango_app/features/support/controllers/support_controller.dart';
import 'package:cleango_app/features/support/data/faq_data.dart';
import 'package:cleango_app/features/support/models/faq_item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

FaqItemModel _faq(String id, String category) => FaqItemModel(
  id: id,
  question: 'Pertanyaan $id?',
  answer: 'Jawaban $id.',
  category: category,
  icon: Icons.help_outline_rounded,
);

void main() {
  group('SupportController.groupByCategory', () {
    test('groups FAQs by category keeping the catalogue order', () {
      final controller = SupportController();
      final groups = controller.groupByCategory([
        _faq('1', 'Jadwal'),
        _faq('2', 'Pembayaran'),
        _faq('3', 'Jadwal'),
      ]);

      expect(groups.keys.toList(), ['Jadwal', 'Pembayaran']);
      expect(groups['Jadwal']!.map((f) => f.id), ['1', '3']);
      expect(groups['Pembayaran']!.map((f) => f.id), ['2']);
    });

    test('puts entries without a category under Umum', () {
      final controller = SupportController();
      final groups = controller.groupByCategory([
        _faq('1', ''),
        _faq('2', '   '),
        _faq('3', 'Layanan'),
      ]);

      expect(groups.keys.toList(), ['Umum', 'Layanan']);
      expect(groups['Umum']!.length, 2);
    });

    test('returns an empty map for an empty list', () {
      expect(SupportController().groupByCategory(const []), isEmpty);
    });
  });

  group('bundled FAQ data', () {
    test('every bundled FAQ carries a category', () {
      for (final faq in FaqData.initialFaqs) {
        expect(faq.category, isNotEmpty, reason: faq.id);
      }
    });
  });
}
