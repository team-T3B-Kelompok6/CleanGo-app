import 'dart:convert';

import 'package:cleango_app/features/home/controllers/home_controller.dart';
import 'package:cleango_app/features/home/widgets/promo_banner_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _Images extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    if (!key.endsWith('.png')) return rootBundle.load(key);
    final bytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4z8DwHwAFgAI/ScLbtAAAAABJRU5ErkJggg==',
    );
    return ByteData.sublistView(bytes);
  }
}

const _paths = ['assets/images/a.png', 'assets/images/b.png'];
const _empty = 'assets/images/no_active_promos.png';

Widget _app({
  List<String> paths = const [],
  BannerStatus status = BannerStatus.success,
  VoidCallback? retry,
}) => MaterialApp(
  home: Scaffold(
    body: DefaultAssetBundle(
      bundle: _Images(),
      child: PromoBannerSection(
        bannerPaths: paths,
        status: status,
        onRetry: retry ?? () {},
      ),
    ),
  ),
);

Finder _asset(String path) => find.byWidgetPredicate(
  (widget) =>
      widget is Image &&
      widget.image is AssetImage &&
      (widget.image as AssetImage).assetName == path,
);

Future<void> _advance(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 6));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}

double _page(WidgetTester tester) =>
    tester.widget<PageView>(find.byType(PageView)).controller!.page!;

void main() {
  testWidgets('sukses kosong menampilkan aset pemilik dengan tinggi nyata', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    expect(_asset(_empty), findsOneWidget);
    expect(tester.getSize(_asset(_empty)).height, greaterThan(0));
    expect(
      tester.widget<AspectRatio>(find.byType(AspectRatio)).aspectRatio,
      2170 / 725,
    );
    expect(find.byType(PageView), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'loading dan error tidak menyamar sebagai promo kosong; retry aktif',
    (tester) async {
      var calls = 0;
      await tester.pumpWidget(_app(status: BannerStatus.loading));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(_asset(_empty), findsNothing);
      await tester.pumpWidget(
        _app(status: BannerStatus.error, retry: () => calls++),
      );
      expect(find.text('Gagal memuat promo'), findsOneWidget);
      expect(_asset(_empty), findsNothing);
      await tester.tap(find.text('Coba lagi'));
      expect(calls, 1);
    },
  );

  testWidgets('satu banner statis tanpa placeholder atau carousel', (
    tester,
  ) async {
    await tester.pumpWidget(_app(paths: [_paths.first]));
    await tester.pumpAndSettle();
    expect(_asset(_paths.first), findsOneWidget);
    expect(_asset(_empty), findsNothing);
    expect(find.byType(PageView), findsNothing);
    await tester.pump(const Duration(seconds: 20));
    expect(tester.takeException(), isNull);
  });

  testWidgets('cache real tetap terlihat saat refresh loading atau gagal', (
    tester,
  ) async {
    for (final status in [BannerStatus.loading, BannerStatus.error]) {
      await tester.pumpWidget(_app(paths: [_paths.first], status: status));
      await tester.pumpAndSettle();
      expect(_asset(_paths.first), findsOneWidget);
      expect(_asset(_empty), findsNothing);
    }
    expect(find.text('Gagal memuat promo'), findsOneWidget);
    expect(find.text('Coba lagi'), findsOneWidget);
  });

  testWidgets('gambar URL gagal bukan promo kosong', (tester) async {
    // flutter_test menyediakan HTTP sintetis 400, tidak mengakses internet.
    await tester.pumpWidget(_app(paths: ['https://example.test/broken.png']));
    await tester.pumpAndSettle();
    expect(find.text('Gagal memuat gambar promo'), findsOneWidget);
    expect(_asset(_empty), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('autocycle enam detik terus maju melewati batas terakhir', (
    tester,
  ) async {
    await tester.pumpWidget(_app(paths: _paths));
    await tester.pumpAndSettle();
    expect(_page(tester), 0);
    await _advance(tester);
    expect(_page(tester), 1);
    await _advance(tester);
    expect(_page(tester), 2);
    expect(_asset(_paths.first), findsOneWidget);
    expect(_asset(_empty), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 20));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'manual swipe dan tahan sentuhan menjeda timer lalu melanjutkan',
    (tester) async {
      await tester.pumpWidget(_app(paths: _paths));
      await tester.pumpAndSettle();
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(PageView)),
      );
      await tester.pump(const Duration(seconds: 12));
      expect(_page(tester), 0);
      await gesture.up();
      await tester.drag(find.byType(PageView), const Offset(-600, 0));
      await tester.pumpAndSettle();
      expect(_page(tester), 1);
      await tester.pump(const Duration(seconds: 5));
      expect(_page(tester), 1);
      await _advance(tester);
      expect(_page(tester), 2);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('background menjeda; resumed melanjutkan; dispose aman', (
    tester,
  ) async {
    await tester.pumpWidget(_app(paths: _paths));
    await tester.pumpAndSettle();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(seconds: 20));
    expect(_page(tester), 0);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await _advance(tester);
    expect(_page(tester), 1);
    await tester.pumpWidget(const SizedBox());
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(const Duration(seconds: 20));
    expect(tester.takeException(), isNull);
  });

  testWidgets('pergantian banyak ke satu ke kosong membuang controller lama', (
    tester,
  ) async {
    await tester.pumpWidget(_app(paths: _paths));
    await tester.pumpAndSettle();
    await _advance(tester);
    await tester.pumpWidget(_app(paths: [_paths.first]));
    await tester.pumpAndSettle();
    expect(find.byType(PageView), findsNothing);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    expect(_asset(_empty), findsOneWidget);
    await tester.pumpWidget(_app(paths: _paths));
    await tester.pumpAndSettle();
    expect(_page(tester), 0);
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });
}
