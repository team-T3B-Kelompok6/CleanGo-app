import 'dart:async';

import 'package:cleango_app/features/service/data/customer_service_reviews_api.dart';
import 'package:cleango_app/features/service/domain/models/service_model.dart';
import 'package:cleango_app/features/service/pages/all_reviews_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeReviewsApi extends CustomerServiceReviewsApi {
  _FakeReviewsApi({
    this.pages = const {},
    this.onFetch,
    this.failPages = const {},
  });

  final Map<int, ServiceReviewsPage> pages;
  final Future<void> Function(int page)? onFetch;
  final Set<int> failPages;
  int calls = 0;

  @override
  Future<ServiceReviewsPage> fetchReviews(
    String serviceId, {
    int page = 1,
    int limit = 10,
  }) async {
    calls++;
    await onFetch?.call(page);
    if (failPages.contains(page)) {
      throw StateError('offline');
    }
    return pages[page] ??
        const ServiceReviewsPage(
          rating: 0,
          reviewCount: 0,
          satisfactionPercentage: 0,
          reviews: [],
          page: 1,
          hasMore: false,
        );
  }
}

class _GatedApi extends CustomerServiceReviewsApi {
  _GatedApi(this.pages, {this.gate});

  final Map<int, ServiceReviewsPage> pages;
  final Completer<void>? gate;
  int calls = 0;

  @override
  Future<ServiceReviewsPage> fetchReviews(
    String serviceId, {
    int page = 1,
    int limit = 10,
  }) async {
    calls++;
    if (calls > 1) await gate?.future;
    return pages[page] ??
        const ServiceReviewsPage(
          rating: 0,
          reviewCount: 0,
          satisfactionPercentage: 0,
          reviews: [],
          page: 1,
          hasMore: false,
        );
  }
}

ServiceReviewModel _review(String name) => ServiceReviewModel(
  name: name,
  comment: 'Komentar $name',
  rating: 5,
  date: 'Hari ini',
);

Future<void> _openReviews(
  WidgetTester tester,
  CustomerServiceReviewsApi api,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: AllReviewsPage(service: _service, api: api),
    ),
  );
  await tester.pump();
}

