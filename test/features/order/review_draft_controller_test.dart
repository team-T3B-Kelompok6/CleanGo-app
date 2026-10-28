import 'dart:typed_data';

import 'package:cleango_app/features/booking/domain/models/review_photo_model.dart';
import 'package:cleango_app/features/order/controllers/review_draft_controller.dart';
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

    test('limits photos to three and tracks removed server photos', () {
      final photo = ReviewPhotoModel(
        bytes: Uint8List.fromList([1, 2, 3]),
        contentType: 'image/jpeg',
      );
      expect(controller.addPhoto(photo), isTrue);
      expect(controller.addPhoto(photo), isTrue);
      expect(controller.addPhoto(photo), isTrue);
      expect(controller.addPhoto(photo), isFalse);
      expect(controller.photos, hasLength(3));

      final removed = controller.removePhoto(1);
      expect(removed, same(photo));
      expect(controller.photos, hasLength(2));
      expect(controller.removedPhotoIds, isEmpty);
    });

    test('keeps existing photo ids when they are removed during edit', () {
      final existing = ReviewPhotoModel(id: '9', url: '/uploads/a.jpg');
      controller = ReviewDraftController(initialPhotos: [existing]);

      controller.removePhoto(0);

      expect(controller.photos, isEmpty);
      expect(controller.removedPhotoIds, ['9']);
    });
  });
}
