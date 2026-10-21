import 'package:cleango_app/core/theme/app_theme.dart';
import 'package:cleango_app/features/support/controllers/support_controller.dart';
import 'package:cleango_app/features/support/data/faq_data.dart';
import 'package:cleango_app/features/support/models/faq_item_model.dart';
import 'package:cleango_app/features/support/pages/help_center_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

FaqItemModel _faq(String id, String category, {int views = 0}) => FaqItemModel(
  id: id,
  question: 'Pertanyaan $id?',
  answer: 'Jawaban $id.',
  category: category,
  viewCount: views,
  icon: Icons.help_outline_rounded,
);

Widget _host(SupportController controller) => ChangeNotifierProvider.value(
  value: controller,
  child: MaterialApp(theme: AppTheme.light, home: const HelpCenterPage()),
);

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  group('SupportController.popularFaqs', () {
    test('orders by read count', () {
      final controller = SupportController(
        initialFaqs: [
          _faq('a', 'Jadwal', views: 1),
          _faq('b', 'Pembayaran', views: 9),
          _faq('c', 'Layanan', views: 5),
        ],
      );

      expect(controller.popularFaqs.map((f) => f.id), ['b', 'c', 'a']);
    });

    test('keeps the catalogue order when counts are equal', () {
      final controller = SupportController(
        initialFaqs: [_faq('a', 'Jadwal'), _faq('b', 'Jadwal'), _faq('c', 'Jadwal')],
      );

      expect(controller.popularFaqs.map((f) => f.id), ['a', 'b', 'c']);
    });

    test('shows at most five questions', () {
      final controller = SupportController(
        initialFaqs: [for (var i = 0; i < 8; i++) _faq('f$i', 'Layanan', views: i)],
      );

      expect(controller.popularFaqs.length, 5);
      expect(controller.popularFaqs.first.id, 'f7');
    });
  });

  testWidgets('help center shows popular questions above the categories', (
    tester,
  ) async {
    final controller = SupportController(initialFaqs: FaqData.initialFaqs);
    await tester.pumpWidget(_host(controller));

    expect(find.text('PERTANYAAN POPULER (FAQ)'), findsOneWidget);

    // The categorised list sits below the popular questions.
    final heading = find.text('SEMUA PERTANYAAN');
    await tester.scrollUntilVisible(
      heading,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    expect(heading, findsOneWidget);

    // Category labels come from the FAQ categories.
    for (final category in ['Jadwal', 'Pembayaran', 'Layanan']) {
      expect(find.text(category), findsWidgets, reason: category);
    }
    expect(tester.takeException(), isNull);
  });
}