Future<void> _dragRefresh(WidgetTester tester) async {
  await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

const _service = ServiceModel(
  id: '7',
  title: 'Deep Cleaning',
  description: 'Bersih menyeluruh',
  duration: '2 jam',
  price: 'Rp150.000',
  category: 'Rumah',
  iconPath: 'assets/icons/home.svg',
);

void main() {
  testWidgets('loads public reviews and shows a load-more button', (
    tester,
  ) async {
    final api = _FakeReviewsApi(
      pages: {
        1: const ServiceReviewsPage(
          rating: 4.5,
          reviewCount: 11,
          satisfactionPercentage: 90,
          reviews: [
            ServiceReviewModel(
              name: 'Budi Santoso',
              comment: 'Bersih dan rapi',
              rating: 5,
              date: 'Hari ini',
            ),
          ],
          page: 1,
          hasMore: true,
        ),
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AllReviewsPage(service: _service, api: api),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Budi Santoso'), findsOneWidget);
    expect(find.text('Bersih dan rapi'), findsOneWidget);
    expect(find.text('Muat Lebih Banyak'), findsOneWidget);
  });

  testWidgets('tarik ulang memuat ulang ulasan pendek', (tester) async {
    final api = _FakeReviewsApi(
      pages: {
        1: ServiceReviewsPage(
          rating: 5,
          reviewCount: 1,
          satisfactionPercentage: 100,
          reviews: [_review('Sari')],
          page: 1,
          hasMore: false,
        ),
      },
    );
    await _openReviews(tester, api);
    expect(find.text('Sari'), findsOneWidget);
    final before = api.calls;

    await _dragRefresh(tester);

    expect(api.calls, greaterThan(before));
    expect(find.text('Sari'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('daftar kosong tetap bisa ditarik untuk memuat ulang', (
    tester,
  ) async {
    final api = _FakeReviewsApi();
    await _openReviews(tester, api);
    expect(find.text('Belum ada ulasan untuk layanan ini.'), findsOneWidget);
    final before = api.calls;

    await _dragRefresh(tester);

    expect(api.calls, greaterThan(before));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('error tetap bisa ditarik ulang setelah gagal', (tester) async {
    final api = _FakeReviewsApi(failPages: {1});
    await _openReviews(tester, api);
    expect(find.textContaining('Ulasan belum dapat dimuat'), findsOneWidget);
    final before = api.calls;

    await _dragRefresh(tester);

    expect(api.calls, greaterThan(before));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('refresh menang atas pagination lama', (tester) async {
    final gate = <int, Completer<void>>{};
    final api = _FakeReviewsApi(
      pages: {
        1: ServiceReviewsPage(
          rating: 5,
          reviewCount: 2,
          satisfactionPercentage: 100,
          reviews: [_review('Baru')],
          page: 1,
          hasMore: true,
        ),
        2: ServiceReviewsPage(
          rating: 5,
          reviewCount: 2,
          satisfactionPercentage: 100,
          reviews: [_review('Lama')],
          page: 2,
          hasMore: false,
        ),
      },
      onFetch: (page) async {
        final pending = gate.remove(page);
        if (pending != null) return pending.future;
      },
    );
    final pageTwo = Completer<void>();
    gate[2] = pageTwo;
    await _openReviews(tester, api);
    expect(find.text('Muat Lebih Banyak'), findsOneWidget);

    await tester.tap(find.text('Muat Lebih Banyak'));
    await tester.pump();
    final beforeRefresh = api.calls;
    await _dragRefresh(tester);
    expect(api.calls, greaterThan(beforeRefresh));

    pageTwo.complete();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Baru'), findsOneWidget);
    expect(find.text('Lama'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('refresh tertahan tetap menampilkan indikator tarik', (
    tester,
  ) async {
    final gate = Completer<void>();
    final api = _GatedApi(const {}, gate: gate);
    await _openReviews(tester, api);
    expect(find.text('Belum ada ulasan untuk layanan ini.'), findsOneWidget);
    final callsBeforeDrag = api.calls;

    await tester.drag(
      find.byType(RefreshIndicator).first,
      const Offset(0, 300),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(api.calls, equals(callsBeforeDrag + 1));
    expect(find.byType(RefreshIndicator), findsOneWidget);
    expect(find.byType(RefreshProgressIndicator), findsOneWidget);

    gate.complete();
    await tester.pump(const Duration(seconds: 1));
    expect(api.calls, equals(callsBeforeDrag + 1));
    expect(find.text('Belum ada ulasan untuk layanan ini.'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('pagination diblokir saat refresh berlangsung', (tester) async {
    final gate = Completer<void>();
    final api = _GatedApi({
      1: ServiceReviewsPage(
        rating: 5,
        reviewCount: 2,
        satisfactionPercentage: 100,
        reviews: [_review('Baru')],
        page: 1,
        hasMore: true,
      ),
      2: ServiceReviewsPage(
        rating: 5,
        reviewCount: 2,
        satisfactionPercentage: 100,
        reviews: [_review('Lama')],
        page: 2,
        hasMore: false,
      ),
    }, gate: gate);
    await _openReviews(tester, api);
    expect(find.text('Muat Lebih Banyak'), findsOneWidget);
    final beforeTap = api.calls;

    await tester.drag(
      find.byType(RefreshIndicator).first,
      const Offset(0, 300),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(api.calls, equals(beforeTap + 1));

    await tester.scrollUntilVisible(
      find.text('Muat Lebih Banyak'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Muat Lebih Banyak'));
    await tester.pump();
    expect(api.calls, equals(beforeTap + 1));

    gate.complete();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Baru'), findsOneWidget);
    expect(find.text('Lama'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
