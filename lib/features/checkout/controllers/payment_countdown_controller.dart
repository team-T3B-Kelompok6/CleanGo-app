import 'dart:async';

import 'package:flutter/foundation.dart';

class PaymentCountdownController extends ChangeNotifier {
  PaymentCountdownController({this.duration = const Duration(minutes: 15)}) {
    _deadline = DateTime.now().add(duration);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  final Duration duration;
  late final DateTime _deadline;
  Timer? _timer;
  Duration _remaining = const Duration(minutes: 15);

  Duration get remaining => _remaining;
  bool get isExpired => _remaining == Duration.zero;

  String get formattedRemaining {
    final minutes = _remaining.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final seconds = _remaining.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _tick() {
    final difference = _deadline.difference(DateTime.now());
    final next = difference.isNegative ? Duration.zero : difference;
    if (next.inSeconds == _remaining.inSeconds) return;
    _remaining = next;
    notifyListeners();
    if (isExpired) _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
