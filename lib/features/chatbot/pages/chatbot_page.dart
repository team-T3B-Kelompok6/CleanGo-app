import 'dart:math' as math;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_notice.dart';
import '../../../shared/widgets/chatbot_icon.dart';
import '../controllers/chatbot_controller.dart';
import '../models/chat_message.dart';
import '../data/chatbot_repository.dart';
import '../data/chat_history_store.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({
    super.key,
    this.repository,
    this.history,
    this.initialMessage,
  });

  final ChatbotGateway? repository;
  final ChatHistoryStore? history;
  final String? initialMessage;

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  late final ChatbotController _chatbotController = ChatbotController(
    repository: widget.repository,
    history: widget.history,
  );
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final message = widget.initialMessage?.trim() ?? '';
      if (message.isNotEmpty) {
        _messageController.text = message;
        _handleMessageChanged(message);
        unawaited(_sendMessage());
      } else {
        unawaited(
          _chatbotController.restoreHistory().then((_) {
            if (mounted) _scrollToEnd();
          }),
        );
      }
    });
  }

  @override
  void dispose() {
    _chatbotController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleMessageChanged(String value) {
    _chatbotController.updateDraft(value);
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _chatbotController.isSending) return;
    if (message.length > 2000) {
      AppNotice.show(
        context,
        'Pesan maksimal 2000 karakter.',
        type: AppNoticeType.error,
      );
      return;
    }
    final pending = _chatbotController.sendMessage(message);
    _messageController.clear();
    _scrollToEnd();
    await pending;
    if (mounted) {
      _scrollToEnd();
      if (_chatbotController.messages.isNotEmpty &&
          _chatbotController.messages.last.failed) {
        AppNotice.show(
          context,
          'Pesan belum berhasil dikirim. Silakan coba lagi.',
          type: AppNoticeType.error,
        );
      }
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _chatbotController,
      builder: (context, _) => AnnotatedRegion<SystemUiOverlayStyle>(
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
                      child: _chatbotController.messages.isEmpty
                          ? const _ChatbotWelcome()
                          : _MessageList(
                              controller: _scrollController,
                              messages: _chatbotController.messages,
                              isSending: _chatbotController.isSending,
                            ),
                    ),
                    if (_chatbotController.historyUnavailable)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Riwayat belum dapat disimpan atau dimuat di perangkat ini.',
                        ),
                      ),
                    _ChatInput(
                      controller: _messageController,
                      hasMessage:
                          _chatbotController.hasMessage &&
                          !_chatbotController.isSending,
                      onChanged: _handleMessageChanged,
                      onSend: _sendMessage,
                    ),
                  ],
                ),
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
                    'Boo · CS AI',
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
                const ChatbotIcon(size: 80),
                const SizedBox(height: 30),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 310),
                  child: const Text.rich(
                    TextSpan(
                      text: 'Hai, saya Boo, Customer Service AI dari ',
                      children: [
                        TextSpan(
                          text: 'CleanGo',
                          style: TextStyle(
                            color: AppColors.primaryAction,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text: '. Saya siap membantu layanan, booking, dan kendala Anda. Ada yang bisa saya bantu?',
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

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.controller,
    required this.messages,
    required this.isSending,
  });

  final ScrollController controller;
  final List<ChatMessage> messages;
  final bool isSending;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: controller,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
      itemCount: messages.length + (isSending ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index == messages.length) {
          return const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Boo sedang mengetik…',
              semanticsLabel: 'Boo sedang menyiapkan jawaban',
            ),
          );
        }
        final message = messages[index];
        return Align(
          alignment: message.isUser
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.76,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: message.isUser
                    ? AppColors.primaryAction
                    : AppColors.slate100,
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
                  message.content,
                  style: TextStyle(
                    color: message.isUser ? Colors.white : AppColors.slate900,
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
            Semantics(
              button: true,
              label: 'Kirim pesan',
              child: Material(
                color: AppColors.primaryAction,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: hasMessage ? onSend : null,
                  customBorder: const CircleBorder(),
                  child: SizedBox.square(
                    dimension: 40,
                    child: Icon(
                      Icons.send_rounded,
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
