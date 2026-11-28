import 'package:cleango_app/shared/widgets/app_camera_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AppCameraPreviewPage renders without crashing when camera unavailable', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AppCameraPreviewPage(),
      ),
    );

    // Widget renders safely without waiting for native camera init
    expect(find.byType(AppCameraPreviewPage), findsOneWidget);
  });
}
