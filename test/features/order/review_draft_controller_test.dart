import 'package:cleango_app/features/order/controllers/review_draft_controller.dart';

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReviewDraftController', () {
    late ReviewDraftController controller;

    setUp(() => controller = ReviewDraftController());

    test('starts with the same default rating and satisfaction tags', () {
      expect(controller.selectedRating, 5);
      expect(controller.ratingLabel, 'Sempurna (5/5)');
      expect(controller.selectedChips, [
        'Bersih Maksimal ✨',
        'Tepat Waktu ⏰',
        'Peralatan Lengkap 📦',
      ]);
    });

    test('updates rating label and toggles a satisfaction tag', () {
      controller
        ..selectRating(3)
        ..toggleChip('Tepat Waktu ⏰')
        ..toggleChip('Ramah & Sopan 😊');

      expect(controller.ratingLabel, 'Cukup Baik (3/5)');
      expect(controller.selectedChips, isNot(contains('Tepat Waktu ⏰')));
      expect(controller.selectedChips, contains('Ramah & Sopan 😊'));
    });

    test('limits attached photos to three and removes by index', () {
      expect(controller.addMockPhoto(), isTrue);
      expect(controller.addMockPhoto(), isTrue);
      expect(controller.addMockPhoto(), isTrue);
      expect(controller.addMockPhoto(), isFalse);
      expect(controller.attachedPhotos, hasLength(3));
      expect(File(controller.attachedPhotos.first).existsSync(), isTrue);

      controller.removePhoto(1);
      expect(controller.attachedPhotos, hasLength(2));
    });
  });
}
