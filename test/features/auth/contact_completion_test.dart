import 'dart:convert';

import 'package:cleango_app/core/network/api_client.dart';
import 'package:cleango_app/core/storage/app_preferences.dart';
import 'package:cleango_app/features/auth/controllers/contact_completion_controller.dart';
import 'package:cleango_app/features/auth/data/api_auth_service.dart';
import 'package:cleango_app/features/auth/widgets/contact_completion_gate.dart';
import 'package:cleango_app/features/profile/data/customer_profile_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

final DateTime _clock = DateTime.utc(2026, 1, 10, 12);

http.Client _okClient() => MockClient(
  (request) async => http.Response(jsonEncode({'data': {}}), 200),
);

http.Client _conflictClient() => MockClient(
  (request) async => http.Response(
    jsonEncode({'message': 'PHONE_TAKEN', 'code': 'PHONE_TAKEN'}),
    409,
  ),
);

http.Client _profileClient({
  String? phone,
  String email = '',
  String? authProvider,
  bool fail = false,
}) {
  return MockClient((request) async {
    if (fail) throw http.ClientException('server offline');
    return http.Response(
      jsonEncode({
        'data': {
          'id': '7',
          'name': 'Budi',
          'phone': phone,
          'email': email,
          'authProvider': authProvider,
        },
      }),
      200,
    );
  });
}

class _FakeStore implements ContactCompletionStore, CachedContactStore {
  final Map<int, int> _skipped = {};
  final Map<int, String> _methods = {};
  final Map<int, CachedContact> _contacts = {};
  int? _lastAccountId;

  @override
  Future<int?> readEmailReminderSkippedAt(int accountId) async =>
      _skipped[accountId];

  @override
  Future<void> saveEmailReminderSkippedAt(
    int accountId,
    DateTime skippedAt,
  ) async {
    _skipped[accountId] = skippedAt.toUtc().millisecondsSinceEpoch;
  }

  @override
  Future<String?> readLoginMethod(int accountId) async => _methods[accountId];

  @override
  Future<void> saveLoginMethod(int accountId, String method) async {
    _methods[accountId] = method;
  }

  @override
  Future<int?> readLastAccountId() async => _lastAccountId;

  @override
  Future<void> saveLastAccountId(int accountId) async {
    _lastAccountId = accountId;
  }

  @override
  Future<CachedContact?> readCachedContact(int accountId) async =>
      _contacts[accountId];

  @override
  Future<void> saveCachedContact(CachedContact contact) async {
    _contacts[contact.accountId] = contact;
  }
}

_FakeStore _store() => _FakeStore();

ContactCompletionController _controller({
  ContactCompletionStore? store,
  http.Client? client,
  DateTime Function()? now,
}) {
  return ContactCompletionController(
    store: store ?? _store(),
    profileService: CustomerProfileService(
      client: ApiClient(client: client ?? _okClient()),
    ),
    now: now ?? (() => _clock),
  );
}

User _googleUser({String? phone, String email = 'budi@gmail.com', int id = 7}) {
  return User(id: id, name: 'Budi', email: email, phone: phone, role: 'customer');
}

User _phoneUser({String email = '', int id = 9}) {
  return User(
    id: id,
    name: 'Budi',
    email: email,
    phone: '081234567890',
    role: 'customer',
  );
}

