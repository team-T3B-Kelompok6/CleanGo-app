import 'package:cleango_app/core/network/api_exception.dart';
import 'package:cleango_app/features/chatbot/models/image_analysis.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> response({
  String cleanliness = 'moderate',
  String confidence = 'high',
  String status = 'analyzed',
  String tidiness = 'cluttered',
}) => {
  'status': status,
  'reply': 'Kotoran tampak pada foto.',
  'analysis': {
    'cleanliness': cleanliness,
    'tidiness': tidiness,
    'observations': 'Kotoran tampak pada foto.',
    'confidence': confidence,
  },
};

void main() {
  test('analysis contract needs no object, target, or recommendations', () {
    final result = ImageAnalysis.fromJson(response());
    expect(result.status, 'analyzed');
    expect(result.needsClarification, isFalse);
    expect(result.analysis['tidiness'], 'cluttered');
  });

  test('medium with visible dirt is tentative, not rejected for quality', () {
    final result = ImageAnalysis.fromJson(response(confidence: 'medium'));
    expect(result.needsClarification, isFalse);
    expect(result.isTentative, isTrue);
  });
  test('optional reasons validate and old payload remains supported', () {
    final json = response(confidence: 'medium', tidiness: 'unknown');
    json['analysis']['cleanlinessReason'] = 'widespread_dirt';
    json['analysis']['tidinessReason'] = 'not_applicable';
    expect(
      ImageAnalysis.fromJson(json).cleanlinessReasonText,
      contains('beberapa area'),
    );
    json['analysis']['cleanlinessReason'] = 'private OCR';
    expect(() => ImageAnalysis.fromJson(json), throwsA(isA<ApiException>()));
  });
  test('contradictory tidiness cannot display an unsupported grade', () {
    for (final confidence in ['high', 'medium']) {
      final json = response(confidence: confidence, tidiness: 'tidy');
      json['analysis']['tidinessReason'] = 'many_items_unarranged';
      final result = ImageAnalysis.fromJson(json);
      expect(result.needsClarification, isFalse);
      expect(result.isTidinessUnknown, isTrue);
      expect(
        result.tidinessReasonText,
        'Bukti kerapian terpisah belum tersedia.',
      );
    }
  });
  test('medium without matching evidence abstains', () {
    final json = response(confidence: 'medium');
    json['analysis']['observations'] = 'Barang tampak tidak tertata.';
    expect(ImageAnalysis.fromJson(json).needsClarification, isTrue);
  });
  for (final confidence in ['low']) {
    test('$confidence confidence cannot display a definite grade', () {
      expect(
        ImageAnalysis.fromJson(response(confidence: confidence))
            .needsClarification,
        isTrue,
      );
    });
  }
  test(
    'unknown cleanliness and server clarification override high confidence',
    () {
      expect(
        ImageAnalysis.fromJson(response(cleanliness: 'unknown'))
            .needsClarification,
        isTrue,
      );
      expect(
        ImageAnalysis.fromJson(response(status: 'needs_clarification'))
            .needsClarification,
        isTrue,
      );
    },
  );
  for (final invalid in [
    response(cleanliness: 'medium'),
    response(tidiness: 'messy'),
    response(status: 'recommended'),
    response(confidence: 'certain'),
    {...response(), 'analysis': null},
  ]) {
    test('reject malformed response $invalid', () {
      expect(
        () => ImageAnalysis.fromJson(invalid),
        throwsA(isA<ApiException>()),
      );
    });
  }
}
