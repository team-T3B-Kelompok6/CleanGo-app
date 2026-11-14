import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _pendingBooPicker = 'boo_image_picker_pending';

Future<void> markBooPicker(bool pending) =>
    SharedPreferencesAsync().setBool(_pendingBooPicker, pending);

/// Call only for an XFile returned by this Boo pick (or its marked lost result).
/// Resolve symlinks so gallery originals outside app cache cannot be removed.
Future<void> deleteChatPickerCopy(String path, {Directory? cache}) async {
  if (kIsWeb) return;
  final directory =
      cache ??
      (Platform.isIOS ? Directory.systemTemp : await getTemporaryDirectory());
  final root = await directory.resolveSymbolicLinks();
  final file = File(path);
  if (!await file.exists()) return;
  final resolved = await file.resolveSymbolicLinks();
  if (!resolved.startsWith('$root${Platform.pathSeparator}')) return;
  final name = file.uri.pathSegments.last;
  final knownPicker =
      name.startsWith('image_picker') ||
      name.startsWith('scaled_') ||
      name.startsWith('flutter_image_picker') ||
      RegExp(
        r'^[0-9a-fA-F]{8}-(?:[0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}[0-9]+\.jpg$',
      ).hasMatch(name) ||
      RegExp(r'^[0-9a-fA-F]{8}-(?:[0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$')
          .hasMatch(
            file.parent.uri.pathSegments.where((part) => part.isNotEmpty).last,
          );
  if (knownPicker) {
    await file.delete();
  }
}

/// Do not consume another feature's lost review/profile photo.
Future<void> discardLostChatPhotos() async {
  if (kIsWeb) return;
  try {
    if (!Platform.isAndroid) return;
    if (await SharedPreferencesAsync().getBool(_pendingBooPicker) != true) {
      return;
    }
    final lost = await ImagePicker().retrieveLostData();
    for (final file in lost.files ?? <XFile>[]) {
      await deleteChatPickerCopy(file.path);
    }
    await markBooPicker(false);
  } catch (_) {
    // ponytail: crash/native orphan cleanup is best effort; OS owns unreturned cache files.
  }
}
