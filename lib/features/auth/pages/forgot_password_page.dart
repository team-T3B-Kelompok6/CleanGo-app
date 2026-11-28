import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_notice.dart';
import '../data/api_auth_service.dart';
import 'reset_password_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key, this.authService});

  final ApiAuthService? authService;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _identifier = TextEditingController();
  late final ApiAuthService _authService = widget.authService ?? ApiAuthService();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _identifier.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final identifier = _identifier.text.trim();
    if (identifier.isEmpty) {
      setState(() => _error = 'Isi nomor telepon atau email akun Anda.');
      return;
    }
    final channel = identifier.contains('@') ? 'email' : 'whatsapp';
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _authService.forgotPassword(
        identifier: identifier,
        channel: channel,
      );
      if (!mounted) return;
      if (channel == 'email') {
        AppNotice.show(
          context,
          'Tautan pemulihan telah dikirim ke email. Silakan periksa kotak masuk Anda.',
          type: AppNoticeType.success,
        );
        Navigator.of(context).pop();
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ResetPasswordPage(
            identifier: identifier,
            channel: channel,
          ),
        ),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(),
        title: const Text('Lupa Kata Sandi'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                const Text(
                  'Masukkan nomor telepon atau email akun Anda. Nomor telepon menerima kode OTP; email menerima tautan pemulihan.',
                  style: TextStyle(
                    color: AppColors.slate500,
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _identifier,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onChanged: (_) => setState(() {}),
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: 'Nomor telepon atau email',
                    hintText: 'Contoh: 0812xxxxxxx atau nama@email.com',
                    errorText: _error,
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
                    _loading
                        ? 'Mengirim…'
                        : (_identifier.text.contains('@')
                            ? 'Kirim Tautan Pemulihan'
                            : 'Kirim Kode OTP'),
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
