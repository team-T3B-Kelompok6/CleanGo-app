import 'package:cleango_app/features/chatbot/controllers/chatbot_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatbotController', () {
    late ChatbotController controller;

    setUp(() => controller = ChatbotController());
    tearDown(() => controller.dispose());

    test('draft state follows trimmed input', () {
      controller.updateDraft('   ');
      expect(controller.hasMessage, isFalse);

      controller.updateDraft('Halo');
      expect(controller.hasMessage, isTrue);
    });

    test('sends trimmed messages and clears the draft state', () {
      controller.updateDraft('  Halo Boo  ');

      expect(controller.sendMessage('  Halo Boo  '), isTrue);
      expect(controller.messages, ['Halo Boo']);
      expect(controller.hasMessage, isFalse);
    });

    test('ignores empty messages', () {
      expect(controller.sendMessage('   '), isFalse);
      expect(controller.messages, isEmpty);
    });
  });
}
