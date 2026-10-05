import 'package:flutter/foundation.dart';

class ChangePasswordController extends ChangeNotifier {
  String _currentPassword = '';
  String _newPassword = '';
  String _confirmPassword = '';

  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  String? _currentPasswordError;
  String? _newPasswordError;
  String? _confirmPasswordError;
  int _failedCurrentPasswordAttempts = 0;

  String get currentPassword => _currentPassword;
  String get newPassword => _newPassword;
  String get confirmPassword => _confirmPassword;

  bool get isCurrentPasswordVisible => _isCurrentPasswordVisible;
  bool get isNewPasswordVisible => _isNewPasswordVisible;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;

  String? get currentPasswordError => _currentPasswordError;
  String? get newPasswordError => _newPasswordError;
  String? get confirmPasswordError => _confirmPasswordError;
  int get failedCurrentPasswordAttempts => _failedCurrentPasswordAttempts;

  // Criteria rules
  bool get hasMinLength => _newPassword.length >= 8;
  bool get hasUppercase => RegExp(r'[A-Z]').hasMatch(_newPassword);
  bool get hasLowercase => RegExp(r'[a-z]').hasMatch(_newPassword);
  bool get hasUpperAndLower => hasUppercase && hasLowercase;
  bool get hasNumber => RegExp(r'[0-9]').hasMatch(_newPassword);

  int get criteriaMetCount {
    if (_newPassword.isEmpty) return 0;
    int count = 0;
    if (hasMinLength) count++;
    if (hasLowercase) count++;
    if (hasUppercase) count++;
    if (hasNumber) count++;
    return count;
  }

  String get strengthLabel {
    final count = criteriaMetCount;
    if (_newPassword.isEmpty) return 'Belum Diisi';
    switch (count) {
      case 1:
        return 'Lemah';
      case 2:
        return 'Sedang';
      case 3:
        return 'Cukup Kuat';
      case 4:
        return 'Sangat Kuat';
      default:
        return 'Belum Diisi';
    }
  }

  void setCurrentPassword(String val) {
    _currentPassword = val;
    if (_currentPasswordError != null) {
      _currentPasswordError = null;
      notifyListeners();
    }
  }

  void setNewPassword(String val) {
    _newPassword = val;
    if (_newPasswordError != null) {
      _newPasswordError = null;
    }
    notifyListeners();
  }

  void setConfirmPassword(String val) {
    _confirmPassword = val;
    if (_confirmPasswordError != null) {
      _confirmPasswordError = null;
      notifyListeners();
    }
  }

  void toggleCurrentPasswordVisibility() {
    _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
    notifyListeners();
  }

  void toggleNewPasswordVisibility() {
    _isNewPasswordVisible = !_isNewPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    notifyListeners();
  }

  bool validate(String activePassword) {
    bool isValid = true;
    _currentPasswordError = null;
    _newPasswordError = null;
    _confirmPasswordError = null;

    final trimmedCurrent = _currentPassword.trim();
    if (trimmedCurrent.isEmpty) {
      _currentPasswordError = 'Kata sandi saat ini wajib diisi.';
      isValid = false;
    } else if (trimmedCurrent != activePassword) {
      _failedCurrentPasswordAttempts++;
      _currentPasswordError = _failedCurrentPasswordAttempts >= 3
          ? 'Kata sandi tidak sesuai. Coba lagi atau klik "Lupa Kata Sandi" untuk mengatur ulang.'
          : 'Kata sandi saat ini tidak sesuai.';
      isValid = false;
    } else {
      _failedCurrentPasswordAttempts = 0;
    }

    if (_newPassword.isEmpty) {
      _newPasswordError = 'Kata sandi baru wajib diisi.';
      isValid = false;
    } else if (!hasMinLength || !hasUpperAndLower || !hasNumber) {
      _newPasswordError = 'Kata sandi baru belum memenuhi semua kriteria.';
      isValid = false;
    } else if (_newPassword == trimmedCurrent) {
      _newPasswordError =
          'Kata sandi baru tidak boleh sama dengan kata sandi saat ini.';
      isValid = false;
    }

    if (_confirmPassword.isEmpty) {
      _confirmPasswordError = 'Konfirmasi kata sandi wajib diisi.';
      isValid = false;
    } else if (_confirmPassword != _newPassword) {
      _confirmPasswordError = 'Konfirmasi kata sandi tidak cocok.';
      isValid = false;
    }

    notifyListeners();
    return isValid;
  }

  void reset() {
    _currentPassword = '';
    _newPassword = '';
    _confirmPassword = '';
    _isCurrentPasswordVisible = false;
    _isNewPasswordVisible = false;
    _isConfirmPasswordVisible = false;
    _currentPasswordError = null;
    _newPasswordError = null;
    _confirmPasswordError = null;
    _failedCurrentPasswordAttempts = 0;
    notifyListeners();
  }
}
