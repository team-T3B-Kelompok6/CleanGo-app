import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/bottom_navigation.dart';
import '../../../shared/widgets/chatbot_button.dart';
import '../../address/controllers/address_controller.dart';
import '../../address/pages/address_list_page.dart';
import '../../chatbot/pages/chatbot_page.dart';
import '../../support/pages/help_center_page.dart';
import '../controllers/profile_controller.dart';
import 'change_password_page.dart';
import 'personal_data_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    this.onPersonalDataTap,
    this.onSavedAddressesTap,
    this.onHelpTap,
    this.onChangePasswordTap,
    this.onEditProfileTap,
    this.onLogout,
    super.key,
  });

  final VoidCallback? onPersonalDataTap;
  final VoidCallback? onSavedAddressesTap;
  final VoidCallback? onHelpTap;
  final VoidCallback? onChangePasswordTap;
  final VoidCallback? onEditProfileTap;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final contentSideInset = ((mediaQuery.size.width - 480) / 2 + 16).clamp(
      16.0,
      double.infinity,
    );
    final bottomSpacing =
        BottomNavigation.contentHeight + mediaQuery.viewPadding.bottom + 88;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.screenBackground,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        extendBody: true,
        backgroundColor: AppColors.screenBackground,
        body: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: SafeArea(
                  bottom: false,
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(16, 18, 16, bottomSpacing),
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          'Profil & Pengaturan',
                          style: TextStyle(
                            color: AppColors.slate900,
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const _ProfileIdentityCard(),
                      const SizedBox(height: 20),
                      const _SectionLabel(label: 'PENGATURAN AKUN'),
                      const SizedBox(height: 8),
                      _ProfileMenuGroup(
                        children: [
                          _ProfileMenuTile(
                            icon: Icons.person_outline_rounded,
                            title: 'Data Diri',
                            onTap: onPersonalDataTap ??
                                () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => const PersonalDataPage(),
                                    ),
                                  );
                                },
                          ),
                          Consumer<AddressController>(
                            builder: (context, addressController, _) {
                              final count = addressController.addresses.length;
                              return _ProfileMenuTile(
                                icon: Icons.location_on_outlined,
                                title: 'Alamat Tersimpan',
                                subtitle: '$count Alamat aktif',
                                onTap: onSavedAddressesTap ??
                                    () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) => const AddressListPage(
                                            isSelectionMode: false,
                                          ),
                                        ),
                                      );
                                    },
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const _SectionLabel(label: 'UMUM & DUKUNGAN'),
                      const SizedBox(height: 8),
                      _ProfileMenuGroup(
                        children: [
                          _ProfileMenuTile(
                            icon: Icons.help_outline_rounded,
                            title: 'Bantuan',
                            subtitle: 'FAQ & Kontak Dukungan',
                            onTap: onHelpTap ??
                                () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => const HelpCenterPage(),
                                    ),
                                  );
                                },
                          ),
                          _ProfileMenuTile(
                            icon: Icons.lock_outline_rounded,
                            title: 'Ubah Kata Sandi',
                            onTap: onChangePasswordTap ??
                                () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => const ChangePasswordPage(),
                                    ),
                                  );
                                },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _LogoutButton(
                        onTap: onLogout ?? () => _logout(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: contentSideInset,
              bottom:
                  BottomNavigation.contentHeight +
                  mediaQuery.viewPadding.bottom +
                  12,
              child: ChatbotButton(onTap: () => _openChatbot(context)),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigation(
          currentIndex: 4,
          showOrderBadge: false,
          onDestinationSelected: (index) => _handleNavigation(context, index),
        ),
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, AppRoutes.services);
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, AppRoutes.orders);
    } else if (index == 3) {
      Navigator.pushReplacementNamed(context, AppRoutes.messages);
    }
  }

  void _logout(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  void _openChatbot(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ChatbotPage()),
    );
  }
}

class _ProfileIdentityCard extends StatelessWidget {
  const _ProfileIdentityCard();

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileController>().profile;

    return _ProfileCard(
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: AppColors.primaryBorder,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              backgroundImage: AssetImage(profile.avatarAsset),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.slate900,
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  profile.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.slate500,
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(
                      Icons.phone_outlined,
                      size: 13,
                      color: AppColors.primaryAction,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        profile.phoneNumber,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.slate500,
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primaryAction,
          fontFamily: AppTheme.fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          height: 1.3,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _ProfileMenuGroup extends StatelessWidget {
  const _ProfileMenuGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return _ProfileCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index < children.length - 1)
              const Divider(
                height: 1,
                indent: 68,
                endIndent: 16,
                color: AppColors.slate100,
              ),
          ],
        ],
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            children: [
              _CircularMenuIcon(icon: icon),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.slate900,
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          color: AppColors.slate500,
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.slate400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircularMenuIcon extends StatelessWidget {
  const _CircularMenuIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.42),
        shape: BoxShape.circle,
      ),
      child: SizedBox.square(
        dimension: 38,
        child: Icon(icon, size: 20, color: AppColors.primaryAction),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Keluar dari akun',
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFFFE4E6)),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0xFFFFF1F2),
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox.square(
                    dimension: 38,
                    child: Icon(
                      Icons.logout_rounded,
                      size: 20,
                      color: Color(0xFFE11D48),
                    ),
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Keluar dari Akun',
                    style: TextStyle(
                      color: Color(0xFFE11D48),
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: Color(0xFFFB7185),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate100),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0F172A),
            offset: Offset(0, 3),
            blurRadius: 10,
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
