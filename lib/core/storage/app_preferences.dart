import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

abstract interface class ContactCompletionStore {
  Future<int?> readEmailReminderSkippedAt(int accountId);

  Future<void> saveEmailReminderSkippedAt(int accountId, DateTime skippedAt);

  Future<String?> readLoginMethod(int accountId);

  Future<void> saveLoginMethod(int accountId, String method);
}

/// Kontak terakhir yang berhasil disimpan per akun. Dipakai memulihkan popup
/// setelah aplikasi dibuka ulang tanpa menebak data server yang tidak tersedia.
class CachedContact {
  const CachedContact({
    required this.accountId,
    this.phone,
    this.email,
    this.authProvider,
  });

  final int accountId;
  final String? phone;
  final String? email;
  final String? authProvider;

  Map<String, dynamic> toJson() => {
    'accountId': accountId,
    'phone': phone,
    'email': email,
    'authProvider': authProvider,
  };

  factory CachedContact.fromJson(Map<String, dynamic> json) => CachedContact(
    accountId: json['accountId'] as int? ?? 0,
    phone: json['phone'] as String?,
    email: json['email'] as String?,
    authProvider: json['authProvider'] as String?,
  );
}

abstract interface class CachedContactStore {
  Future<CachedContact?> readCachedContact(int accountId);

  Future<void> saveCachedContact(CachedContact contact);

  Future<int?> readLastAccountId();

  Future<void> saveLastAccountId(int accountId);
}

class AppPreferences
    implements ContactCompletionStore, CachedContactStore {
  AppPreferences(this._preferences);

  static const _onboardingCompletedKey = 'onboarding_completed';
  static const _lastServiceFilterKey = 'last_service_filter';
  static const _emailReminderSkippedPrefix = 'email_reminder_skipped_';
  static const _loginMethodPrefix = 'login_method_';
  static const _cachedContactPrefix = 'cached_contact_';
  static const _lastAccountIdKey = 'last_account_id';

  final SharedPreferencesAsync _preferences;

  Future<bool> hasCompletedOnboarding() async =>
      await _preferences.getBool(_onboardingCompletedKey) ?? false;

  Future<void> completeOnboarding() {
    return _preferences.setBool(_onboardingCompletedKey, true);
  }

  Future<String?> readLastServiceFilter() {
    return _preferences.getString(_lastServiceFilterKey);
  }

  Future<void> saveLastServiceFilter(String filter) {
    return _preferences.setString(_lastServiceFilterKey, filter);
  }

  Future<void> removeLastServiceFilter() {
    return _preferences.remove(_lastServiceFilterKey);
  }

  /// Kunci per ID akun, bukan kontak/token, agar akun A dan B tidak campur.
  @override
  Future<int?> readEmailReminderSkippedAt(int accountId) {
    return _preferences.getInt('$_emailReminderSkippedPrefix$accountId');
  }

  @override
  Future<void> saveEmailReminderSkippedAt(int accountId, DateTime skippedAt) {
    return _preferences.setInt(
      '$_emailReminderSkippedPrefix$accountId',
      skippedAt.toUtc().millisecondsSinceEpoch,
    );
  }

  @override
  Future<String?> readLoginMethod(int accountId) {
    return _preferences.getString('$_loginMethodPrefix$accountId');
  }

  @override
  Future<void> saveLoginMethod(int accountId, String method) {
    return _preferences.setString('$_loginMethodPrefix$accountId', method);
  }

  @override
  Future<CachedContact?> readCachedContact(int accountId) async {
    final raw = await _preferences.getString('$_cachedContactPrefix$accountId');
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return CachedContact.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveCachedContact(CachedContact contact) {
    return _preferences.setString(
      '$_cachedContactPrefix${contact.accountId}',
      jsonEncode(contact.toJson()),
    );
  }

  @override
  Future<int?> readLastAccountId() {
    return _preferences.getInt(_lastAccountIdKey);
  }

  @override
  Future<void> saveLastAccountId(int accountId) {
    return _preferences.setInt(_lastAccountIdKey, accountId);
  }
}
