abstract final class AuthValidators {
  static final RegExp _indonesianPhonePattern = RegExp(
    r'^(?:(?:\+62|62|0)?8)[1-9][0-9]{7,11}$',
  );

  static String? phone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) {
      return 'Nomor telepon wajib diisi.';
    }
    if (!_indonesianPhonePattern.hasMatch(phone)) {
      return 'Masukkan nomor telepon yang valid.';
    }
    return null;
  }

  static String? requiredPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kata sandi wajib diisi.';
    }
    return null;
  }

  static String? registerPassword(String? value) {
    final requiredError = requiredPassword(value);
    if (requiredError != null) {
      return requiredError;
    }
    if (value!.length < 8) {
      return 'Password minimal 8 karakter.';
    }
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama wajib diisi.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password wajib diisi.';
    }
    if (value != password) {
      return 'Konfirmasi password belum sama.';
    }
    return null;
  }
}

class LoginValidationResult {
  const LoginValidationResult({
    required this.phoneError,
    required this.passwordError,
  });

  final String? phoneError;
  final String? passwordError;

  bool get isSuccess => phoneError == null && passwordError == null;
}

class DummyAuthService {
  const DummyAuthService();

  static const String validPhone = '81234567890';
  static const String validPassword = '321321';

  bool phoneMatches(String phone) => _normalizePhone(phone) == validPhone;

  bool passwordMatches(String password) => password == validPassword;

  LoginValidationResult validateLogin({
    required String phone,
    required String password,
  }) {
    final phoneValidationError = AuthValidators.phone(phone);
    final passwordValidationError = AuthValidators.requiredPassword(password);

    if (phoneValidationError != null || passwordValidationError != null) {
      return LoginValidationResult(
        phoneError: phoneValidationError,
        passwordError: passwordValidationError,
      );
    }

    return LoginValidationResult(
      phoneError: phoneMatches(phone)
          ? null
          : 'Nomor telepon tidak terdaftar.',
      passwordError: passwordMatches(password)
          ? null
          : 'Kata sandi tidak sesuai. Coba lagi atau klik "Lupa Kata Sandi" untuk mengatur ulang.',
    );
  }

  bool login({required String phone, required String password}) {
    return phoneMatches(phone) && passwordMatches(password);
  }

  String _normalizePhone(String phone) {
    var normalized = phone.replaceAll(RegExp(r'[^0-9]'), '');

    if (normalized.startsWith('62')) {
      normalized = normalized.substring(2);
    } else if (normalized.startsWith('0')) {
      normalized = normalized.substring(1);
    }

    return normalized;
  }
}
