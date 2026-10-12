abstract final class ProfileFormValidator {
  static String? fullName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) {
      return 'Nama lengkap wajib diisi.';
    }
    if (name.length < 3 ||
        !RegExp(r"^[a-zA-ZÀ-ÖØ-öø-ÿ.' -]+$").hasMatch(name) ||
        !RegExp(r'[a-zA-ZÀ-ÖØ-öø-ÿ]').hasMatch(name)) {
      return 'Masukkan nama lengkap yang valid.';
    }
    return null;
  }

  static String? phone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) return 'Nomor telepon wajib diisi.';
    if (!RegExp(r'^\d+$').hasMatch(phone)) {
      return 'Masukkan nomor telepon yang valid.';
    }
    final digits = phone;
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
