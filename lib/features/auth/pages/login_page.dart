import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../data/dummy_auth_service.dart';
import 'register_page.dart';
import '../widgets/auth_social_buttons.dart';
import '../widgets/auth_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = const DummyAuthService();

  bool _obscurePassword = true;
  String? _phoneCredentialError;
  String? _passwordCredentialError;

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
                              onPressed: _submit,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primaryAction,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
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
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
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
                          const AuthSocialButtons(),
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

  void _clearPhoneError() {
    if (_phoneCredentialError != null) {
      setState(() => _phoneCredentialError = null);
    }
  }

  void _clearPasswordError() {
    if (_passwordCredentialError != null) {
      setState(() => _passwordCredentialError = null);
    }
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    final result = _authService.validateLogin(
      phone: _phoneController.text,
      password: _passwordController.text,
    );

    setState(() {
      _phoneCredentialError = result.phoneError;
      _passwordCredentialError = result.passwordError;
    });

    if (!result.isSuccess) {
      return;
    }

    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  Future<void> _openRegister() async {
    final registered = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const RegisterPage()),
    );

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
