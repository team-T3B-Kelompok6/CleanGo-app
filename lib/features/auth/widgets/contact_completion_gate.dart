import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../controllers/contact_completion_controller.dart';

/// Menampilkan popup kontak di atas halaman manapun. Popup nomor telepon tidak
/// bisa ditutup dengan tombol kembali atau sentuhan di luar; email opsional
/// hanya lewat tombol Lewati atau Simpan.
class ContactCompletionGate extends StatefulWidget {
  const ContactCompletionGate({
    super.key,
    required this.controller,
    required this.child,
    this.navigatorKey,
  });

  final ContactCompletionController controller;
  final Widget child;
  final GlobalKey<NavigatorState>? navigatorKey;

  @override
  State<ContactCompletionGate> createState() => _ContactCompletionGateState();
}

class _ContactCompletionGateState extends State<ContactCompletionGate> {
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  bool _dialogOpen = false;
  bool _openScheduled = false;
  ModalRoute<void>? _route;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_sync);
    _sync();
  }

  @override
  void didUpdateWidget(ContactCompletionGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_sync);
      widget.controller.addListener(_sync);
      _sync();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_sync);
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  NavigatorState? get _navigator =>
      widget.navigatorKey?.currentState ?? Navigator.maybeOf(context);

  void _sync() {
    final controller = widget.controller;
    final visible =
        controller.shouldShowPhoneGate || controller.shouldShowEmailReminder;

    if (visible && !_dialogOpen && !_openScheduled) {
      _openScheduled = true;
      if (controller.shouldShowPhoneGate) {
        _phoneController.clear();
      } else {
        _emailController.clear();
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openScheduled = false;
        if (!mounted) return;
        // clear()/logout bisa terjadi sebelum frame ini berjalan.
        if (!widget.controller.shouldShowPhoneGate &&
            !widget.controller.shouldShowEmailReminder) {
          return;
        }
        unawaited(_openDialog());
      });
    } else if (!visible && _dialogOpen) {
      _closeDialog();
    }
  }

  /// Hanya menutup DialogRoute milik popup ini. Halaman lain yang berada di
  /// atasnya tidak ikut ter-pop saat logout/response async.
  void _closeDialog() {
    final route = _route;
    _route = null;
    _dialogOpen = false;
    if (route == null) return;
    final navigator = _navigator;
    if (navigator == null) return;
    if (route.isCurrent) {
      navigator.pop();
    } else if (route.isActive) {
      navigator.removeRoute(route);
    }
  }

  Future<void> _openDialog() async {
    final navigator = _navigator;
    if (navigator == null) {
      _dialogOpen = false;
      return;
    }
    final route = DialogRoute<void>(
      context: navigator.context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (dialogContext) => ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          final controller = widget.controller;
          if (!controller.shouldShowPhoneGate &&
              !controller.shouldShowEmailReminder) {
            return const SizedBox.shrink();
          }
          return PopScope(
            canPop: false,
            child: controller.shouldShowPhoneGate
                ? _phoneDialog(controller)
                : _emailDialog(controller),
          );
        },
      ),
    );
    _route = route;
    _dialogOpen = true;
    await navigator.push(route);
    _dialogOpen = false;
    if (identical(_route, route)) _route = null;
  }

  Widget _phoneDialog(ContactCompletionController controller) {
    return AlertDialog(
      title: const Text('Nomor telepon wajib'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Nomor telepon diperlukan sebelum Anda dapat membuat pesanan.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Nomor telepon',
              hintText: 'Contoh: 081234567890',
              errorText: controller.phoneError,
            ),
          ),
          if (controller.message != null) ...[
            const SizedBox(height: 12),
            Text(
              controller.message!,
              style: TextStyle(color: Colors.red.shade700, fontSize: 13),
            ),
          ],
        ],
      ),
      actions: [
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryAction,
            foregroundColor: Colors.white,
          ),
          onPressed: controller.isSubmitting
              ? null
              : () => controller.submitPhone(_phoneController.text),
          child: controller.isSubmitting
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Simpan'),
        ),
      ],
    );
  }

  Widget _emailDialog(ContactCompletionController controller) {
    return AlertDialog(
      title: const Text('Lengkapi email (opsional)'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Email membantu Anda memulihkan akun. Anda bisa melewatinya sekarang.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'nama@email.com',
              errorText: controller.emailError,
            ),
          ),
          if (controller.message != null) ...[
            const SizedBox(height: 12),
            Text(
              controller.message!,
              style: TextStyle(color: Colors.red.shade700, fontSize: 13),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: controller.isSubmitting ? null : controller.skipEmail,
          child: const Text('Lewati'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryAction,
            foregroundColor: Colors.white,
          ),
          onPressed: controller.isSubmitting
              ? null
              : () => controller.submitEmail(_emailController.text),
          child: controller.isSubmitting
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Simpan'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
