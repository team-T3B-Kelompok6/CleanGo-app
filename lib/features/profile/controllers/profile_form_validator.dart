abstract final class ProfileFormValidator {
  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama lengkap wajib diisi.';
    }
    if (value.trim().length < 3) {
      return 'Masukkan nama lengkap yang valid.';
    }
    return null;
  }

  static String? phone(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return 'Nomor telepon wajib diisi.';
    final local = digits.startsWith('62')
        ? digits.substring(2)
        : digits.startsWith('0')
        ? digits.substring(1)
        : digits;
    if (!RegExp(r'^8[0-9]{8,12}$').hasMatch(local)) {
      return 'Masukkan nomor telepon yang valid.';
    }
    return null;
  }

  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Alamat email wajib diisi.';
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      return 'Masukkan alamat email yang valid.';
    }
    return null;
  }
}
