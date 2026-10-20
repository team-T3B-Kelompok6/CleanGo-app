import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_theme.dart';
import '../../booking/controllers/booking_controller.dart';
import '../controllers/checkout_controller.dart';
import '../domain/models/promo_model.dart';

class PromoPage extends StatefulWidget {
  const PromoPage({
    required this.servicePrice,
    this.initialPromoCode,
    super.key,
  });

  final int servicePrice;
  final String? initialPromoCode;

  @override
  State<PromoPage> createState() => _PromoPageState();
}

class _PromoPageState extends State<PromoPage> {
  final _selection = CheckoutController();

  @override
  void initState() {
    super.initState();
    _selection.applyPromo(widget.initialPromoCode ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.screenBackground,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.screenBackground,
        body: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                    child: Row(
                      children: [
                        Material(
                          color: Colors.white,
                          shape: const CircleBorder(
                            side: BorderSide(color: AppColors.slate100),
                          ),
                          child: InkWell(
                            key: const ValueKey('promo-back'),
                            onTap: () => Navigator.pop(context),
                            customBorder: const CircleBorder(),
                            child: SizedBox.square(
                              dimension: 38,
                              child: Center(
                                child: SvgPicture.asset(
                                  'assets/icons/detail_back.svg',
                                  width: 15,
                                  height: 15,
                                  semanticsLabel: 'Kembali',
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Promo',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontSize: 24,
                                      letterSpacing: -0.2,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Pilih promo untuk pesanan Anda',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
                      itemCount: CheckoutController.availablePromos.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final promo = CheckoutController.availablePromos[index];
                        final selected =
                            _selection.appliedPromo?.code == promo.code;
                        return _PromoOptionCard(
                          promo: promo,
                          selected: selected,
                          savings: BookingController.formatRupiah(
                            promo.discountAmount(widget.servicePrice),
                          ),
                          onTap: () => setState(() {
                            if (selected) {
                              _selection.clearPromo();
                            } else {
                              _selection.applyPromo(promo.code);
                            }
                          }),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: DecoratedBox(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.slate100)),
          ),
          child: SafeArea(
            top: false,
            child: Center(
              heightFactor: 1,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      key: const ValueKey('confirm-promo'),
                      onPressed: () => Navigator.pop(
                        context,
                        _selection.appliedPromo?.code ?? '',
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryAction,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _selection.isPromoApplied
                            ? 'Gunakan Promo'
                            : 'Lanjutkan tanpa Promo',
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PromoOptionCard extends StatelessWidget {
  const _PromoOptionCard({
    required this.promo,
    required this.selected,
    required this.savings,
    required this.onTap,
  });

  final PromoModel promo;
  final bool selected;
  final String savings;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? const Color(0xFFE8FAF7) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          key: ValueKey('promo-${promo.code}'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? AppColors.primaryAction : AppColors.slate100,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.sell_outlined,
                  size: 24,
                  color: AppColors.primaryAction,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(promo.title, style: textTheme.titleSmall),
                      const SizedBox(height: 6),
                      Text(promo.code, style: textTheme.labelLarge),
                      const SizedBox(height: 6),
                      Text(
                        'Potongan biaya layanan, tidak termasuk biaya platform.',
                        style: textTheme.bodySmall?.copyWith(fontSize: 13),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Hemat $savings',
                        style: textTheme.labelLarge?.copyWith(
                          color: AppColors.primaryAction,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected
                      ? AppColors.primaryAction
                      : AppColors.slate400,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
