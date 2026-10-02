import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/bottom_navigation.dart';
import '../../../../shared/widgets/chatbot_button.dart';
import '../../../chatbot/presentation/pages/chatbot_page.dart';
import '../../data/message_data.dart';
import '../../domain/models/message_notification_model.dart';

enum _MessageTab { all, orders, promo }

class MessagesPage extends StatefulWidget {
  const MessagesPage({this.onMessageTap, super.key});

  final ValueChanged<MessageNotificationModel>? onMessageTap;

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  _MessageTab _selectedTab = _MessageTab.all;
  late List<MessageNotificationModel> _messages;

  @override
  void initState() {
    super.initState();
    _messages = List<MessageNotificationModel>.from(MessageData.notifications);
  }

  int get _unreadCount => _messages.where((m) => m.isUnread).length;

  List<MessageNotificationModel> get _visibleMessages {
    return switch (_selectedTab) {
      _MessageTab.all => _messages,
      _MessageTab.orders => _messages
          .where((message) => message.category == MessageCategory.order)
          .toList(growable: false),
      _MessageTab.promo => _messages
          .where((message) => message.category == MessageCategory.promo)
          .toList(growable: false),
    };
  }

  void _markAsRead(String id) {
    setState(() {
      final index = _messages.indexWhere((m) => m.id == id);
      if (index != -1 && _messages[index].isUnread) {
        _messages[index] = _messages[index].copyWith(isUnread: false);
      }
    });
  }

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
                  child: Column(
                    children: [
                      _MessagesHeader(
                        unreadCount: _unreadCount,
                      ),
                      _MessageTabs(
                        selectedTab: _selectedTab,
                        onSelected: (tab) {
                          if (tab == _selectedTab) return;
                          setState(() => _selectedTab = tab);
                        },
                      ),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          child: ListView.separated(
                            key: ValueKey(_selectedTab),
                            padding: EdgeInsets.fromLTRB(
                              16,
                              16,
                              16,
                              bottomSpacing,
                            ),
                            itemCount: _visibleMessages.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final message = _visibleMessages[index];
                              return _MessageNotificationCard(
                                message: message,
                                onTap: () {
                                  _markAsRead(message.id);
                                  widget.onMessageTap?.call(message);
                                },
                              );
                            },
                          ),
                        ),
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
          currentIndex: 3,
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
    } else if (index == 4) {
      Navigator.pushReplacementNamed(context, AppRoutes.profile);
    }
  }

  void _openChatbot(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ChatbotPage()),
    );
  }
}

class _MessagesHeader extends StatelessWidget {
  const _MessagesHeader({required this.unreadCount});

  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Notifikasi Pesan',
              style: TextStyle(
                color: AppColors.slate900,
                fontFamily: AppTheme.fontFamily,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ),
          if (unreadCount > 0)
            DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.primaryAction,
                borderRadius: BorderRadius.all(Radius.circular(999)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Text(
                  '$unreadCount Baru',
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MessageTabs extends StatelessWidget {
  const _MessageTabs({required this.selectedTab, required this.onSelected});

  final _MessageTab selectedTab;
  final ValueChanged<_MessageTab> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.slate100)),
      ),
      child: Row(
        children: [
          _MessageTabButton(
            label: 'Semua',
            selected: selectedTab == _MessageTab.all,
            onTap: () => onSelected(_MessageTab.all),
          ),
          _MessageTabButton(
            label: 'Pesanan',
            selected: selectedTab == _MessageTab.orders,
            onTap: () => onSelected(_MessageTab.orders),
          ),
          _MessageTabButton(
            label: 'Promo',
            selected: selectedTab == _MessageTab.promo,
            onTap: () => onSelected(_MessageTab.promo),
          ),
        ],
      ),
    );
  }
}

class _MessageTabButton extends StatelessWidget {
  const _MessageTabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: 'Tab $label',
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: selected
                        ? AppColors.primaryAction
                        : AppColors.slate400,
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                if (selected)
                  const Positioned(
                    left: 24,
                    right: 24,
                    bottom: 0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.primaryAction,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(99),
                        ),
                      ),
                      child: SizedBox(height: 3),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageNotificationCard extends StatelessWidget {
  const _MessageNotificationCard({
    required this.message,
    required this.onTap,
  });

  final MessageNotificationModel message;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = message.isWarning
        ? const Color(0xFFFFFBEB)
        : Colors.white;
    final borderColor = message.isWarning
        ? const Color(0xFFF6D986)
        : AppColors.slate100;

    return Semantics(
      button: onTap != null,
      label: '${message.title}. ${message.description}',
      child: Material(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor),
        ),
        elevation: 0,
        shadowColor: const Color(0x120F172A),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MessageIcon(message: message),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              message.title,
                              style: const TextStyle(
                                color: AppColors.slate900,
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                height: 1.35,
                              ),
                            ),
                          ),
                          if (message.isUnread) ...[
                            const SizedBox(width: 8),
                            const Padding(
                              padding: EdgeInsets.only(top: 5),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: AppColors.primaryAction,
                                  shape: BoxShape.circle,
                                ),
                                child: SizedBox.square(dimension: 8),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message.description,
                        style: const TextStyle(
                          color: AppColors.slate500,
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          Text(
                            message.timeLabel,
                            style: const TextStyle(
                              color: AppColors.slate400,
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                          ),
                          if (message.badge != null)
                            _MessageBadge(label: message.badge!),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageIcon extends StatelessWidget {
  const _MessageIcon({required this.message});

  final MessageNotificationModel message;

  @override
  Widget build(BuildContext context) {
    final isWarm = message.iconType == MessageIconType.delayed ||
        message.iconType == MessageIconType.promo;
    final background = isWarm
        ? const Color(0xFFFFF1C7)
        : AppColors.primaryContainer.withValues(alpha: 0.55);
    final foreground = isWarm
        ? const Color(0xFFD97706)
        : AppColors.primaryAction;
    final icon = switch (message.iconType) {
      MessageIconType.delivery => Icons.directions_bike_outlined,
      MessageIconType.confirmed => Icons.check_circle_outline_rounded,
      MessageIconType.delayed => Icons.warning_amber_rounded,
      MessageIconType.payment => Icons.verified_outlined,
      MessageIconType.promo => Icons.card_giftcard_rounded,
      MessageIconType.rating => Icons.star_rounded,
    };

    return DecoratedBox(
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: SizedBox.square(
        dimension: 42,
        child: Icon(icon, size: 22, color: foreground),
      ),
    );
  }
}

class _MessageBadge extends StatelessWidget {
  const _MessageBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFF1D279)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.auto_awesome_rounded,
              size: 11,
              color: Color(0xFFD97706),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF92400E),
                fontFamily: AppTheme.fontFamily,
                fontSize: 9,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
