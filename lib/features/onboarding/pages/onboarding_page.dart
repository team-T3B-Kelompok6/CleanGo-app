import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../data/onboarding_data.dart';
import '../domain/models/onboarding_item.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  bool get _isLastPage => _currentPage == OnboardingData.items.length - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openLogin() {
    Navigator.of(context)
        .pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  void _nextPage() {
    if (_isLastPage) {
      _openLogin();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: OnboardingData.items.length,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      itemBuilder: (context, index) =>
                          _OnboardingContent(item: OnboardingData.items[index]),
                    ),
                  ),
                  _PageIndicator(currentPage: _currentPage),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: _isLastPage
                          ? SizedBox(
                              key: const ValueKey('start'),
                              width: double.infinity,
                              height: 54,
                              child: FilledButton(
                                onPressed: _openLogin,
                                style: _filledButtonStyle(),
                                child: const Text('Mulai Sekarang'),
                              ),
                            )
                          : Row(
                              key: const ValueKey('navigation'),
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 54,
                                    child: OutlinedButton(
                                      onPressed: _openLogin,
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.slate600,
                                        side: const BorderSide(
                                          color: AppColors.slate200,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            28,
                                          ),
                                        ),
                                      ),
                                      child: const Text('Lewati'),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: SizedBox(
                                    height: 54,
                                    child: FilledButton(
                                      onPressed: _nextPage,
                                      style: _filledButtonStyle(),
                                      child: const Text('Lanjut'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  ButtonStyle _filledButtonStyle() {
    return FilledButton.styleFrom(
      backgroundColor: AppColors.primaryAction,
      foregroundColor: Colors.white,
      textStyle: const TextStyle(
        fontFamily: AppTheme.fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 2,
      shadowColor: const Color(0x2600685F),
    );
  }
}

class _OnboardingContent extends StatelessWidget {
  const _OnboardingContent({required this.item});

  final OnboardingItem item;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final imageSize = (screenHeight * 0.36).clamp(250.0, 344.0);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 12),
      child: Column(
        children: [
          SizedBox(height: screenHeight < 700 ? 6 : 28),
          Container(
            width: imageSize,
            height: imageSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x170F172A),
                  blurRadius: 16,
                  offset: Offset(0, 7),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.asset(item.imagePath, fit: BoxFit.contain),
            ),
          ),
          SizedBox(height: screenHeight < 700 ? 24 : 36),
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.slate900,
              fontFamily: AppTheme.fontFamily,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1.25,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: Text(
              item.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.slate500,
                fontFamily: AppTheme.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.currentPage});

  final int currentPage;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(OnboardingData.items.length, (index) {
        final selected = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          width: selected ? 28 : 10,
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryAction : const Color(0xFFD6DEE8),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}
