import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_theme.dart';
import '../../booking/controllers/booking_controller.dart';
import '../controllers/checkout_controller.dart';
import '../data/customer_promo_api.dart';
import '../domain/models/promo_model.dart';

class PromoPage extends StatefulWidget {
  const PromoPage({
    required this.servicePrice,
    this.initialPromoCode,
    this.promoApi,
    this.serviceId,
    super.key,
  });

  final int servicePrice;
  final String? initialPromoCode;

  /// Null means local-only mode (bundled demo list, no network).
  final CustomerPromoApi? promoApi;

  /// Backend service id of the service being checked out; scoped promos that
  /// do not cover this service are hidden from the list.
  final String? serviceId;

  @override
  State<PromoPage> createState() => _PromoPageState();
}

class _PromoPageState extends State<PromoPage> {
  late final CheckoutController _selection = CheckoutController(
    promoApi: widget.promoApi,
  );
  bool _isLoading = false;
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Show the current selection immediately; the backend refresh follows.
    final code = widget.initialPromoCode ?? '';
    if (code.isNotEmpty) _selection.applyPromo(code);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() => _isLoading = true);
    await _selection.loadPromos(serviceId: widget.serviceId);
    final code = widget.initialPromoCode ?? '';
    if (code.isNotEmpty) {
      // Re-validate against the freshly loaded list (handles server-only codes).
      await _selection.applyPromoRemote(
        code: code,
        servicePrice: widget.servicePrice,
        serviceId: widget.serviceId,
      );
    }
    if (mounted) setState(() => _isLoading = false);
  }

  bool _appliesToService(PromoModel promo) {
    if (promo.scope != 'services') return true;
    final serviceId = widget.serviceId;
    if (promo.serviceIds.isEmpty) return true;
    if (serviceId == null || serviceId.isEmpty) return false;
    return promo.serviceIds.contains(serviceId);
  }

  String? _eligibility(PromoModel promo) {
    if (!_appliesToService(promo)) return 'Tidak berlaku untuk layanan ini';
    if (promo.remainingQuota == 0) return 'Kuota habis';
    if (widget.servicePrice < promo.minPurchase) {
      return 'Min. transaksi ${BookingController.formatRupiah(promo.minPurchase)}';
    }
    return null;
  }

  Future<void> _selectCode(String code) async {
    if (_isLoading || code.trim().isEmpty) return;
    setState(() => _isLoading = true);
    await _selection.applyPromoRemote(
      code: code,
      servicePrice: widget.servicePrice,
      serviceId: widget.serviceId,
    );
    if (mounted) setState(() => _isLoading = false);
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
                                'Pilih Voucher',
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _code,
                            enabled: !_isLoading,
                            textCapitalization: TextCapitalization.characters,
                            decoration: const InputDecoration(
                              labelText: 'Kode voucher',
                            ),
                            onSubmitted: _selectCode,
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () => _selectCode(_code.text),
                          child: const Text('Pakai'),
                        ),
                      ],
                    ),
                  ),
                  if ((_isLoading ? null : _selection.promoError)
                      case final error?)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                      child: Text(
                        error,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  Expanded(
                    child: _isLoading && _selection.promos.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : (() {
                            final applicable = _selection.promos.toList();
                            final eligible =
                                applicable
                                    .where(
                                      (promo) =>
                                          _eligibility(promo) == null &&
                                          promo.discountAmount(
                                                widget.servicePrice,
                                              ) >
                                              0,
                                    )
                                    .toList()
                                  ..sort((a, b) {
                                    final bySavings = b
                                        .discountAmount(widget.servicePrice)
                                        .compareTo(
                                          a.discountAmount(widget.servicePrice),
                                        );
                                    return bySavings == 0
                                        ? a.code.compareTo(b.code)
                                        : bySavings;
                                  });
                            final recommended = eligible.firstOrNull;
                            if (recommended != null) {
                              applicable.remove(recommended);
                              applicable.insert(0, recommended);
                            }
                            if (applicable.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Text(
                                    _selection.promoError != null
                                        ? 'Gagal memuat promo: ${_selection.promoError}'
                                        : _selection.promos.isEmpty
                                        ? 'Belum ada promo aktif saat ini.'
                                        : 'Belum ada promo untuk layanan ini.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.slate500,
                                      fontFamily: AppTheme.fontFamily,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              );
                            }
                            return ListView.separated(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
                              itemCount: applicable.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 14),
                              itemBuilder: (context, index) {
                                final promo = applicable[index];
                                final selected =
                                    _selection.appliedPromo?.code == promo.code;
                                return _PromoOptionCard(
                                  promo: promo,
                                  selected: selected,
                                  recommended: promo == recommended,
                                  unavailable: _eligibility(promo),
                                  savings: BookingController.formatRupiah(
                                    promo.discountAmount(widget.servicePrice),
                                  ),
                                  onTap: _eligibility(promo) != null
                                      ? null
                                      : () {
                                          if (selected) {
                                            setState(_selection.clearPromo);
                                          } else {
                                            _selectCode(promo.code);
                                          }
                                        },
                                );
                              },
                            );
                          })(),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_selection.isPromoApplied)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Hemat ${BookingController.formatRupiah(_selection.discountAmount(widget.servicePrice))}',
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          key: const ValueKey('confirm-promo'),
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.pop(
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
                    ],
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
    required this.recommended,
    required this.unavailable,
    required this.onTap,
  });

  final PromoModel promo;
  final bool selected;
  final String savings;
  final bool recommended;
  final String? unavailable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final formatMoney = BookingController.formatRupiah;
    final dates = MaterialLocalizations.of(context);
    final discount = promo.discountType == 'fixed'
        ? formatMoney((promo.discountValue ?? 0).round())
        : '${promo.discountValue ?? promo.discountPercent}%';
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
                      if (recommended)
                        Text('Direkomendasikan', style: textTheme.labelLarge),
                      const SizedBox(height: 6),
                      Text(promo.code, style: textTheme.labelLarge),
                      const SizedBox(height: 6),
                      Text(
                        [
                          'Diskon $discount',
                          if (promo.maxDiscount != null &&
                              promo.discountType == 'percentage')
                            'maks. ${formatMoney(promo.maxDiscount!)}',
                          if (promo.minPurchase > 0)
                            'min. ${formatMoney(promo.minPurchase)}',
                          if (promo.endsOn != null)
                            'hingga ${dates.formatMediumDate(promo.endsOn!)}',
                          if (promo.remainingQuota != null)
                            'sisa ${promo.remainingQuota}',
                          if (promo.perCustomerLimit != null)
                            'maks. ${promo.perCustomerLimit} per pelanggan',
                        ].join(' · '),
                        style: textTheme.bodySmall?.copyWith(fontSize: 13),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        unavailable ?? 'Hemat $savings',
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
