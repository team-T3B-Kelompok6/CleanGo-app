import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_sheet.dart';

Future<bool> showOrderConfirmationDialog(
  BuildContext context, {
  required String serviceName,
  required String schedule,
  required String address,
  required String note,
  required String paymentMethod,
  required String total,
}) async {
  FocusManager.instance.primaryFocus?.unfocus();

  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x730F172A),
    builder: (context) => _OrderConfirmationSheet(
      serviceName: serviceName,
      schedule: schedule,
      address: address,
      note: note,
      paymentMethod: paymentMethod,
      total: total,
    ),
  );

  return result ?? false;
}

class _OrderConfirmationSheet extends StatelessWidget {
  const _OrderConfirmationSheet({
    required this.serviceName,
    required this.schedule,
    required this.address,
    required this.note,
    required this.paymentMethod,
    required this.total,
  });

  final String serviceName;
  final String schedule;
  final String address;
  final String note;
  final String paymentMethod;
  final String total;

  @override
  Widget build(BuildContext context) {
    return AppSheet(
      title: 'Konfirmasi Pesanan',
      subtitle: 'Periksa alamat, jadwal, dan layanan sebelum membayar.',
      actions: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context, false),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryAction,
                minimumSize: const Size.fromHeight(50),
                side: const BorderSide(color: AppColors.primaryAction),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Periksa Lagi',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryAction,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Lanjut Bayar',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      child: Column(
        children: [
          _ConfirmationRow(label: 'Layanan', value: serviceName),
          const SizedBox(height: 12),
          _ConfirmationRow(label: 'Jadwal', value: schedule),
          const SizedBox(height: 12),
          _ConfirmationRow(label: 'Alamat', value: address),
          const SizedBox(height: 12),
          _ConfirmationRow(label: 'Catatan', value: note),
          const SizedBox(height: 12),
          _ConfirmationRow(label: 'Pembayaran', value: paymentMethod),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: AppColors.slate100),
          ),
          _ConfirmationRow(label: 'Total', value: total, emphasized: true),
        ],
      ),
    );
  }
}

class _ConfirmationRow extends StatelessWidget {
  const _ConfirmationRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: MediaQuery.textScalerOf(context).scale(104),
          child: Text(
            label,
            style: TextStyle(
              color: emphasized ? AppColors.slate900 : AppColors.slate500,
              fontFamily: AppTheme.fontFamily,
              fontSize: 14,
              fontWeight: emphasized ? FontWeight.w600 : FontWeight.w500,
              height: 1.5,
            ),
          ),
        ),
        SizedBox(
          width: 14,
          child: Text(
            ':',
            style: TextStyle(
              color: emphasized ? AppColors.slate900 : AppColors.slate500,
              fontFamily: AppTheme.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: emphasized ? AppColors.primaryAction : AppColors.slate900,
              fontFamily: AppTheme.fontFamily,
              fontSize: emphasized ? 18 : 14,
              fontWeight: emphasized ? FontWeight.w700 : FontWeight.w600,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
