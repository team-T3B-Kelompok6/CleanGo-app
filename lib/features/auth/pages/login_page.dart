import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/auth_session_controller.dart';
import '../data/api_auth_service.dart';
import '../data/dummy_auth_service.dart';
import '../data/google_sign_in_service.dart';
import 'register_page.dart';
import '../widgets/auth_social_buttons.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/facebook_dummy_dialog.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.authService});

  final ApiAuthService? authService;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  late final ApiAuthService _authService = widget.authService ?? ApiAuthService();
  final _googleSignInService = GoogleSignInService();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _phoneCredentialError;
  String? _passwordCredentialError;
  String? _generalError;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final topSpace = constraints.maxHeight >= 760 ? 78.0 : 36.0;

              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  24,
                  topSpace,
                  24,
                  32 + MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Form(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Selamat datang di CleanGo',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Masukkan nomor telepon Anda untuk melanjutkan',
                            style: TextStyle(
                              color: AppColors.slate500,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 34),
                          if (_generalError != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Text(
                                _generalError!,
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
                            label: 'Nomor telepon',
                            hintText: 'Masukkan nomor telepon Anda',
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            isPhone: true,
                            errorText: _phoneCredentialError,
                            onChanged: (_) => _clearPhoneError(),
                          ),
                          const SizedBox(height: 18),
                          AuthTextField(
                            label: 'Kata sandi',
                            hintText: 'Masukkan kata sandi',
                            controller: _passwordController,
                            textInputAction: TextInputAction.done,
                            obscureText: _obscurePassword,
                            errorText: _passwordCredentialError,
                            onChanged: (_) => _clearPasswordError(),
                            onSubmitted: (_) => _submit(),
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
                                      'Login',
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
                                'Belum punya akun?',
                                style: TextStyle(
                                  color: AppColors.slate500,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextButton(
                                onPressed: _openRegister,
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  minimumSize: Size.zero,
                                  padding: const EdgeInsets.only(left: 5),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Buat akun',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                minimumSize: Size.zero,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Lupa kata sandi',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          AuthSocialButtons(
                            isLoading: _isLoading,
                            onFacebookTap: _handleFacebookLogin,
                            onGoogleTap: _handleGoogleLogin,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _handleGoogleLogin() async {
    setState(() {
      _isLoading = true;
      _generalError = null;
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
      await context.read<AuthSessionController>().createSession(result.token);

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } on ApiException catch (e) {
      if (mounted) setState(() => _generalError = e.message);
    } catch (e) {
      if (mounted) {
        setState(() => _generalError = 'Gagal masuk dengan Google: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleFacebookLogin() async {
    final account = await showFacebookDummyDialog(context);
    if (account == null || !mounted) return;

    setState(() {
      _isLoading = true;
      _generalError = null;
    });

    try {
      final result = await _authService.socialLogin(
        provider: 'facebook',
        email: account.email,
        name: account.name,
      );
      if (!mounted) return;
      await context.read<AuthSessionController>().createSession(result.token);
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } on ApiException catch (e) {
      if (mounted) setState(() => _generalError = e.message);
    } catch (_) {
      if (mounted) setState(() => _generalError = 'Gagal terhubung ke server.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _clearPhoneError() {
    if (_phoneCredentialError != null || _generalError != null) {
      setState(() {
        _phoneCredentialError = null;
        _generalError = null;
      });
    }
  }

  void _clearPasswordError() {
    if (_passwordCredentialError != null || _generalError != null) {
      setState(() {
        _passwordCredentialError = null;
        _generalError = null;
      });
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final phoneError = AuthValidators.phone(_phoneController.text);
    final passwordError = AuthValidators.requiredPassword(
      _passwordController.text,
    );

    setState(() {
      _phoneCredentialError = phoneError;
      _passwordCredentialError = passwordError;
      _generalError = null;
    });

    if (phoneError != null || passwordError != null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _authService.login(
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      await context.read<AuthSessionController>().createSession(result.token);

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _generalError = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _generalError = 'Gagal terhubung ke server. Pastikan server aktif.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openRegister() async {
    final registered = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute<bool>(builder: (_) => const RegisterPage()));

    if (!mounted || registered != true) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pendaftaran berhasil. Silakan masuk.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
