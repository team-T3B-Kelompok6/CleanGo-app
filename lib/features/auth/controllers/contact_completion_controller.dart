import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/storage/app_preferences.dart';
import '../../profile/data/customer_profile_service.dart';
import '../../profile/models/user_profile_model.dart';
import '../data/api_auth_service.dart';
import '../data/auth_validators.dart';

enum ContactCompletionMethod { google, phone }

CachedContactStore? _cacheStoreOf(ContactCompletionStore store) {
  return store is CachedContactStore ? store as CachedContactStore : null;
}

/// Menentukan popup melengkapi nomor telepon (wajib) dan pengingat email
/// opsional setelah masuk, serta memulihkannya setelah aplikasi dibuka ulang.
/// Status hanya hidup untuk akun yang sedang masuk; [clear] dipanggil saat
/// keluar atau berganti akun.
class ContactCompletionController extends ChangeNotifier {
  ContactCompletionController({
    required this.store,
    CachedContactStore? cacheStore,
    CustomerProfileService? profileService,
    DateTime Function()? now,
  }) : _cacheStore = cacheStore ?? _cacheStoreOf(store),
       _profileService = profileService ?? CustomerProfileService(),
       _now = now ?? (() => DateTime.now().toUtc());

  final ContactCompletionStore store;
  final CachedContactStore? _cacheStore;
  final CustomerProfileService _profileService;
  final DateTime Function() _now;

  static const Duration emailReminderInterval = Duration(days: 7);
  static const Duration restoreTimeout = Duration(seconds: 6);

  bool _phoneRequired = false;
  bool _emailReminder = false;
  bool _submitting = false;
  String? _phoneError;
  String? _emailError;
  String? _message;
  int? _accountId;
  String? _accessToken;

  /// Perlindungan respons async: ganti akun atau keluar membatalkan pekerjaan
  /// yang masih tertunda, termasuk saat ID akun kebetulan sama.
  int _generation = 0;

  bool get shouldShowPhoneGate => _phoneRequired;

  bool get shouldShowEmailReminder => _emailReminder;

  bool get isSubmitting => _submitting;

  String? get phoneError => _phoneError;

  String? get emailError => _emailError;

  String? get message => _message;

  /// Dipanggil LoginPage/RegisterPage setelah sesi dibuat.
  Future<void> start({
    required User user,
    required ContactCompletionMethod method,
    required String accessToken,
  }) async {
    final generation = ++_generation;
    _resetState();
    _accountId = user.id;
    _accessToken = accessToken;
    await store.saveLoginMethod(user.id, method.name);
    await _cacheStore?.saveLastAccountId(user.id);
    await _persistContact(
      phone: user.phone,
      email: user.email,
      provider: user.authProvider,
      generation: generation,
    );
    if (_generation != generation) return;

    if (method == ContactCompletionMethod.google &&
        !_hasValidPhone(user.phone)) {
      _phoneRequired = true;
    } else if (method == ContactCompletionMethod.phone &&
        _needsEmail(user.email)) {
      final skipped = await store.readEmailReminderSkippedAt(user.id);
      if (_generation != generation) return;
      _emailReminder = !_isReminderBlocked(skipped);
    }
    notifyListeners();
  }

  /// Memulihkan popup saat aplikasi dibuka ulang dengan sesi yang masih valid.
  /// Server adalah sumber utama; cache per akun dipakai bila profil gagal diambil.
  /// Bila tidak ada metadata sama sekali, popup tidak dibuka (tidak menebak).
  Future<void> restore({
    required String accessToken,
    UserProfileModel? profile,
    Duration timeout = restoreTimeout,
  }) async {
    final generation = ++_generation;
    _resetState();

    final cache = _cacheStore;
    int? accountId;
    try {
      accountId = await cache?.readLastAccountId();
    } catch (_) {
      accountId = null;
    }
    if (accountId == null) {
      if (_generation == generation) notifyListeners();
      return;
    }

    _accountId = accountId;
    _accessToken = accessToken;

    UserProfileModel? remote = profile;
    if (remote == null || remote.id.isEmpty) {
      try {
        remote = await _profileService.fetchProfile(accessToken).timeout(timeout);
      } catch (_) {
        remote = null;
      }
    }

    CachedContact? cached;
    try {
      cached = await cache?.readCachedContact(accountId);
    } catch (_) {
      cached = null;
    }
    if (_generation != generation) return;
    if (remote == null && cached == null) {
      notifyListeners();
      return;
    }

    String? storedMethod;
    try {
      storedMethod = await store.readLoginMethod(accountId);
    } catch (_) {
      storedMethod = null;
    }
    if (_generation != generation) return;

    String? provider = cached?.authProvider;
    if (storedMethod == null && provider == null) {
      // API lama tidak punya authProvider; null berarti tidak menebak.
      try {
        provider = await _profileService
            .fetchAuthProvider(accessToken)
            .timeout(timeout);
      } catch (_) {
        provider = null;
      }
      if (_generation != generation) return;
    }

    final method = _resolveMethod(storedMethod, _normalizeProvider(provider));
    if (method == null) {
      notifyListeners();
      return;
    }

    final phone = _contactPhone(remote, cached);
    final email = _contactEmail(remote, cached);
    if (method == ContactCompletionMethod.google && !_hasValidPhone(phone)) {
      _phoneRequired = true;
    } else if (method == ContactCompletionMethod.phone &&
        _needsEmail(email)) {
      final skipped = await store.readEmailReminderSkippedAt(accountId);
      if (_generation != generation) return;
      _emailReminder = !_isReminderBlocked(skipped);
    }

    await _persistContact(
      phone: phone,
      email: email,
      provider: provider,
      generation: generation,
    );
    if (_generation != generation) return;
    notifyListeners();
  }

