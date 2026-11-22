import 'package:flutter_test/flutter_test.dart';
import 'package:cleango_app/features/profile/controllers/change_password_controller.dart';
import 'package:cleango_app/features/profile/controllers/profile_controller.dart';

void main() {
  group('ChangePasswordController Tests', () {
    late ChangePasswordController controller;

    setUp(() {
      controller = ChangePasswordController();
    });

    test('Initial state is empty and unrevealed', () {
      expect(controller.currentPassword, '');
      expect(controller.newPassword, '');
      expect(controller.confirmPassword, '');
      expect(controller.isCurrentPasswordVisible, false);
      expect(controller.isNewPasswordVisible, false);
      expect(controller.isConfirmPasswordVisible, false);
      expect(controller.criteriaMetCount, 0);
      expect(controller.strengthLabel, 'Belum Diisi');
    });

    test(
      'Strength evaluation correctly evaluates 3 of 4 criteria as Cukup Kuat',
      () {
        // CleanGooo has >= 8 chars, uppercase, lowercase, but no number -> 3/4
        controller.setNewPassword('CleanGooo');

        expect(controller.hasMinLength, true);
        expect(controller.hasUpperAndLower, true);
        expect(controller.hasNumber, false);
        expect(controller.criteriaMetCount, 3);
        expect(controller.strengthLabel, 'Cukup Kuat');
      },
    );

    test(
      'Strength evaluation correctly evaluates 4 of 4 criteria as Sangat Kuat',
      () {
        // CleanGo123 has >= 8 chars, uppercase, lowercase, and numbers -> 4/4
        controller.setNewPassword('CleanGo123');

        expect(controller.hasMinLength, true);
        expect(controller.hasUpperAndLower, true);
        expect(controller.hasNumber, true);
        expect(controller.criteriaMetCount, 4);
        expect(controller.strengthLabel, 'Sangat Kuat');
      },
    );

    test('Validation fails if current password is wrong', () {
      controller.setCurrentPassword('wrongpass');
      controller.setNewPassword('CleanGo123');
      controller.setConfirmPassword('CleanGo123');

      final isValid = controller.validate('321321');
      expect(isValid, false);
      expect(
        controller.currentPasswordError,
        'Kata sandi saat ini tidak sesuai.',
      );
    });

    test('Validation compares the current password exactly', () {
      controller.setCurrentPassword(' 321321 ');
      controller.setNewPassword('CleanGo123');
      controller.setConfirmPassword('CleanGo123');

      expect(controller.validate('321321'), isFalse);
      expect(
        controller.currentPasswordError,
        'Kata sandi saat ini tidak sesuai.',
      );
    });

    test('Third wrong current password attempt shows recovery guidance', () {
      controller.setCurrentPassword('wrongpass');
      controller.setNewPassword('CleanGo123');
      controller.setConfirmPassword('CleanGo123');

      controller.validate('321321');
      controller.validate('321321');
      controller.validate('321321');

      expect(controller.failedCurrentPasswordAttempts, 3);
      expect(
        controller.currentPasswordError,
        'Kata sandi tidak sesuai. Coba lagi atau klik "Lupa Kata Sandi" untuk mengatur ulang.',
      );
    });

    test('Validation fails if new password does not satisfy criteria', () {
      controller.setCurrentPassword('321321');
      controller.setNewPassword('pendek'); // < 8 chars, no upper, no number
      controller.setConfirmPassword('pendek');

      final isValid = controller.validate('321321');
      expect(isValid, false);
      expect(
        controller.newPasswordError,
        'Kata sandi baru belum memenuhi semua kriteria.',
      );
    });

    test('Validation fails if confirm password does not match', () {
      controller.setCurrentPassword('321321');
      controller.setNewPassword('CleanGo123');
      controller.setConfirmPassword('CleanGo999');

      final isValid = controller.validate('321321');
      expect(isValid, false);
      expect(
        controller.confirmPasswordError,
        'Konfirmasi kata sandi tidak cocok.',
      );
    });

    test('Validation passes with valid current password and matching valid new password', () {
      controller.setCurrentPassword('321321');
      controller.setNewPassword('CleanGo123');
      controller.setConfirmPassword('CleanGo123');

      final isValid = controller.validate('321321');
      expect(isValid, true);
      expect(controller.currentPasswordError, isNull);
      expect(controller.newPasswordError, isNull);
      expect(controller.confirmPasswordError, isNull);
    });

    test('valid form cannot change a password without an authenticated API session', () async {
      final profileController = ProfileController();
      addTearDown(profileController.dispose);
      controller.setCurrentPassword('ExistingPassword123');
      controller.setNewPassword('CleanGo123');
      controller.setConfirmPassword('CleanGo123');

      expect(controller.validate(null), isTrue);
      final success = await profileController.changePasswordRemote(
        currentPassword: controller.currentPassword,
        newPassword: controller.newPassword,
      );

      expect(success, isFalse);
      expect(
        profileController.error,
        'Sesi tidak ditemukan. Silakan masuk kembali.',
      );
    });

    test('remote form validation requires all fields', () {
      expect(controller.validate(null), isFalse);
      expect(
        controller.currentPasswordError,
        'Kata sandi saat ini wajib diisi.',
      );
      expect(controller.newPasswordError, 'Kata sandi baru wajib diisi.');
      expect(
        controller.confirmPasswordError,
        'Konfirmasi kata sandi wajib diisi.',
      );
    });

    test('remote form rejects unchanged and overlong new passwords', () {
      controller.setCurrentPassword('ExistingPassword123');
      controller.setNewPassword('ExistingPassword123');
      controller.setConfirmPassword('ExistingPassword123');
      expect(controller.validate(null), isFalse);
      expect(
        controller.newPasswordError,
        'Kata sandi baru tidak boleh sama dengan kata sandi saat ini.',
      );
      controller.setNewPassword('Aa1${'a' * 30}');
      controller.setConfirmPassword(controller.newPassword);
      expect(controller.validate(null), isFalse);
      expect(
        controller.newPasswordError,
        'Kata sandi baru belum memenuhi semua kriteria.',
      );
    });

    test(
      'server rejection remains visible until current password is edited',
      () {
        controller.setCurrentPasswordError('Kata sandi saat ini tidak sesuai.');
        expect(
          controller.currentPasswordError,
          'Kata sandi saat ini tidak sesuai.',
        );
        controller.setCurrentPassword('CorrectedPassword123');
        expect(controller.currentPasswordError, isNull);
      },
    );

    test('toggleVisibility switches visibility booleans', () {
      controller.toggleCurrentPasswordVisibility();
      expect(controller.isCurrentPasswordVisible, true);

      controller.toggleNewPasswordVisibility();
      expect(controller.isNewPasswordVisible, true);

      controller.toggleConfirmPasswordVisibility();
      expect(controller.isConfirmPasswordVisible, true);
    });
  });
}
