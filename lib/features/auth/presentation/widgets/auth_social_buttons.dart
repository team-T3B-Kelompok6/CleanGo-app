import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_theme.dart';

class AuthSocialButtons extends StatelessWidget {
  const AuthSocialButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SocialButton(
          label: 'Facebook',
          svgSource: _facebookSvg,
        ),
        SizedBox(width: 16),
        _SocialButton(label: 'Google', svgSource: _googleSvg),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.label, required this.svgSource});

  final String label;
  final String svgSource;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Masuk dengan $label',
      child: Material(
        color: Colors.white,
        shape: CircleBorder(
          side: BorderSide(color: AppColors.slate200),
        ),
        child: InkWell(
          onTap: () {},
          customBorder: const CircleBorder(),
          child: SizedBox.square(
            dimension: 48,
            child: Center(
              child: SvgPicture.string(svgSource, width: 24, height: 24),
            ),
          ),
        ),
      ),
    );
  }
}

const String _facebookSvg = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="12" cy="12" r="11" fill="#1877F2"/>
  <path d="M13.55 20V13.15H15.85L16.2 10.48H13.55V8.78C13.55 8.01 13.76 7.48 14.88 7.48H16.3V5.09C16.05 5.06 15.21 5 14.23 5C12.18 5 10.78 6.25 10.78 8.55V10.48H8.46V13.15H10.78V20H13.55Z" fill="white"/>
</svg>
''';

const String _googleSvg = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M21.35 12.18C21.35 11.54 21.29 10.93 21.19 10.34H12V13.82H17.25C17.02 14.94 16.35 15.89 15.34 16.53V18.79H18.43C20.24 17.12 21.35 14.66 21.35 12.18Z" fill="#4285F4"/>
  <path d="M12 21.72C14.58 21.72 16.75 20.87 18.43 18.79L15.34 16.53C14.48 17.11 13.38 17.45 12 17.45C9.51 17.45 7.4 15.77 6.64 13.51H3.45V15.84C5.12 19.16 8.55 21.72 12 21.72Z" fill="#34A853"/>
  <path d="M6.64 13.51C6.45 12.93 6.34 12.31 6.34 11.67C6.34 11.03 6.45 10.41 6.64 9.83V7.5H3.45C2.8 8.79 2.43 10.25 2.43 11.67C2.43 13.09 2.8 14.55 3.45 15.84L6.64 13.51Z" fill="#FBBC05"/>
  <path d="M12 5.89C13.4 5.89 14.66 6.37 15.65 7.31L18.5 4.46C16.75 2.83 14.58 1.83 12 1.83C8.55 1.83 5.12 4.39 3.45 7.5L6.64 9.83C7.4 7.57 9.51 5.89 12 5.89Z" fill="#EA4335"/>
</svg>
''';
