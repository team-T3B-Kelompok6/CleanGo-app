import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cleango_app/core/camera_access.dart';

const _channel = MethodChannel('com.cleango.app/permissions');

int _invocationCount = 0;

void _setMock(Future<dynamic> Function(MethodCall call)? handler) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_channel, handler);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    debugDefaultTargetPlatformOverride = null;
    _invocationCount = 0;
    _setMock((call) async {
      _invocationCount++;
      if (call.method == 'requestCameraPermission') return 'granted';
      return null;
    });
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    _invocationCount = 0;
    _setMock(null);
  });

  test('non-android tidak invoke channel dan mengembalikan granted', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    final status = await ensureCameraPermission();
    expect(status, CameraPermissionStatus.granted);
    expect(_invocationCount, 0);
  });

  test('android granted melanjutkan', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    final status = await ensureCameraPermission();
    expect(status, CameraPermissionStatus.granted);
    expect(_invocationCount, 1);
  });

  test('android denied tidak melanjutkan', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    _setMock((call) async {
      _invocationCount++;
      if (call.method == 'requestCameraPermission') return 'denied';
      return null;
    });
    final status = await ensureCameraPermission();
    expect(status, CameraPermissionStatus.denied);
    expect(_invocationCount, 1);
  });

  test('permanently denied tidak membuka pengaturan otomatis', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    var settingsOpened = false;
    _setMock((call) async {
      _invocationCount++;
      if (call.method == 'requestCameraPermission') return 'permanently_denied';
      if (call.method == 'openAppSettings') {
        settingsOpened = true;
        return null;
      }
      return null;
    });
    final status = await ensureCameraPermission();
    expect(status, CameraPermissionStatus.permanentlyDenied);
    expect(settingsOpened, isFalse);
  });

  test('channel error tidak crash dan mengembalikan denied', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    _setMock((call) async {
      throw PlatformException(
        code: 'MissingPlugin',
        message: 'no implementation',
        details: null,
      );
    });
    final status = await ensureCameraPermission();
    expect(status, CameraPermissionStatus.denied);
  });

  testWidgets('tombol panggil native nol sebelum tap dan satu sesudah tap',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    try {
      _invocationCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                await ensureCameraPermission();
              },
              child: const Text('Kamera'),
            ),
          ),
        ),
      );
      expect(_invocationCount, 0);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(_invocationCount, 1);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}