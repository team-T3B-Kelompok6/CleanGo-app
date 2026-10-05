import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../profile/controllers/profile_controller.dart';
import '../domain/models/order_model.dart';

class HistoryOrderDetailPage extends StatelessWidget {
  const HistoryOrderDetailPage({
    required this.order,
    required this.onReorder,
    super.key,
  });

  final OrderHistoryModel order;
  final VoidCallback onReorder;

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileController>().profile;
    final isCancelled = order.status == 'DIBATALKAN';

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                _DetailHeader(onBack: () => Navigator.pop(context)),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ServiceSummary(order: order),
                        const SizedBox(height: 14),
                        if (isCancelled) ...[
                          const _CancelledNotice(),
                          const SizedBox(height: 14),
                        ],
                        if (order.address.isNotEmpty) ...[
                          _SectionCard(
                            title: 'Alamat Pengerjaan',
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _RoundIcon(
                                  icon: Icons.location_on_outlined,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    order.address,
                                    style: const TextStyle(
                                      color: AppColors.slate600,
                                      fontFamily: AppTheme.fontFamily,
                                      fontSize: 13.5,
                                      height: 1.55,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                        _SectionCard(
                          title: 'Informasi Pesanan',
                          child: Column(
                            children: [
                              _DetailRow(
                                label: 'No. Pesanan',
                                value: order.orderId,
                              ),
                              _DetailRow(
                                label: 'Jadwal',
                                value: order.schedule,
                              ),
                              _DetailRow(
                                label: 'Catatan',
                                value: order.note.trim().isEmpty
                                    ? 'Tidak ada catatan'
                                    : order.note,
                                isLast: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        _SectionCard(
                          title: 'Rincian Pembayaran',
                          child: Column(
                            children: [
                              _DetailRow(
                                label: 'Biaya layanan',
                                value: _formatRupiah(order.servicePrice),
                              ),
                              _DetailRow(
                                label: 'Biaya platform',
                                value: _formatRupiah(order.platformFee),
                              ),
                              if (order.discountAmount > 0)
                                _DetailRow(
                                  label: 'Diskon',
                                  value:
                                      '-${_formatRupiah(order.discountAmount)}',
                                  discounted: true,
                                ),
                              const Divider(
                                height: 20,
                                color: AppColors.slate100,
                              ),
                              _DetailRow(
                                label: 'Total pembayaran',
                                value: order.price,
                                emphasized: true,
                              ),
                              _DetailRow(
                                label: 'Metode pembayaran',
                                value: order.paymentMethod,
                                isLast: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        _SectionCard(
                          title: 'Profil Pemesan',
                          child: Row(
                            children: [
                              ClipOval(
                                child: Image.asset(
                                  profile.avatarAsset,
                                  width: 42,
                                  height: 42,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => const _RoundIcon(
                                    icon: Icons.person_outline_rounded,
                                    size: 42,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      order.customerName,
                                      style: const TextStyle(
                                        color: AppColors.slate900,
                                        fontFamily: AppTheme.fontFamily,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    const Text(
                                      'Pribadi',
                                      style: TextStyle(
                                        color: AppColors.slate500,
                                        fontFamily: AppTheme.fontFamily,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (order.rating != null) ...[
                          const SizedBox(height: 14),
                          _SectionCard(
                            title: 'Ulasan Anda',
                            child: _ReviewDetails(order: order),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.slate100)),
          ),
          child: SizedBox(
            height: 50,
            child: FilledButton.icon(
              onPressed: onReorder,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryAction,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 19),
              label: const Text(
                'Pesan Lagi',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      child: Row(
        children: [
          Material(
            color: Colors.white,
            shape: const CircleBorder(
              side: BorderSide(color: AppColors.slate200),
            ),
            child: IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
              color: AppColors.slate600,
              iconSize: 21,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detail Pesanan',
                  style: TextStyle(
                    color: AppColors.slate900,
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Informasi layanan yang telah dipesan',
                  style: TextStyle(
                    color: AppColors.slate500,
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceSummary extends StatelessWidget {
  const _ServiceSummary({required this.order});

  final OrderHistoryModel order;

  @override
  Widget build(BuildContext context) {
    final isRaster =
        order.serviceAssetPath.endsWith('.jpg') ||
        order.serviceAssetPath.endsWith('.jpeg') ||
        order.serviceAssetPath.endsWith('.png');
    return _SectionCard(
      title: 'Layanan',
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox.square(
              dimension: 64,
              child: isRaster
                  ? Image.asset(order.serviceAssetPath, fit: BoxFit.cover)
                  : ColoredBox(
                      color: const Color(0xFFE8FAF7),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: SvgPicture.asset(order.serviceAssetPath),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.serviceName,
                  style: const TextStyle(
                    color: AppColors.slate900,
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  order.schedule,
                  style: const TextStyle(
                    color: AppColors.slate500,
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate100),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.slate900,
              fontFamily: AppTheme.fontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.emphasized = false,
    this.discounted = false,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool emphasized;
  final bool discounted;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.slate500,
                fontFamily: AppTheme.fontFamily,
                fontSize: 12.5,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: emphasized || discounted
                    ? AppColors.primaryAction
                    : AppColors.slate900,
                fontFamily: AppTheme.fontFamily,
                fontSize: emphasized ? 15 : 12.5,
                fontWeight: emphasized ? FontWeight.w700 : FontWeight.w600,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewDetails extends StatelessWidget {
  const _ReviewDetails({required this.order});

  final OrderHistoryModel order;

  @override
  Widget build(BuildContext context) {
    final review = order.review;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ...List.generate(
              5,
              (index) => Icon(
                Icons.star_rounded,
                color: index < (order.rating ?? 0).round()
                    ? const Color(0xFFF59E0B)
                    : AppColors.slate200,
                size: 21,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${order.rating!.toStringAsFixed(1)} / 5.0',
              style: const TextStyle(
                color: AppColors.slate900,
                fontFamily: AppTheme.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        if (review != null && review.satisfactionTags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: review.satisfactionTags
                .map(
                  (tag) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDFA),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
        if (review != null && review.comment.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: const TextStyle(
              color: AppColors.slate600,
              fontFamily: AppTheme.fontFamily,
              fontSize: 13,
              height: 1.55,
            ),
          ),
        ],
        if (review != null && review.photoPaths.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: review.photoPaths
                .map(
                  (path) => ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      path,
                      width: 76,
                      height: 76,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 76,
                        height: 76,
                        color: AppColors.slate100,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: AppColors.slate400,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

String _formatRupiah(int value) {
  final digits = value.toString();
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(digits[index]);
  }
  return 'Rp$buffer';
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, this.size = 38});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFE8FAF7),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.primaryAction, size: size * .5),
    );
  }
}

class _CancelledNotice extends StatelessWidget {
  const _CancelledNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFCDD5)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFFBE123C)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Pesanan ini telah dibatalkan.',
              style: TextStyle(
                color: Color(0xFF9F1239),
                fontFamily: AppTheme.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