void main() {
  test('Google tanpa nomor telepon menampilkan gate wajib', () async {
    final controller = _controller(store:_store());

    await controller.start(
      user: _googleUser(phone: null),
      method: ContactCompletionMethod.google,
      accessToken: 'token',
    );

    expect(controller.shouldShowPhoneGate, isTrue);
    expect(controller.shouldShowEmailReminder, isFalse);
  });

  test('Google dengan nomor valid tidak diminta lagi', () async {
    final controller = _controller(store:_store());

    await controller.start(
      user: _googleUser(phone: '081234567890'),
      method: ContactCompletionMethod.google,
      accessToken: 'token',
    );

    expect(controller.shouldShowPhoneGate, isFalse);
  });

  test('menyimpan nomor telepon menunggu server lalu menutup gate', () async {
    String? sentPhone;
    final client = MockClient((request) async {
      sentPhone = (jsonDecode(request.body) as Map<String, dynamic>)['phone']
          as String?;
      return http.Response(jsonEncode({'data': {}}), 200);
    });
    final controller = _controller(
      store: _store(),
      client: client,
    );

    await controller.start(
      user: _googleUser(phone: null),
      method: ContactCompletionMethod.google,
      accessToken: 'token',
    );
    await controller.submitPhone('081234567890');

    expect(sentPhone, '081234567890');
    expect(controller.shouldShowPhoneGate, isFalse);
  });

  test('409 tetap menampilkan gate dengan pesan ramah', () async {
    final controller = _controller(
      store: _store(),
      client: _conflictClient(),
    );

    await controller.start(
      user: _googleUser(phone: null),
      method: ContactCompletionMethod.google,
      accessToken: 'token',
    );
    await controller.submitPhone('081234567890');

    expect(controller.shouldShowPhoneGate, isTrue);
    expect(
      controller.message,
      'Nomor telepon sudah terdaftar. Gunakan nomor lain.',
    );
  });

  test('nomor telepon buruk ditolak validasi lokal', () async {
    final controller = _controller(store:_store());

    await controller.start(
      user: _googleUser(phone: null),
      method: ContactCompletionMethod.google,
      accessToken: 'token',
    );
    await controller.submitPhone('123');

    expect(controller.phoneError, isNotNull);
    expect(controller.shouldShowPhoneGate, isTrue);
  });

  test('login nomor telepon dengan email kosong mengingatkan email', () async {
    final controller = _controller(store:_store());

    await controller.start(
      user: _phoneUser(email: ''),
      method: ContactCompletionMethod.phone,
      accessToken: 'token',
    );

    expect(controller.shouldShowEmailReminder, isTrue);
  });

  test('email placeholder internal dianggap belum ada', () async {
    final controller = _controller(store:_store());

    await controller.start(
      user: _phoneUser(email: 'budi@cleango.customer.local'),
      method: ContactCompletionMethod.phone,
      accessToken: 'token',
    );

    expect(controller.shouldShowEmailReminder, isTrue);
  });

  test('email pribadi valid tidak diingatkan', () async {
    final controller = _controller(store:_store());

    await controller.start(
      user: _phoneUser(email: 'budi@mail.com'),
      method: ContactCompletionMethod.phone,
      accessToken: 'token',
    );

    expect(controller.shouldShowEmailReminder, isFalse);
  });

  test('lewati enam hari masih diam, tujuh hari muncul lagi', () async {
    final preferences = _store();
    await preferences.saveEmailReminderSkippedAt(
      9,
      _clock.subtract(const Duration(days: 6)),
    );
    final stillHidden = _controller(
      store: preferences,
      now: () => _clock,
    );
    await stillHidden.start(
      user: _phoneUser(email: ''),
      method: ContactCompletionMethod.phone,
      accessToken: 'token',
    );
    expect(stillHidden.shouldShowEmailReminder, isFalse);

    final preferencesAtSeven = _store();
    await preferencesAtSeven.saveEmailReminderSkippedAt(
      9,
      _clock.subtract(const Duration(days: 7)),
    );
    final shownAgain = _controller(
      store:preferencesAtSeven,
      now: () => _clock,
    );
    await shownAgain.start(
      user: _phoneUser(email: ''),
      method: ContactCompletionMethod.phone,
      accessToken: 'token',
    );
    expect(shownAgain.shouldShowEmailReminder, isTrue);
  });

  test('pengingat tersimpan per akun dan tahan restart', () async {
    final preferences = _store();
    final first = _controller(store: preferences, now: () => _clock);
    await first.start(
      user: _phoneUser(email: ''),
      method: ContactCompletionMethod.phone,
      accessToken: 'token',
    );
    await first.skipEmail();
    expect(await preferences.readEmailReminderSkippedAt(9), isNotNull);

    final afterRestart = _controller(store: preferences, now: () => _clock);
    await afterRestart.start(
      user: _phoneUser(email: ''),
      method: ContactCompletionMethod.phone,
      accessToken: 'token',
    );
    expect(afterRestart.shouldShowEmailReminder, isFalse);

    final otherAccount = _controller(
      store: preferences,
      now: () => _clock,
    );
    await otherAccount.start(
      user: _phoneUser(email: '', id: 10),
      method: ContactCompletionMethod.phone,
      accessToken: 'token',
    );
    expect(otherAccount.shouldShowEmailReminder, isTrue);
  });

  test('berganti akun me-reset gate akun lama', () async {
    final controller = _controller(store:_store());

    await controller.start(
      user: _googleUser(phone: null),
      method: ContactCompletionMethod.google,
      accessToken: 'token-lama',
    );
    await controller.start(
      user: _googleUser(phone: '081234567890', id: 8),
      method: ContactCompletionMethod.google,
      accessToken: 'token-baru',
    );

    expect(controller.shouldShowPhoneGate, isFalse);
  });

  test('response telepon yang terlambat tidak menutup gate akun baru', () async {
    final preferences = _store();
    final lateClient = MockClient((request) async {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      return http.Response(jsonEncode({'data': {}}), 200);
    });
    final controller = _controller(
      store: preferences,
      client: lateClient,
      now: () => _clock,
    );

    await controller.start(
      user: _googleUser(phone: null),
      method: ContactCompletionMethod.google,
      accessToken: 'token-lama',
    );
    final pending = controller.submitPhone('081234567890');
    await controller.start(
      user: _googleUser(phone: '081234567890', id: 8),
      method: ContactCompletionMethod.google,
      accessToken: 'token-baru',
    );
    await pending;

    expect(controller.shouldShowPhoneGate, isFalse);
  });

  test('menyimpan email pribadi menutup pengingat', () async {
    final controller = _controller(store:_store());

    await controller.start(
      user: _phoneUser(email: ''),
      method: ContactCompletionMethod.phone,
      accessToken: 'token',
    );
    await controller.submitEmail('budi@mail.com');

    expect(controller.shouldShowEmailReminder, isFalse);
  });

  testWidgets('popup wajib tidak tertutup sentuhan luar atau kembali', (
    tester,
  ) async {
    final controller = _controller(store:_store());
    await controller.start(
      user: _googleUser(phone: null),
      method: ContactCompletionMethod.google,
      accessToken: 'token',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ContactCompletionGate(
          controller: controller,
          child: const Scaffold(body: Text('Beranda')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nomor telepon wajib'), findsOneWidget);

    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();
    expect(find.text('Nomor telepon wajib'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Nomor telepon wajib'), findsOneWidget);
  });

  testWidgets('409 pada popup tetap menampilkan gate', (tester) async {
    final controller = _controller(
      store: _store(),
      client: _conflictClient(),
    );
    await controller.start(
      user: _googleUser(phone: null),
      method: ContactCompletionMethod.google,
      accessToken: 'token',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ContactCompletionGate(
          controller: controller,
          child: const Scaffold(body: Text('Beranda')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '081234567890');
    await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.text('Nomor telepon sudah terdaftar. Gunakan nomor lain.'),
      findsOneWidget,
    );
    expect(find.text('Nomor telepon wajib'), findsOneWidget);
  });

  testWidgets('Google dengan nomor lengkap tidak membuka popup', (tester) async {
    final controller = _controller(store:_store());
    await controller.start(
      user: _googleUser(phone: '081234567890'),
      method: ContactCompletionMethod.google,
      accessToken: 'token',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ContactCompletionGate(
          controller: controller,
          child: const Scaffold(body: Text('Beranda')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nomor telepon wajib'), findsNothing);
    expect(find.text('Lengkapi email (opsional)'), findsNothing);
  });

  testWidgets('pengingat email bisa dilewati', (tester) async {
    final controller = _controller(store:_store());
    await controller.start(
      user: _phoneUser(email: ''),
      method: ContactCompletionMethod.phone,
      accessToken: 'token',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ContactCompletionGate(
          controller: controller,
          child: const Scaffold(body: Text('Beranda')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Lengkapi email (opsional)'), findsOneWidget);

    await tester.tap(find.text('Lewati'));
    await tester.pumpAndSettle();

    expect(find.text('Lengkapi email (opsional)'), findsNothing);
    expect(controller.shouldShowEmailReminder, isFalse);
  });

  test('restart dengan sesi Google tanpa HP memunculkan gate lagi', () async {
    final preferences = _store();
    await preferences.saveLastAccountId(7);
    await preferences.saveLoginMethod(7, 'google');
    await preferences.saveCachedContact(
      const CachedContact(
        accountId: 7,
        email: 'budi@gmail.com',
        authProvider: 'google',
      ),
    );
    final controller = _controller(
      store: preferences,
      client: _profileClient(phone: null, authProvider: 'google'),
    );

    await controller.restore(accessToken: 'token');

    expect(controller.shouldShowPhoneGate, isTrue);
  });

  test('HP yang berhasil disimpan tidak diminta lagi saat restart', () async {
    final preferences = _store();
    final controller = _controller(
      store: preferences,
      client: _profileClient(phone: null),
    );
    await controller.start(
      user: _googleUser(phone: null),
      method: ContactCompletionMethod.google,
      accessToken: 'token',
    );
    await controller.submitPhone('081234567890');

    expect((await preferences.readCachedContact(7))?.phone, '081234567890');

    final afterRestart = _controller(
      store: preferences,
      client: _profileClient(phone: '081234567890', authProvider: 'google'),
    );
    await afterRestart.restore(accessToken: 'token');

    expect(afterRestart.shouldShowPhoneGate, isFalse);
  });

  test('email yang disimpan tidak diminta lagi saat restart', () async {
    final preferences = _store();
    final controller = _controller(
      store: preferences,
      client: _profileClient(phone: '081234567890', email: ''),
    );
    await controller.start(
      user: _phoneUser(email: ''),
      method: ContactCompletionMethod.phone,
      accessToken: 'token',
    );
    await controller.submitEmail('budi@mail.com');

    final refreshed = _controller(
      store: preferences,
      client: _profileClient(
        phone: '081234567890',
        email: 'budi@mail.com',
        authProvider: 'local',
      ),
    );
    await refreshed.restore(accessToken: 'token');
    expect(refreshed.shouldShowEmailReminder, isFalse);

    final offline = _controller(
      store: preferences,
      client: _profileClient(fail: true),
    );
    await offline.restore(accessToken: 'token');
    expect(offline.shouldShowEmailReminder, isFalse);
  });

  test('restart: lewati enam hari diam, tujuh hari muncul lagi', () async {
    final atSix = _store();
    await atSix.saveLastAccountId(9);
    await atSix.saveLoginMethod(9, 'phone');
    await atSix.saveEmailReminderSkippedAt(
      9,
      _clock.subtract(const Duration(days: 6)),
    );
    final hidden = _controller(
      store: atSix,
      client: _profileClient(phone: '081234567890', email: ''),
      now: () => _clock,
    );
    await hidden.restore(accessToken: 'token');
    expect(hidden.shouldShowEmailReminder, isFalse);

    final atSeven = _store();
    await atSeven.saveLastAccountId(9);
    await atSeven.saveLoginMethod(9, 'phone');
    await atSeven.saveEmailReminderSkippedAt(
      9,
      _clock.subtract(const Duration(days: 7)),
    );
    final shown = _controller(
      store: atSeven,
      client: _profileClient(phone: '081234567890', email: ''),
      now: () => _clock,
    );
    await shown.restore(accessToken: 'token');
    expect(shown.shouldShowEmailReminder, isTrue);
  });

  test('restore memakai authProvider server bila login method hilang', () async {
    final preferences = _store();
    await preferences.saveLastAccountId(7);
    await preferences.saveCachedContact(
      const CachedContact(accountId: 7, email: 'budi@gmail.com'),
    );
    final controller = _controller(
      store: preferences,
      client: _profileClient(phone: null, authProvider: 'google'),
    );

    await controller.restore(accessToken: 'token');

    expect(controller.shouldShowPhoneGate, isTrue);
  });

  test('authProvider local memulihkan pengingat email', () async {
    final preferences = _store();
    await preferences.saveLastAccountId(9);
    await preferences.saveCachedContact(
      const CachedContact(accountId: 9, phone: '081234567890'),
    );
    final controller = _controller(
      store: preferences,
      client: _profileClient(
        phone: '081234567890',
        email: '',
        authProvider: 'local',
      ),
    );

    await controller.restore(accessToken: 'token');

    expect(controller.shouldShowEmailReminder, isTrue);
  });

  test('restore tanpa akun terakhir tidak menebak gate', () async {
    final controller = _controller(
      store: _store(),
      client: _profileClient(phone: null, authProvider: 'google'),
    );

    await controller.restore(accessToken: 'token');

    expect(controller.shouldShowPhoneGate, isFalse);
    expect(controller.shouldShowEmailReminder, isFalse);
  });

  test('restore offline tanpa cache tidak membuka gate', () async {
    final preferences = _store();
    await preferences.saveLastAccountId(7);
    await preferences.saveLoginMethod(7, 'google');
    final controller = _controller(
      store: preferences,
      client: _profileClient(fail: true),
    );

    await controller.restore(accessToken: 'token');

    expect(controller.shouldShowPhoneGate, isFalse);
  });

  test('response telepon lama setelah logout tidak mengubah gate', () async {
    final preferences = _store();
    final lateClient = MockClient((request) async {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      return http.Response(jsonEncode({'data': {}}), 200);
    });
    final controller = _controller(
      store: preferences,
      client: lateClient,
      now: () => _clock,
    );
    await controller.start(
      user: _googleUser(phone: null),
      method: ContactCompletionMethod.google,
      accessToken: 'token-lama',
    );
    final pending = controller.submitPhone('081234567890');
    controller.clear();
    await pending;

    expect(controller.shouldShowPhoneGate, isFalse);
    expect(controller.isSubmitting, isFalse);
  });

  testWidgets('menutup popup tidak ikut mem-pop halaman baru', (tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    final controller = _controller(store:_store());
    await controller.start(
      user: _googleUser(phone: null),
      method: ContactCompletionMethod.google,
      accessToken: 'token',
    );

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: ContactCompletionGate(
          controller: controller,
          navigatorKey: navigatorKey,
          child: const Scaffold(body: Text('Beranda')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Nomor telepon wajib'), findsOneWidget);

    navigatorKey.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('Halaman Baru')),
      ),
    );
    await tester.pumpAndSettle();

    controller.clear();
    await tester.pumpAndSettle();

    expect(find.text('Nomor telepon wajib'), findsNothing);
    expect(find.text('Halaman Baru'), findsOneWidget);
  });

  testWidgets('clear sebelum frame tidak meninggalkan popup kosong', (
    tester,
  ) async {
    final controller = _controller(store:_store());
    await controller.start(
      user: _googleUser(phone: null),
      method: ContactCompletionMethod.google,
      accessToken: 'token',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ContactCompletionGate(
          controller: controller,
          child: const Scaffold(body: Text('Beranda')),
        ),
      ),
    );
    controller.clear();
    await tester.pumpAndSettle();

    expect(find.text('Nomor telepon wajib'), findsNothing);
  });
}
