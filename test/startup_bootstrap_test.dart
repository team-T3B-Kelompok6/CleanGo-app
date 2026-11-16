import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'package:cleango_app/main.dart' as entry;

void main() {
  testWidgets(
    'startup frame pertama tidak ada exception callback Future di setState',
    (WidgetTester tester) async {
      final previousInstance = SharedPreferencesAsyncPlatform.instance;
      SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();

      dynamic startupException;
      dynamic cleanupException;
      try {
        // Entry main publik menjalankan runApp(const _BootstrapView()) asli.
        await entry.main();

        // Pump terukur (bukan pumpAndSettle tanpa batas; Splash animasi berulang).
        await tester.pump(const Duration(seconds: 2));
        await tester.pump(const Duration(seconds: 2));
      } finally {
        // Ambil exception yang tertangkap binding flutter_test tanpa override onError.
        startupException = tester.takeException();

        // Melepas root widget asli dalam tes.
        await tester.pumpWidget(const SizedBox.shrink());

        // Majukan waktu fake tester cukup melewati guard production 8 detik
        // agar task/timer bootstrap (Firebase, _guard) selesai setelah widget dilepas.
        await tester.pump(const Duration(seconds: 10));

        // Ambil exception yang mungkin timbul selama cleanup melalui binding.
        cleanupException = tester.takeException();

        // Pulihkan platform instance penyimpanan setelah task dibersihkan;
        // jangan membaca store pengguna.
        SharedPreferencesAsyncPlatform.instance = previousInstance;
      }

      final exception = startupException ?? cleanupException;

      // Kontrak regresi: tidak ada exception pada startup frame pertama.
      // Source lama: 'setState() callback argument returned a Future'
      //  --> exception tidak null dengan pesan itu --> tes merah (RED).
      // Source diperbaiki: exception null --> tes hijau (GREEN).
      // Semua exception dipertanggungjawabkan melalui takeException; tidak ada yang dibuang.
      expect(
        exception,
        isNull,
        reason: 'tidak boleh ada exception saat startup: $exception',
      );
    },
  );
}
