import 'package:cleango_app/core/theme/app_theme.dart';
import 'package:cleango_app/features/chatbot/pages/chatbot_page.dart';
import 'package:cleango_app/features/support/data/faq_data.dart';
import 'package:cleango_app/features/support/controllers/support_controller.dart';
import 'package:cleango_app/features/support/pages/help_center_page.dart';
import 'package:cleango_app/shared/widgets/chatbot_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

Widget _host() => ChangeNotifierProvider(
  create: (_) => SupportController(),
  child: MaterialApp(theme: AppTheme.light, home: const HelpCenterPage()),
);

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  testWidgets('help dropdowns fit a narrow screen with larger text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => SupportController(),
        child: MaterialApp(
          theme: AppTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.4)),
            child: child!,
          ),
          home: const HelpCenterPage(),
        ),
      ),
    );
    final terms = find.text('Syarat & Ketentuan Layanan');
    await tester.scrollUntilVisible(
      terms,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    await tester.tap(terms);
    await tester.pump();
    final lastSection = find.text('4. Privasi & Keamanan Data');
    await tester.ensureVisible(lastSection);
    await tester.pump();
    expect(lastSection, findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('every FAQ opens and closes inline without a bottom sheet', (
    tester,
  ) async {
    await tester.pumpWidget(_host());
    final controller = tester
        .element(find.byType(HelpCenterPage))
        .read<SupportController>();
    for (final faq in FaqData.initialFaqs) {
      controller.setExpanded(faq.id, false);
      await tester.pump();
      // A popular question also appears in its category list, so target one.
      final question = find.text(faq.question).first;
      await tester.scrollUntilVisible(
        question,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();
      expect(find.text(faq.answer), findsNothing);
      await tester.tap(question);
      await tester.pump();
      expect(find.text(faq.answer), findsWidgets);
      expect(
        tester.widget<Text>(find.text(faq.answer).first).textAlign,
        TextAlign.justify,
      );
      expect(find.byType(BottomSheet), findsNothing);
      await tester.ensureVisible(question);
      await tester.pump();
      await tester.tap(question);
      await tester.pump();
      expect(find.text(faq.answer), findsNothing);
    }
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('help is readable and terms expand inline', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => SupportController(),
        child: MaterialApp(theme: AppTheme.light, home: const HelpCenterPage()),
      ),
    );
    Future<void> finishTransition() async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }

    await tester.tap(find.byIcon(Icons.help_outline_rounded).first);
    await finishTransition();
    expect(find.text('Pusat Dukungan'), findsOneWidget);
    await tester.tap(find.text('Mengerti'));
    await finishTransition();

    final terms = find.text('Syarat & Ketentuan Layanan');
    await tester.scrollUntilVisible(
      terms,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await finishTransition();
    await tester.tap(terms);
    await finishTransition();
    for (final description in [
      'CleanGo menjamin kepuasan pelanggan',
      'Perubahan jadwal dan pembatalan dapat dilakukan',
      'Seluruh staf cleaner telah melalui uji integritas',
      'Data identitas, nomor kontak, serta alamat rumah',
    ]) {
      expect(
        tester.widget<Text>(find.textContaining(description)).textAlign,
        TextAlign.justify,
      );
    }
    final lastSection = find.text('4. Privasi & Keamanan Data');
    await tester.ensureVisible(lastSection);
    await finishTransition();
    expect(lastSection, findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(find.byType(BottomSheet), findsNothing);
    await tester.ensureVisible(terms);
    await finishTransition();
    await tester.tap(terms);
    await finishTransition();
    expect(lastSection, findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('question input does not filter FAQs and sends its text to Boo', (
    tester,
  ) async {
    await tester.pumpWidget(_host());
    final input = find.byKey(const ValueKey('help-question-input'));
    final decoration = tester.widget<TextField>(input).decoration!;
    expect(
      find.descendant(
        of: find.byWidget(decoration.prefixIcon!),
        matching: find.byType(ChatbotIcon),
      ),
      findsOneWidget,
    );
    expect(
      tester
          .widget<IconButton>(
            find.widgetWithIcon(IconButton, Icons.send_rounded),
          )
          .onPressed,
      isNull,
    );
    await tester.enterText(input, '  Bagaimana cara booking?  ');
    await tester.pump();
    expect(find.text(FaqData.initialFaqs.first.question), findsOneWidget);
    expect(find.text('Topik bantuan tidak ditemukan'), findsNothing);
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
    expect(find.byType(ChatbotPage), findsOneWidget);
    expect(
      tester.widget<ChatbotPage>(find.byType(ChatbotPage)).initialMessage,
      'Bagaimana cara booking?',
    );
    expect(find.text('Bagaimana cara booking?'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('blank or oversized help questions do not navigate', (
    tester,
  ) async {
    await tester.pumpWidget(_host());
    final input = find.byKey(const ValueKey('help-question-input'));
    await tester.enterText(input, '   ');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump();
    expect(find.byType(ChatbotPage), findsNothing);
    await tester.enterText(input, 'a' * 2001);
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump();
    expect(find.byType(ChatbotPage), findsNothing);
    expect(find.text('Pertanyaan maksimal 2000 karakter.'), findsOneWidget);
    expect(find.text(FaqData.initialFaqs.first.question), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
