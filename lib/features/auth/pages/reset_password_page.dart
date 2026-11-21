import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_notice.dart';
import '../data/api_auth_service.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({
    required this.identifier,
    required this.channel,
    super.key,
  });

  final String identifier;
  final String channel;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _otp = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final ApiAuthService _authService = ApiAuthService();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _otp.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final otp = _otp.text.trim();
    final password = _password.text;
    final confirm = _confirm.text;
    if (otp.length != 6 || !RegExp(r'^\d{6}$').hasMatch(otp)) {
      setState(() => _error = 'Kode OTP harus 6 digit angka.');
      return;
    }
    if (password.length < 8) {
      setState(() => _error = 'Kata sandi baru minimal 8 karakter.');
      return;
    }
    if (password != confirm) {
      setState(() => _error = 'Konfirmasi kata sandi tidak sama.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _authService.resetPassword(
        identifier: widget.identifier,
        otp: otp,
        newPassword: password,
      );
      if (!mounted) return;
      AppNotice.show(context, 'Kata sandi berhasil diubah. Silakan masuk.');
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
      AppNotice.show(context, error.message, type: AppNoticeType.error);
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _error = 'Gagal terhubung ke server. Pastikan server aktif.',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final channelLabel = widget.channel == 'email' ? 'email' : 'WhatsApp';
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(),
        title: const Text('Ubah Kata Sandi'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Kode OTP dikirim melalui $channelLabel. Kode berlaku 10 menit dan hanya digunakan sekali.',
                style: const TextStyle(
                  color: AppColors.slate500,
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _otp,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: 'Kode OTP',
                  hintText: '6 digit angka',
                  errorText: _error,
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _password,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Kata sandi baru',
                  hintText: 'Minimal 8 karakter',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirm,
                obscureText: _obscure,
                onFieldSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: 'Konfirmasi kata sandi',
                  hintText: 'Ulangi kata sandi baru',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _loading ? null : _submit,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: AppColors.primaryAction,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _loading ? 'Menyimpan…' : 'Ubah Kata Sandi',
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