  Future<void> submitPhone(String value) async {
    final error = AuthValidators.phone(value);
    if (error != null) {
      _phoneError = error;
      notifyListeners();
      return;
    }

    final generation = _generation;
    final account = _accountId;
    final token = _accessToken;
    if (account == null || token == null) {
      _phoneRequired = false;
      notifyListeners();
      return;
    }

    _submitting = true;
    _phoneError = null;
    _message = null;
    notifyListeners();

    try {
      await _profileService.updateProfile(token, phoneNumber: value.trim());
      if (_generation != generation) return;
      await _persistContact(phone: value.trim(), generation: generation);
      _submitting = false;
      _phoneRequired = false;
      notifyListeners();
    } on ApiException catch (e) {
      if (_generation != generation) return;
      _submitting = false;
      _message = e.statusCode == 409
          ? 'Nomor telepon sudah terdaftar. Gunakan nomor lain.'
          : e.message;
      notifyListeners();
    } catch (_) {
      if (_generation != generation) return;
      _submitting = false;
      _message = 'Gagal terhubung ke server. Pastikan server aktif.';
      notifyListeners();
    }
  }

  Future<void> submitEmail(String value) async {
    final email = value.trim();
    if (email.isEmpty) {
      _emailError = 'Email wajib diisi.';
      notifyListeners();
      return;
    }
    final error = AuthValidators.optionalEmail(email);
    if (error != null) {
      _emailError = error;
      notifyListeners();
      return;
    }

    final generation = _generation;
    final account = _accountId;
    final token = _accessToken;
    if (account == null || token == null) {
      _emailReminder = false;
      notifyListeners();
      return;
    }

    _submitting = true;
    _emailError = null;
    _message = null;
    notifyListeners();

    try {
      await _profileService.updateProfile(token, email: email);
      if (_generation != generation) return;
      await _persistContact(email: email, generation: generation);
      _submitting = false;
      _emailReminder = false;
      notifyListeners();
    } on ApiException catch (e) {
      if (_generation != generation) return;
      _submitting = false;
      _message = e.message;
      notifyListeners();
    } catch (_) {
      if (_generation != generation) return;
      _submitting = false;
      _message = 'Gagal terhubung ke server. Pastikan server aktif.';
      notifyListeners();
    }
  }

  Future<void> skipEmail() async {
    final generation = _generation;
    final account = _accountId;
    if (account != null) {
      await store.saveEmailReminderSkippedAt(account, _now());
    }
    if (_generation != generation) return;
    _emailReminder = false;
    notifyListeners();
  }

  /// Dipanggil keluar/berganti akun; response async yang terlambat tidak
  /// boleh mengubah gate akun baru.
  void clear() {
    _resetState();
    _generation++;
    notifyListeners();
  }

  void _resetState() {
    _phoneRequired = false;
    _emailReminder = false;
    _submitting = false;
    _phoneError = null;
    _emailError = null;
    _message = null;
    _accountId = null;
    _accessToken = null;
  }

  Future<void> _persistContact({
    String? phone,
    String? email,
    String? provider,
    required int generation,
  }) async {
    final cache = _cacheStore;
    final account = _accountId;
    if (cache == null || account == null || _generation != generation) return;
    CachedContact? existing;
    try {
      existing = await cache.readCachedContact(account);
    } catch (_) {
      existing = null;
    }
    if (_generation != generation) return;
    await cache.saveCachedContact(
      CachedContact(
        accountId: account,
        phone: phone ?? existing?.phone,
        email: email ?? existing?.email,
        authProvider: provider ?? existing?.authProvider,
      ),
    );
  }

  String? _contactPhone(UserProfileModel? remote, CachedContact? cached) {
    final value = remote?.phoneNumber ?? '';
    return value.isNotEmpty ? value : cached?.phone;
  }

  String? _contactEmail(UserProfileModel? remote, CachedContact? cached) {
    final value = remote?.email ?? '';
    return value.isNotEmpty ? value : cached?.email;
  }

  ContactCompletionMethod? _resolveMethod(String? stored, String? provider) {
    final value = stored?.trim().toLowerCase();
    if (value == 'google') return ContactCompletionMethod.google;
    if (value == 'phone' || value == 'local' || value == 'password') {
      return ContactCompletionMethod.phone;
    }
    if (provider == 'google') return ContactCompletionMethod.google;
    if (provider == 'phone') return ContactCompletionMethod.phone;
    return null;
  }

  String? _normalizeProvider(String? raw) {
    final value = raw?.trim().toLowerCase();
    if (value == null || value.isEmpty) return null;
    if (value == 'google') return 'google';
    if (value == 'local' || value == 'phone' || value == 'password') {
      return 'phone';
    }
    return null;
  }

  bool _hasValidPhone(String? phone) {
    final value = phone?.trim() ?? '';
    return value.isNotEmpty && AuthValidators.phone(value) == null;
  }

  bool _needsEmail(String? email) {
    final value = email?.trim().toLowerCase() ?? '';
    return value.isEmpty || value.endsWith('@cleango.customer.local');
  }

  bool _isReminderBlocked(int? skippedMs) {
    if (skippedMs == null) return false;
    final skipped = DateTime.fromMillisecondsSinceEpoch(skippedMs, isUtc: true);
    return _now().difference(skipped) < emailReminderInterval;
  }
}
