import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cleango_app/features/chatbot/models/image_analysis.dart';
import 'package:cleango_app/features/chatbot/pages/chat_image_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

class PendingAnalysis implements ImageAnalysisGateway {
  final answer = Completer<ImageAnalysis>();
  List<int>? sent;
  @override
  Future<ImageAnalysis> analyzeImage(List<int> bytes, String contentType) {
    sent = bytes;
    expect(contentType, 'image/png');
    return answer.future;
  }

  @override
  void close() {}
}

Uint8List photo() => base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jRZkAAAAASUVORK5CYII=',
);

void main() {
  testWidgets('late picker result after dispose is wiped without upload', (
    tester,
  ) async {
    final picked = Completer<Uint8List?>();
    final gateway = PendingAnalysis();
    final bytes = photo();
    await tester.pumpWidget(
      MaterialApp(
        home: ChatImagePage(
          repository: gateway,
          pickImage: (_) => picked.future,
        ),
      ),
    );
    await tester.tap(find.text('Galeri'));
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    picked.complete(bytes);
    await tester.pump();
    expect(bytes.every((byte) => byte == 0), isTrue);
    expect(gateway.sent, isNull);
    expect(tester.takeException(), isNull);
  });

  for (final confidence in ['high', 'medium', 'low']) {
    testWidgets(
      'analysis only, $confidence confidence, narrow and large text',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 640));
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(() async {
          tester.platformDispatcher.clearTextScaleFactorTestValue();
          await tester.binding.setSurfaceSize(null);
        });
        final gateway = PendingAnalysis();
        await tester.pumpWidget(
          MaterialApp(
            home: ChatImagePage(
              repository: gateway,
              pickImage: (_) async => photo(),
            ),
          ),
        );
        await tester.scrollUntilVisible(find.text('Galeri'), 200);
        await tester.tap(find.text('Galeri'));
        await tester.pumpAndSettle();
        expect(gateway.sent, isNull);
        expect(
          find.textContaining('layanan analisis eksternal'),
          findsOneWidget,
        );
        expect(find.textContaining('Groq'), findsNothing);
        await tester.scrollUntilVisible(find.text('Kirim dan analisis'), 200);
        await Scrollable.ensureVisible(
          tester.element(find.text('Kirim dan analisis')),
          alignment: 0.5,
        );
        await tester.pump();
        await tester.tap(find.text('Kirim dan analisis'));
        await tester.pump();
        gateway.answer.complete(
          ImageAnalysis.fromJson({
            'reply': 'Hasil dari foto.',
            'analysis': {
              'cleanliness': 'heavy',
              'tidiness': 'cluttered',
              'observations': 'Kotoran tampak pada foto.',
              'confidence': confidence,
              'cleanlinessReason': 'dirt_buildup',
              'tidinessReason': 'many_items_unarranged',
            },
            'status': 'analyzed',
          }),
        );
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.text('Kekotoran yang terlihat'),
          -200,
        );
        expect(
          find.text(
            confidence == 'low' ? 'Belum dapat dinilai' : 'Kotor berat',
          ),
          confidence == 'low' ? findsNWidgets(2) : findsOneWidget,
        );
        expect(
          find.text('Perkiraan'),
          confidence == 'medium' ? findsOneWidget : findsNothing,
        );
        expect(find.text('Terlihat penumpukan kotoran.'), findsOneWidget);
        expect(
          find.text('Banyak barang terlihat tidak tertata.'),
          findsOneWidget,
        );
        expect(find.text('Rekomendasi layanan'), findsNothing);
        expect(find.textContaining('Lihat layanan'), findsNothing);
        expect(find.text('Target'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'gallery preview needs confirmation, then clears bytes after result',
    (tester) async {
      final gateway = PendingAnalysis();
      final bytes = photo();
      final sources = <ImageSource>[];
      await tester.pumpWidget(
        MaterialApp(
          home: ChatImagePage(
            repository: gateway,
            pickImage: (source) async {
              sources.add(source);
              return bytes;
            },
          ),
        ),
      );
      await tester.tap(find.text('Galeri'));
      await tester.pumpAndSettle();
      expect(sources, [ImageSource.gallery]);
      expect(gateway.sent, isNull);
      expect(find.byType(Image), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Kirim dan analisis'), 200);
      await Scrollable.ensureVisible(
        tester.element(find.text('Kirim dan analisis')),
        alignment: 0.5,
      );
      await tester.pump();
      await tester.tap(find.text('Kirim dan analisis'));
      await tester.pump();
      expect(find.text('Boo sedang menganalisis foto…'), findsOneWidget);
      gateway.answer.complete(
        const ImageAnalysis(
          reply: 'Perlu dibersihkan.',
          analysis: {
            'cleanliness': 'moderate',
            'tidiness': 'unknown',
            'confidence': 'high',
            'observations': 'Kotoran tampak pada foto.',
          },
          status: 'analyzed',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Perlu dibersihkan.'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
      expect(bytes.every((byte) => byte == 0), isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('cancel wipes image without sending', (tester) async {
    final gateway = PendingAnalysis();
    final bytes = photo();
    await tester.pumpWidget(
      MaterialApp(
        home: ChatImagePage(repository: gateway, pickImage: (_) async => bytes),
      ),
    );
    await tester.tap(find.text('Kamera'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Batal'), 200);
    await Scrollable.ensureVisible(
      tester.element(find.text('Batal')),
      alignment: 0.5,
    );
    await tester.pump();
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(gateway.sent, isNull);
    expect(bytes.every((byte) => byte == 0), isTrue);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('failure wipes photo and permits new selection', (tester) async {
    final gateway = PendingAnalysis();
    final bytes = photo();
    await tester.pumpWidget(
      MaterialApp(
        home: ChatImagePage(repository: gateway, pickImage: (_) async => bytes),
      ),
    );
    await tester.tap(find.text('Galeri'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Kirim dan analisis'), 200);
    await Scrollable.ensureVisible(
      tester.element(find.text('Kirim dan analisis')),
      alignment: 0.5,
    );
    await tester.pump();
    await tester.tap(find.text('Kirim dan analisis'));
    await tester.pump();
    gateway.answer.completeError(Exception('offline'));
    await tester.pumpAndSettle();
    expect(bytes.every((byte) => byte == 0), isTrue);
    expect(
      find.text('Analisis foto gagal. Pilih foto lagi untuk mencoba ulang.'),
      findsOneWidget,
    );
    expect(find.byType(Image), findsNothing);
    expect(find.text('Galeri'), findsOneWidget);
  });

  testWidgets('unsupported photo and oversize never reach gateway', (
    tester,
  ) async {
    final gateway = PendingAnalysis();
    var bytes = Uint8List.fromList([1, 2, 3]);
    await tester.pumpWidget(
      MaterialApp(
        home: ChatImagePage(repository: gateway, pickImage: (_) async => bytes),
      ),
    );
    await tester.tap(find.text('Galeri'));
    await tester.pumpAndSettle();
    expect(
      find.text('Foto harus JPEG, PNG, atau WebP dan maksimal 5 MB.'),
      findsOneWidget,
    );
    bytes = Uint8List(5 * 1024 * 1024 + 1);
    await tester.tap(find.text('Galeri'));
    await tester.pumpAndSettle();
    expect(gateway.sent, isNull);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('dispose wipes selected photo', (tester) async {
    final bytes = photo();
    await tester.pumpWidget(
      MaterialApp(
        home: ChatImagePage(
          repository: PendingAnalysis(),
          pickImage: (_) async => bytes,
        ),
      ),
    );
    await tester.tap(find.text('Galeri'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox.shrink());
    expect(bytes.every((byte) => byte == 0), isTrue);
  });
}
