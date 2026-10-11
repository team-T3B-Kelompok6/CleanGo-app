abstract final class AddressFormValidator {
  static String? address(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Alamat wajib diisi.';
    if (text.length < 5) return 'Masukkan alamat yang lebih jelas.';
    return null;
  }

  static String? fullAddress(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Alamat lengkap wajib diisi.';
    if (text.length < 10) {
      return 'Lengkapi nama jalan, nomor, kecamatan, dan kota.';
    }
    return null;
  }

  static String? contactName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Nama kontak wajib diisi.';
    if (text.length < 2 || !RegExp(r"^[a-zA-ZÀ-ÿ.' -]+$").hasMatch(text)) {
      return 'Masukkan nama kontak yang valid.';
    }
    return null;
  }

  static String? phone(String? value) {
    final digits = normalizePhone(value ?? '');
    if (digits.isEmpty) return 'Nomor telepon wajib diisi.';
    if (!RegExp(r'^8[0-9]{8,12}$').hasMatch(digits)) {
      return 'Masukkan nomor telepon yang valid setelah +62.';
    }
    return null;
  }

  static String normalizePhone(String value) {
    var digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('62')) digits = digits.substring(2);
    if (digits.startsWith('0')) digits = digits.substring(1);
    return digits;
  }

  static String formatPhone(String value) {
    return '(+62) ${normalizePhone(value)}';
  }
}
