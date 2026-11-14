import 'dart:io';

import 'package:cleango_app/features/chatbot/data/chat_image_cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'deletes known picker copies, never originals or arbitrary cache files',
    () async {
      final root = await Directory.systemTemp.createTemp('cleango-cache-test');
      addTearDown(() => root.delete(recursive: true));
      final cache = await Directory('${root.path}/cache').create();
      final original = await File('${root.path}/image_picker_original.jpg')
          .writeAsBytes([1]);
      final unknown = await File('${cache.path}/important.jpg')
          .writeAsBytes([1]);
      final copy = await File('${cache.path}/image_picker_123.jpg')
          .writeAsBytes([1]);
      final otherFeatureCopy = await File(
        '${cache.path}/flutter_image_picker_review.jpg',
      ).writeAsBytes([1]);
      final camera = await File(
        '${cache.path}/12345678-1234-1234-1234-123456789abc123456.jpg',
      ).writeAsBytes([1]);
      final galleryDir = await Directory(
        '${cache.path}/12345678-1234-1234-1234-123456789abc',
      ).create();
      final gallery = await File('${galleryDir.path}/vacation.png')
          .writeAsBytes([1]);
      for (final file in [original, unknown, copy, camera, gallery]) {
        await deleteChatPickerCopy(file.path, cache: cache);
      }
      expect(await original.exists(), isTrue);
      expect(await unknown.exists(), isTrue);
      expect(await otherFeatureCopy.exists(), isTrue);
      expect(await copy.exists(), isFalse);
      expect(await camera.exists(), isFalse);
      expect(await gallery.exists(), isFalse);
    },
  );
}
