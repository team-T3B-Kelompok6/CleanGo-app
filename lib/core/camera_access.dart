import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const _permissionsChannel = MethodChannel('com.cleango.app/permissions');

enum CameraPermissionStatus { granted, denied, permanentlyDenied }

Future<CameraPermissionStatus> ensureCameraPermission() async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
    return CameraPermissionStatus.granted;
  }
  try {
    final status = await _permissionsChannel.invokeMethod<String>('requestCameraPermission');
    return switch (status) {
      'granted' => CameraPermissionStatus.granted,
      'denied' => CameraPermissionStatus.denied,
      'permanently_denied' => CameraPermissionStatus.permanentlyDenied,
      _ => CameraPermissionStatus.denied,
    };
  } on MissingPluginException {
    return CameraPermissionStatus.denied;
  } on PlatformException {
    return CameraPermissionStatus.denied;
  }
}

Future<void> openAppSettings() async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
  try {
    await _permissionsChannel.invokeMethod('openAppSettings');
  } on MissingPluginException {
    return;
  } on PlatformException {
    return;
  }
}