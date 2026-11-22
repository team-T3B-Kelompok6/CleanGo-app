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
    if (value == null || value.trim().isEmpty) {
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
    if (value.length > 32) {
      return 'Password maksimal 32 karakter.';
    }
    return null;
  }

  static String? name(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) {
      return 'Nama wajib diisi.';
    }
    if (!RegExp(r"^[a-zA-ZÀ-ÖØ-öø-ÿ.' -]+$").hasMatch(name) ||
        !RegExp(r'[a-zA-ZÀ-ÖØ-öø-ÿ]').hasMatch(name)) {
      return 'Masukkan nama yang valid.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.trim().isEmpty) {
      return 'Konfirmasi password wajib diisi.';
    }
    if (value != password) {
      return 'Konfirmasi password belum sama.';
    }
    return null;
  }
}
