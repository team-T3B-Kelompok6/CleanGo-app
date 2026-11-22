import 'package:cleango_app/core/theme/refresh_scroll_physics.dart';
import 'package:cleango_app/shared/widgets/anchored_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('konten pendek: onRefresh satu kali, konten tidak ikut turun', (
    tester,
  ) async {
    final controller = ScrollController();
    var refreshCount = 0;
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnchoredRefreshIndicator(
            onRefresh: () async => refreshCount++,
            child: ListView.builder(
              controller: controller,
              physics: refreshScrollPhysics,
              itemCount: 2,
              itemBuilder: (context, index) =>
                  ListTile(title: Text('Item $index')),
            ),
          ),
        ),
      ),
    );
    final before = tester.getTopLeft(find.text('Item 0')).dy;
    await tester.drag(find.byType(ListView), const Offset(0, 300));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(controller.offset, 0);
    expect(tester.getTopLeft(find.text('Item 0')).dy, before);
    expect(find.byType(RefreshIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    expect(refreshCount, 1);
    expect(tester.getTopLeft(find.text('Item 0')).dy, before);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'konten panjang: overscroll ke bawah diam, gulir normal tetap jalan',
    (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnchoredRefreshIndicator(
              onRefresh: () async {},
              child: ListView.builder(
                controller: controller,
                physics: refreshScrollPhysics,
                itemCount: 60,
                itemBuilder: (context, index) =>
                    ListTile(title: Text('Item $index')),
              ),
            ),
          ),
        ),
      );
      final before = tester.getTopLeft(find.text('Item 0')).dy;
      await tester.drag(find.byType(ListView), const Offset(0, 300));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(controller.offset, 0);
      expect(tester.getTopLeft(find.text('Item 0')).dy, before);

      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pump();
      expect(controller.offset, greaterThan(0));
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
