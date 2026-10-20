import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_notice.dart';
import '../../profile/controllers/profile_controller.dart';
import '../controllers/auth_session_controller.dart';
import '../data/api_auth_service.dart';
import '../data/dummy_auth_service.dart';
import '../data/google_sign_in_service.dart';
import '../widgets/auth_social_buttons.dart';
import '../widgets/auth_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, this.authService});

  final ApiAuthService? authService;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  late final ApiAuthService _authService = widget.authService ?? ApiAuthService();
  final _googleSignInService = GoogleSignInService();

  bool _obscurePassword = true;
  bool _obscureConfirmation = true;
  bool _hasSubmitted = false;
  bool _isLoading = false;
  String? _serverError;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.screenBackground,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.screenBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(
              20,
              14,
              20,
              30 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Form(
                  key: _formKey,
                  autovalidateMode: _hasSubmitted
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          _BackButton(onTap: () => Navigator.pop(context)),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Buat Akun CleanGo',
                              style: TextStyle(
                                color: AppColors.slate900,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Lengkapi data Anda untuk mulai memesan layanan kebersihan terbaik.',
                        style: TextStyle(
                          color: AppColors.slate500,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.55,
                        ),
                      ),
                      const SizedBox(height: 28),
                      if (_serverError != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            _serverError!,
                            style: TextStyle(
                              color: Colors.red.shade800,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      AuthTextField(
                        label: 'Nama Lengkap',
                        hintText: 'Masukkan nama lengkap Anda',
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.name,
                        validator: AuthValidators.name,
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        label: 'Nomor telepon',
                        hintText: 'Masukkan nomor telepon Anda',
                        controller: _phoneController,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.phone,
                        isPhone: true,
                        validator: AuthValidators.phone,
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        label: 'Kata sandi',
                        hintText: 'Buat kata sandi minimal 8 karakter',
                        controller: _passwordController,
                        textInputAction: TextInputAction.next,
                        obscureText: _obscurePassword,
                        validator: AuthValidators.registerPassword,
                        suffixIcon: IconButton(
                          tooltip: _obscurePassword
                              ? 'Tampilkan kata sandi'
                              : 'Sembunyikan kata sandi',
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.slate400,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        label: 'Konfirmasi kata sandi',
                        hintText: 'Ulangi kata sandi Anda',
                        controller: _confirmationController,
                        textInputAction: TextInputAction.done,
                        obscureText: _obscureConfirmation,
                        validator: (value) => AuthValidators.confirmPassword(
                          value,
                          _passwordController.text,
                        ),
                        onSubmitted: (_) => _submit(),
                        suffixIcon: IconButton(
                          tooltip: _obscureConfirmation
                              ? 'Tampilkan konfirmasi kata sandi'
                              : 'Sembunyikan konfirmasi kata sandi',
                          onPressed: () => setState(
                            () => _obscureConfirmation = !_obscureConfirmation,
                          ),
                          icon: Icon(
                            _obscureConfirmation
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.slate400,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primaryAction,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox.square(
                                  dimension: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Daftar',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Sudah punya akun?',
                            style: TextStyle(
                              color: AppColors.slate500,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              minimumSize: Size.zero,
                              padding: const EdgeInsets.only(left: 5),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Masuk',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      AuthSocialButtons(
                        onGoogleTap: _handleGoogleRegister,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleGoogleRegister() async {
    setState(() {
      _isLoading = true;
      _serverError = null;
    });

    try {
      final googleUser = await _googleSignInService.signIn();
      if (googleUser == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final result = await _authService.socialLogin(
        provider: 'google',
        email: googleUser.email,
        name: googleUser.name,
        idToken: googleUser.idToken,
      );
      if (!mounted) return;
      await context.read<AuthSessionController>().createSession(result.token, expiresInSeconds: result.expiresIn);
      try {
        if (mounted) await context.read<ProfileController>().loadFromApi();
      } catch (_) {}
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } on ApiException catch (e) {
      if (mounted) setState(() => _serverError = e.message);
    } catch (e) {
      if (mounted) setState(() => _serverError = 'Gagal daftar dengan Google: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_hasSubmitted) {
      setState(() => _hasSubmitted = true);
    }
    setState(() => _serverError = null);

    if (!(_formKey.currentState?.validate() ?? false)) {
      AppNotice.show(
        context,
        'Pendaftaran belum berhasil. Periksa kembali isian Anda.',
        type: AppNoticeType.error,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _authService.register(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      await context.read<AuthSessionController>().createSession(result.token, expiresInSeconds: result.expiresIn);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _serverError = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _serverError = 'Gagal terhubung ke server.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox.square(
          dimension: 42,
          child: Center(
            child: SvgPicture.asset(
              'assets/icons/back.svg',
              width: 17,
              height: 17,
            ),
          ),
        ),
      ),
    );
  }
}
