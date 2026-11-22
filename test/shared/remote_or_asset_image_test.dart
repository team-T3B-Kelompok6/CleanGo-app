import 'package:cleango_app/shared/widgets/remote_or_asset_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('network URL uses Image.network', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 48,
            height: 48,
            child: RemoteOrAssetImage(source: 'https://example.com/a.png'),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(Image), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('SVG asset renders', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 48,
            height: 48,
            child: RemoteOrAssetImage(
              source: 'assets/icons/service_placeholder.svg',
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty source shows generic placeholder', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 48,
            height: 48,
            child: RemoteOrAssetImage(source: ''),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(ColoredBox), findsAtLeastNWidgets(1));
    expect(tester.takeException(), isNull);
  });
}
