import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

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
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Align(
      alignment: Alignment.bottomCenter,
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 20 + bottomInset),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.slate200,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8FAF7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.fact_check_outlined,
                        color: AppColors.primaryAction,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Konfirmasi Pesanan',
                            style: TextStyle(
                              color: AppColors.slate900,
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Pastikan alamat dan pesanan Anda sudah sesuai sebelum melanjutkan pembayaran.',
                            style: TextStyle(
                              color: AppColors.slate500,
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.screenBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.slate100),
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
                      _ConfirmationRow(
                        label: 'Pembayaran',
                        value: paymentMethod,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Divider(height: 1, color: AppColors.slate200),
                      ),
                      _ConfirmationRow(
                        label: 'Total',
                        value: total,
                        emphasized: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryAction,
                          minimumSize: const Size.fromHeight(50),
                          side: const BorderSide(
                            color: AppColors.primaryAction,
                          ),
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
              ],
            ),
          ),
        ),
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
          width: 78,
          child: Text(
            label,
            style: TextStyle(
              color: emphasized ? AppColors.slate900 : AppColors.slate500,
              fontFamily: AppTheme.fontFamily,
              fontSize: 12,
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
              fontSize: 12,
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
              color: emphasized
                  ? AppColors.primaryAction
                  : AppColors.slate900,
              fontFamily: AppTheme.fontFamily,
              fontSize: emphasized ? 15 : 12,
              fontWeight: emphasized ? FontWeight.w700 : FontWeight.w600,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
