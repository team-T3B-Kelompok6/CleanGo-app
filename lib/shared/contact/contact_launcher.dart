import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../shared/widgets/app_notice.dart';

/// Nomor CS resmi CleanGo. Satu sumber untuk semua tombol bantuan.
const String cleanGoSupportPhoneDisplay = '082140636747';
const String cleanGoSupportPhoneWa = '6282140636747';
const String cleanGoSupportEmail = 'ahmadbintang812@gmail.com';

/// Nomor Indonesia kanonik ke format wa.me 62.
String waPhone(String value) {
  final digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return '';
  if (digits.startsWith('62')) return digits;
  if (digits.startsWith('0')) return '62' + digits.substring(1);
  return '62$digits';
}

/// Buka WhatsApp dengan nomor dan teks pesan opsional.
/// Tidak mengirim pesan; hanya membuka aplikasi eksternal.
Future<bool> openWhatsApp(
  BuildContext context, {
  required String phone,
  String targetLabel = 'WhatsApp',
  String? text,
}) async {
  final wa = waPhone(phone);
  if (wa.isEmpty) {
    _notify(context, 'Nomor WhatsApp tidak valid.', isError: true);
    return false;
  }
  final uri = Uri.parse(
    text == null
        ? 'https://wa.me/$wa'
        : 'https://wa.me/$wa?text=${Uri.encodeComponent(text)}',
  );
  try {
    if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return true;
  } catch (_) {}
  if (context.mounted) {
    _notify(
      context,
      'WhatsApp belum dapat dibuka. Hubungi CS di $cleanGoSupportPhoneDisplay.',
      isError: true,
    );
  }
  return false;
}

Future<bool> openRefundChat(BuildContext context, String orderCode) {
  return openWhatsApp(
    context,
    phone: cleanGoSupportPhoneWa,
    text:
        'Halo CS CleanGo, saya ingin mengajukan pengembalian dana untuk '
        'pesanan $orderCode. Mohon bantuannya.',
  );
}

/// Buka aplikasi email dengan alamat tujuan.
Future<bool> openEmail(
  BuildContext context, {
  required String email,
  String? subject,
}) async {
  final uri = Uri.parse(
    subject == null
        ? 'mailto:$email'
        : 'mailto:$email?subject=${Uri.encodeComponent(subject)}',
  );
  try {
    if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return true;
  } catch (_) {}
  if (context.mounted) {
    _notify(context, 'Email belum dapat dibuka.', isError: true);
  }
  return false;
}

void _notify(BuildContext context, String message, {bool isError = false}) {
  if (!context.mounted) return;
  AppNotice.show(
    context,
    message,
    type: isError ? AppNoticeType.error : AppNoticeType.info,
  );
}
