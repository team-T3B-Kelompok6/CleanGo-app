import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/dummy_auth_service.dart';
import '../widgets/auth_social_buttons.dart';
import '../widgets/auth_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmation = true;

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
                            () => _obscureConfirmation =
                                !_obscureConfirmation,
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
                          onPressed: _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primaryAction,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
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
                      const AuthSocialButtons(),
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

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    Navigator.of(context).pop(true);
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
