import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import 'onboarding_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loadingController;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1050),
    )..repeat();
    _navigationTimer = Timer(
      const Duration(milliseconds: 2600),
      _openOnboarding,
    );
  }

  void _openOnboarding() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 380),
        pageBuilder: (_, animation, _) => const OnboardingPage(),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFFF4FAFA),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF8FAFC), Color(0xFFF8FAFC), Color(0xFFEAF9F7)],
              stops: [0, 0.47, 1],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 5),
                Container(
                  width: 112,
                  height: 112,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x16006B61),
                        blurRadius: 18,
                        offset: Offset(0, 7),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.asset(
                      'assets/images/app_icon.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: 'Clean'),
                      TextSpan(
                        text: 'Go',
                        style: TextStyle(color: AppColors.primaryAction),
                      ),
                    ],
                  ),
                  style: TextStyle(
                    color: AppColors.slate900,
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1.1,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Layanan Kebersihan Profesional',
                  style: TextStyle(
                    color: AppColors.slate500,
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(flex: 4),
                AnimatedBuilder(
                  animation: _loadingController,
                  builder: (context, _) => _LoadingDots(
                    activeIndex: (_loadingController.value * 3).floor() % 3,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingDots extends StatelessWidget {
  const _LoadingDots({required this.activeIndex});

  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final distance = (index - activeIndex + 3) % 3;
        final color = switch (distance) {
          0 => AppColors.primaryAction,
          1 => const Color(0xFF4EA89F),
          _ => const Color(0xFF91CEC8),
        };
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 10,
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        );
      }),
    );
  }
}
