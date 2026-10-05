import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/chatbot_icon.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<String> _messages = [];

  bool _hasMessage = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleMessageChanged(String value) {
    final hasMessage = value.trim().isNotEmpty;
    if (hasMessage == _hasMessage) return;
    setState(() => _hasMessage = hasMessage);
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add(message);
      _messageController.clear();
      _hasMessage = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                children: [
                  const _ChatbotHeader(),
                  Expanded(
                    child: _messages.isEmpty
                        ? const _ChatbotWelcome()
                        : _MessageList(
                            controller: _scrollController,
                            messages: _messages,
                          ),
                  ),
                  _ChatInput(
                    controller: _messageController,
                    hasMessage: _hasMessage,
                    onChanged: _handleMessageChanged,
                    onSend: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatbotHeader extends StatelessWidget {
  const _ChatbotHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            _HeaderBackButton(onTap: () => Navigator.maybePop(context)),
            const Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChatbotIcon(size: 32),
                  SizedBox(width: 9),
                  Text(
                    'Boo',
                    style: TextStyle(
                      color: AppColors.heading,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox.square(dimension: 40),
          ],
        ),
      ),
    );
  }
}

class _HeaderBackButton extends StatelessWidget {
  const _HeaderBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Kembali',
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: 1,
        shadowColor: const Color(0x14000000),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox.square(
            dimension: 40,
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/back.svg',
                width: 16,
                height: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatbotWelcome extends StatelessWidget {
  const _ChatbotWelcome();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final topSpace = math.max(50.0, constraints.maxHeight * 0.17);
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              children: [
                SizedBox(height: topSpace),
                const _WelcomeOrb(),
                const SizedBox(height: 30),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 310),
                  child: const Text.rich(
                    TextSpan(
                      text:
                          'Hai, saya adalah Boo, asisten rumah pribadi Anda dari ',
                      children: [
                        TextSpan(
                          text: 'CleanGo',
                          style: TextStyle(
                            color: AppColors.primaryAction,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text:
                              '. Apa yang bisa saya bantu untuk Anda hari ini?',
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.slate600,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.55,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WelcomeOrb extends StatelessWidget {
  const _WelcomeOrb();

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 112,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 106,
            height: 106,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0x6636D7C8), Color(0x1A75E5D8), Colors.white],
                stops: [0, 0.52, 1],
              ),
            ),
          ),
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: Alignment(-0.22, -0.28),
                colors: [
                  Color(0xFFFFFFFF),
                  Color(0xFFE6FFF9),
                  Color(0xFF8FE3D8),
                  Color(0xFFF9D675),
                ],
                stops: [0, 0.38, 0.73, 1],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x3334C8B8),
                  blurRadius: 20,
                  spreadRadius: 3,
                ),
              ],
            ),
          ),
          Positioned(
            right: 15,
            bottom: 18,
            child: Container(
              width: 17,
              height: 17,
              decoration: BoxDecoration(
                color: const Color(0xFF65D5C8),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({required this.controller, required this.messages});

  final ScrollController controller;
  final List<String> messages;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: controller,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
      itemCount: messages.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return Align(
          alignment: Alignment.centerRight,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.76,
            ),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.primaryAction,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(5),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 11,
                ),
                child: Text(
                  messages[index],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ChatInput extends StatelessWidget {
  const _ChatInput({
    required this.controller,
    required this.hasMessage,
    required this.onChanged,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool hasMessage;
  final ValueChanged<String> onChanged;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Container(
        constraints: const BoxConstraints(minHeight: 52),
        padding: const EdgeInsets.fromLTRB(16, 5, 6, 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.slate200),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              offset: Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                onSubmitted: (_) => onSend(),
                textInputAction: TextInputAction.send,
                style: const TextStyle(
                  color: AppColors.slate900,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: 'Masukkan pesan ....',
                  hintStyle: TextStyle(
                    color: AppColors.slate400,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.image_outlined,
              color: AppColors.slate500,
              size: 20,
            ),
            const SizedBox(width: 8),
            Semantics(
              button: true,
              label: hasMessage ? 'Kirim pesan' : 'Pesan suara',
              child: Material(
                color: AppColors.primaryAction,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: hasMessage ? onSend : null,
                  customBorder: const CircleBorder(),
                  child: SizedBox.square(
                    dimension: 40,
                    child: Icon(
                      hasMessage ? Icons.send_rounded : Icons.mic_none_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
