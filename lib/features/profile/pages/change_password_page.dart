import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../controllers/change_password_controller.dart';
import '../controllers/profile_controller.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  late final ChangePasswordController _passwordController;
  final TextEditingController _currentPassTextController =
      TextEditingController();
  final TextEditingController _newPassTextController = TextEditingController();
  final TextEditingController _confirmPassTextController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _passwordController = ChangePasswordController();
  }

  @override
  void dispose() {
    _currentPassTextController.dispose();
    _newPassTextController.dispose();
    _confirmPassTextController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    FocusScope.of(context).unfocus();
    final profileController = context.read<ProfileController>();
    final activePassword = profileController.password;

    final isValid = _passwordController.validate(activePassword);
    if (!isValid) {
      return;
    }

    final success = profileController.changePassword(
      currentPassword: _passwordController.currentPassword.trim(),
      newPassword: _passwordController.newPassword.trim(),
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 10),
              Text(
                'Kata sandi berhasil diperbarui!',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: AppTheme.fontFamily,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  void _showForgotPasswordModal() {
    final profile = context.read<ProfileController>().profile;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            16,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Icon(
                Icons.lock_reset_rounded,
                size: 48,
                color: Color(0xFF00685F),
              ),
              const SizedBox(height: 12),
              const Text(
                'Lupa Kata Sandi?',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Kode verifikasi pemulihan sandi dapat dikirimkan ke nomor terverifikasi ${profile.phoneNumber} atau email ${profile.email}.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Tautan pemulihan dikirim ke email Anda.',
                        ),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00685F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Kirim Tautan Pemulihan',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showResetConfirmation() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Reset Form?',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontFamily: AppTheme.fontFamily,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'Apakah Anda ingin mengosongkan seluruh isian kata sandi di layar ini?',
            style: TextStyle(
              color: Color(0xFF475569),
              fontFamily: AppTheme.fontFamily,
              fontSize: 13.5,
              height: 1.45,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                _currentPassTextController.clear();
                _newPassTextController.clear();
                _confirmPassTextController.clear();
                _passwordController.reset();
                Navigator.pop(context);
              },
              child: const Text(
                'Kosongkan',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _passwordController,
      builder: (context, _) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            systemNavigationBarColor: Colors.white,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
          child: Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            body: SafeArea(
              child: Column(
                children: [
                  // App Bar
                  _buildHeader(context),
                  // Content
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      children: [
                        // Info Banner
                        _buildInfoBanner(),
                        const SizedBox(height: 20),
                        // Field 1: Kata Sandi Saat Ini
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildLabel('Kata Sandi Saat Ini'),
                            GestureDetector(
                              onTap: _showForgotPasswordModal,
                              child: const Text(
                                'Lupa Sandi?',
                                style: TextStyle(
                                  color: Color(0xFF00685F),
                                  fontFamily: AppTheme.fontFamily,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildPasswordField(
                          controller: _currentPassTextController,
                          hint: 'Masukkan password saat ini',
                          prefixIcon: Icons.lock_outline_rounded,
                          isVisible:
                              _passwordController.isCurrentPasswordVisible,
                          onToggleVisibility: _passwordController
                              .toggleCurrentPasswordVisibility,
                          onChanged: _passwordController.setCurrentPassword,
                          errorText: _passwordController.currentPasswordError,
                        ),
                        const SizedBox(height: 18),
                        // Field 2: Kata Sandi Baru
                        _buildLabel('Kata Sandi Baru'),
                        const SizedBox(height: 8),
                        _buildPasswordField(
                          controller: _newPassTextController,
                          hint: 'Minimal 8 karakter baru',
                          prefixIcon: Icons.vpn_key_outlined,
                          isVisible: _passwordController.isNewPasswordVisible,
                          onToggleVisibility:
                              _passwordController.toggleNewPasswordVisibility,
                          onChanged: _passwordController.setNewPassword,
                          errorText: _passwordController.newPasswordError,
                        ),
                        const SizedBox(height: 10),
                        // Strength Indicator
                        _buildStrengthIndicator(),
                        const SizedBox(height: 18),
                        // Field 3: Konfirmasi Kata Sandi Baru
                        _buildLabel('Konfirmasi Kata Sandi Baru'),
                        const SizedBox(height: 8),
                        _buildPasswordField(
                          controller: _confirmPassTextController,
                          hint: 'Ulangi kata sandi baru',
                          prefixIcon: Icons.shield_outlined,
                          isVisible:
                              _passwordController.isConfirmPasswordVisible,
                          onToggleVisibility: _passwordController
                              .toggleConfirmPasswordVisibility,
                          onChanged: _passwordController.setConfirmPassword,
                          errorText: _passwordController.confirmPasswordError,
                        ),
                        const SizedBox(height: 20),
                        // Ketentuan Kata Sandi Card
                        _buildCriteriaCard(),
                      ],
                    ),
                  ),
                  // Bottom Sticky Button & Security Label
                  _buildBottomActionBar(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Color(0xFF1E293B),
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
            ),
          ),
          const Text(
            'Ubah Kata Sandi',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontFamily: AppTheme.fontFamily,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          GestureDetector(
            onTap: _showResetConfirmation,
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFFE6FAF7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_reset_rounded,
                color: Color(0xFF00685F),
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDFA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFCCFBF1), width: 1.2),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              Icons.info_outline_rounded,
              color: Color(0xFF0D9488),
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keamanan Akun Anda',
                  style: TextStyle(
                    color: Color(0xFF00685F),
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Gunakan minimal 8 karakter dengan kombinasi huruf besar, huruf kecil, dan angka untuk menjaga keamanan akun Anda.',
                  style: TextStyle(
                    color: Color(0xFF475569),
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12.5,
                    height: 1.45,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text.rich(
      TextSpan(
        text: text,
        style: const TextStyle(
          color: Color(0xFF1E293B),
          fontFamily: AppTheme.fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    required ValueChanged<String> onChanged,
    String? errorText,
  }) {
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasError ? Colors.red : const Color(0xFFE2E8F0),
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: !isVisible,
            onChanged: onChanged,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontFamily: AppTheme.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFF94A3B8),
                fontFamily: AppTheme.fontFamily,
                fontSize: 14,
              ),
              prefixIcon: Icon(
                prefixIcon,
                color: const Color(0xFF94A3B8),
                size: 20,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  isVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: const Color(0xFF94A3B8),
                  size: 20,
                ),
                onPressed: onToggleVisibility,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 14,
                  height: 14,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(top: 1),
                  decoration: const BoxDecoration(
                    color: AppColors.notification,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    errorText,
                    style: const TextStyle(
                      color: AppColors.notification,
                      fontSize: 12,
                      fontFamily: AppTheme.fontFamily,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStrengthIndicator() {
    final count = _passwordController.criteriaMetCount;
    final label = _passwordController.strengthLabel;

    Color labelColor = const Color(0xFF64748B);
    if (count == 1) labelColor = Colors.red;
    if (count == 2) labelColor = Colors.orange;
    if (count == 3) labelColor = const Color(0xFF00685F);
    if (count == 4) labelColor = const Color(0xFF00685F);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'Kekuatan sandi: ',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: labelColor,
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Text(
              '$count / 4 Kriteria',
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontFamily: AppTheme.fontFamily,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(4, (index) {
            final isActive = index < count;
            return Expanded(
              child: Container(
                height: 5,
                margin: EdgeInsets.only(right: index < 3 ? 6 : 0),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF00685F)
                      : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCriteriaCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ketentuan Kata Sandi:',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontFamily: AppTheme.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _buildCheckItem(
            text: 'Minimal 8 karakter',
            isSatisfied: _passwordController.hasMinLength,
          ),
          const SizedBox(height: 10),
          _buildCheckItem(
            text: 'Mengandung huruf besar (A-Z) & huruf kecil (a-z)',
            isSatisfied: _passwordController.hasUpperAndLower,
          ),
          const SizedBox(height: 10),
          _buildCheckItem(
            text: 'Mengandung minimal 1 angka (0–9)',
            isSatisfied: _passwordController.hasNumber,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem({required String text, required bool isSatisfied}) {
    return Row(
      children: [
        Icon(
          isSatisfied
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked_rounded,
          color: isSatisfied
              ? const Color(0xFF00685F)
              : const Color(0xFFCBD5E1),
          size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isSatisfied
                  ? const Color(0xFF1E293B)
                  : const Color(0xFF64748B),
              fontFamily: AppTheme.fontFamily,
              fontSize: 13,
              fontWeight: isSatisfied ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9), width: 1.5)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00685F),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Simpan Kata Sandi',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 13,
                color: Color(0xFF94A3B8),
              ),
              SizedBox(width: 6),
              Text(
                'Terenkripsi aman dengan standar keamanan CleanGo',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
