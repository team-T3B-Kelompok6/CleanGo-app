import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class HoldCountdownBanner extends StatefulWidget {
  const HoldCountdownBanner({
    required this.holdUntil,
    required this.onCancel,
    this.showCancel = true,
    super.key,
  });

  final DateTime holdUntil;
  final Future<void> Function() onCancel;
  final bool showCancel;

  @override
  State<HoldCountdownBanner> createState() => _HoldCountdownBannerState();
}

class _HoldCountdownBannerState extends State<HoldCountdownBanner> {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _cancelling = false;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final remaining = widget.holdUntil.difference(DateTime.now());
    if (!mounted) return;
    setState(() {
      _remaining = remaining.isNegative ? Duration.zero : remaining;
    });
    if (_remaining == Duration.zero) _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining == Duration.zero) return const SizedBox.shrink();
    final totalSeconds = _remaining.inSeconds;
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, size: 18, color: Color(0xFFB45309)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Admin belum dapat menugaskan petugas selama $minutes:$seconds',
              style: const TextStyle(
                color: Color(0xFF92400E),
                fontFamily: AppTheme.fontFamily,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (widget.showCancel)
            TextButton(
              onPressed: _cancelling
                  ? null
                  : () async {
                      setState(() => _cancelling = true);
                      await widget.onCancel();
                      if (mounted) setState(() => _cancelling = false);
                    },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFB91C1C),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 34),
              ),
              child: Text(_cancelling ? '...' : 'Batalkan'),
            ),
        ],
      ),
    );
  }
}
