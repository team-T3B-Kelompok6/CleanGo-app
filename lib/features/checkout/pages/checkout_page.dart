import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../booking/controllers/booking_controller.dart';
import '../domain/models/payment_method_model.dart';
import '../controllers/checkout_controller.dart';
import '../widgets/order_confirmation_dialog.dart';
import '../widgets/payment_method_icon.dart';
import 'payment_page.dart';
import 'payment_method_page.dart';

abstract final class _CheckoutTypography {
  static const String fontFamily = AppTheme.fontFamily;

  static const TextStyle pageTitle = TextStyle(
    color: AppColors.slate900,
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.2,
  );

  static const TextStyle pageSubtitle = TextStyle(
    color: AppColors.slate500,
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle cardTitle = TextStyle(
    color: AppColors.slate900,
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.1,
  );

  static const TextStyle sectionTitle = TextStyle(
    color: AppColors.slate900,
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle rowLabel = TextStyle(
    color: AppColors.slate500,
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  static const TextStyle rowValue = TextStyle(
    color: AppColors.slate900,
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );
}

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({
    this.onApplyPromo,
    this.onPaymentMethodTap,
    this.onPay,
    super.key,
  });

  final VoidCallback? onApplyPromo;
  final VoidCallback? onPaymentMethodTap;
  final VoidCallback? onPay;

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  PaymentMethodType _selectedPaymentMethod = PaymentMethodType.qris;
  final CheckoutController _checkoutController = CheckoutController();
  final TextEditingController _promoTextController = TextEditingController();

  @override
  void dispose() {
    _promoTextController.dispose();
    super.dispose();
  }

  void _applyPromo() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _checkoutController.applyPromo(_promoTextController.text);
    });
    widget.onApplyPromo?.call();
  }

  void _handlePromoChanged(String code) {
    if (_checkoutController.updatePromoInput(code)) {
      setState(() {});
    }
  }

  Future<void> _openPaymentMethods() async {
    if (widget.onPaymentMethodTap != null) {
      widget.onPaymentMethodTap!.call();
      return;
    }

    final selectedMethod = await Navigator.of(context).push<PaymentMethodType>(
      MaterialPageRoute<PaymentMethodType>(
        builder: (_) =>
            PaymentMethodPage(initialMethod: _selectedPaymentMethod),
      ),
    );

    if (!mounted || selectedMethod == null) {
      return;
    }

    setState(() => _selectedPaymentMethod = selectedMethod);
  }

  Future<void> _confirmOrder({
    required BookingController booking,
    required String formattedTotal,
  }) async {
    final service = booking.service;
    final address = booking.address;
    final note = booking.note.trim().isEmpty
        ? 'Tidak ada catatan'
        : booking.note.trim();
    final paymentMethod = paymentMethodByType(_selectedPaymentMethod);
    final isConfirmed = await showOrderConfirmationDialog(
      context,
      serviceName: service?.title ?? '-',
      schedule:
          '${booking.formattedSelectedDate}, ${booking.formattedSelectedTime}',
      address: '${address.label}\n${address.street}, ${address.city}',
      note: note,
      paymentMethod: paymentMethod.name,
      total: formattedTotal,
    );

    if (!mounted || !isConfirmed) {
      return;
    }

    widget.onPay?.call();
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => PaymentPage(
          method: paymentMethod,
          totalPayment: formattedTotal,
          servicePrice: booking.servicePriceValue,
          platformFee: BookingController.platformFee,
          discountAmount: _checkoutController.discountAmount(
            booking.servicePriceValue,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final booking = context.watch<BookingController>();
    final service = booking.service;
    final address = booking.address;
    final discountValue = _checkoutController.discountAmount(
      booking.servicePriceValue,
    );
    final totalPaymentValue = _checkoutController.totalPayment(
      servicePrice: booking.servicePriceValue,
      platformFee: BookingController.platformFee,
    );
    final formattedDiscount = BookingController.formatRupiah(discountValue);
    final formattedTotal = BookingController.formatRupiah(totalPaymentValue);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.screenBackground,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.screenBackground,
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: SafeArea(
                    bottom: false,
                    child: _CheckoutHeader(
                      onBack: () => Navigator.maybePop(context),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 32),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate.fixed([
                      _WorkAddressCard(
                        label: address.label,
                        address: '${address.street}, ${address.city}',
                      ),
                      const SizedBox(height: 14),
                      _OrderSummaryCard(
                        serviceName: service?.title ?? '-',
                        date: booking.formattedSelectedDate,
                        time: booking.formattedSelectedTime,
                        note: booking.note.trim().isEmpty
                            ? 'Tidak ada catatan'
                            : booking.note.trim(),
                      ),
                      const SizedBox(height: 14),
                      _PriceDetailsCard(
                        servicePrice: booking.formattedServicePrice,
                        platformFee: booking.formattedPlatformFee,
                        discount: _checkoutController.isPromoApplied
                            ? formattedDiscount
                            : null,
                        total: formattedTotal,
                      ),
                      const SizedBox(height: 20),
                      const _SectionLabel('Kode Promo / Voucher'),
                      const SizedBox(height: 8),
                      _PromoInput(
                        controller: _promoTextController,
                        errorText: _checkoutController.promoError,
                        successText: _checkoutController.promoSuccessMessage,
                        onChanged: _handlePromoChanged,
                        onApply: _applyPromo,
                      ),
                      const SizedBox(height: 20),
                      const _SectionLabel('Metode Pembayaran'),
                      const SizedBox(height: 8),
                      _PaymentMethodCard(
                        method: paymentMethodByType(_selectedPaymentMethod),
                        onTap: _openPaymentMethods,
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _PaymentBar(
          total: formattedTotal,
          onPressed: () =>
              _confirmOrder(booking: booking, formattedTotal: formattedTotal),
        ),
      ),
    );
  }
}

class _CheckoutHeader extends StatelessWidget {
  const _CheckoutHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Row(
        children: [
          _CircularBackButton(onPressed: onBack),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Checkout', style: _CheckoutTypography.pageTitle),
                SizedBox(height: 2),
                Text(
                  'Selesaikan pembayaran Anda',
                  style: _CheckoutTypography.pageSubtitle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircularBackButton extends StatelessWidget {
  const _CircularBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(side: BorderSide(color: AppColors.slate100)),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox.square(
          dimension: 38,
          child: Center(
            child: SvgPicture.asset(
              'assets/icons/detail_back.svg',
              width: 15,
              height: 15,
            ),
          ),
        ),
      ),
    );
  }
}

class _WorkAddressCard extends StatelessWidget {
  const _WorkAddressCard({required this.label, required this.address});

  final String label;
  final String address;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _MintIcon(icon: Icons.location_on_outlined),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ALAMAT PENGERJAAN',
                  style: TextStyle(
                    color: AppColors.slate400,
                    fontFamily: _CheckoutTypography.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1.55,
                    letterSpacing: 0.45,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.slate900,
                    fontFamily: _CheckoutTypography.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  address,
                  style: const TextStyle(
                    color: AppColors.slate500,
                    fontFamily: _CheckoutTypography.fontFamily,
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
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({
    required this.serviceName,
    required this.date,
    required this.time,
    required this.note,
  });

  final String serviceName;
  final String date;
  final String time;
  final String note;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ringkasan Pesanan', style: _CheckoutTypography.cardTitle),
          const SizedBox(height: 14),
          _SummaryRow(
            icon: Icons.cleaning_services_outlined,
            label: 'Layanan',
            value: serviceName,
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            icon: Icons.calendar_month_outlined,
            label: 'Tanggal',
            value: date,
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            icon: Icons.schedule_outlined,
            label: 'Waktu',
            value: time,
          ),
          const SizedBox(height: 10),
          _SummaryRow(icon: Icons.notes_rounded, label: 'Catatan', value: note),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 22,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Icon(icon, color: AppColors.primaryAction, size: 18),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 58,
            child: Text(
              label,
              textAlign: TextAlign.left,
              style: _CheckoutTypography.rowLabel,
            ),
          ),
          const SizedBox(
            width: 10,
            child: Text(
              ':',
              textAlign: TextAlign.center,
              style: _CheckoutTypography.rowLabel,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: _CheckoutTypography.rowValue,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceDetailsCard extends StatelessWidget {
  const _PriceDetailsCard({
    required this.servicePrice,
    required this.platformFee,
    required this.discount,
    required this.total,
  });

  final String servicePrice;
  final String platformFee;
  final String? discount;
  final String total;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Rincian Biaya', style: _CheckoutTypography.cardTitle),
          const SizedBox(height: 14),
          _PriceRow(label: 'Biaya Layanan', value: servicePrice),
          const SizedBox(height: 7),
          _PriceRow(label: 'Biaya Platform', value: platformFee),
          if (discount != null) ...[
            const SizedBox(height: 7),
            _PriceRow(
              label: 'Diskon Promo (35%)',
              value: '-$discount',
              discounted: true,
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: AppColors.slate100),
          ),
          _PriceRow(label: 'Total Pembayaran', value: total, emphasized: true),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.emphasized = false,
    this.discounted = false,
  });

  final String label;
  final String value;
  final bool emphasized;
  final bool discounted;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: emphasized ? AppColors.slate900 : AppColors.slate500,
              fontFamily: _CheckoutTypography.fontFamily,
              fontSize: emphasized ? 14 : 13,
              fontWeight: emphasized ? FontWeight.w600 : FontWeight.w400,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: TextStyle(
            color: emphasized || discounted
                ? AppColors.primaryAction
                : AppColors.slate600,
            fontFamily: _CheckoutTypography.fontFamily,
            fontSize: emphasized ? 20 : 14,
            fontWeight: emphasized ? FontWeight.w700 : FontWeight.w500,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: _CheckoutTypography.sectionTitle);
  }
}

class _PromoInput extends StatelessWidget {
  const _PromoInput({
    required this.controller,
    required this.errorText,
    required this.successText,
    required this.onChanged,
    required this.onApply,
  });

  final TextEditingController controller;
  final String? errorText;
  final String? successText;
  final ValueChanged<String> onChanged;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                onChanged: onChanged,
                onFieldSubmitted: (_) => onApply(),
                textCapitalization: TextCapitalization.characters,
                inputFormatters: const [_UpperCaseTextFormatter()],
                style: const TextStyle(
                  color: AppColors.slate600,
                  fontFamily: _CheckoutTypography.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Masukkan kode promo...',
                  hintStyle: const TextStyle(
                    color: AppColors.slate400,
                    fontFamily: _CheckoutTypography.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  prefixIcon: const Icon(
                    Icons.sell_outlined,
                    size: 18,
                    color: AppColors.slate400,
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 42),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.slate200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: onApply,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryAction,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 19),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Terapkan',
                  style: TextStyle(
                    fontFamily: _CheckoutTypography.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          _PromoStatusMessage(
            icon: Icons.error_outline_rounded,
            message: errorText!,
            color: const Color(0xFFDC2626),
          ),
        ] else if (successText != null) ...[
          const SizedBox(height: 6),
          _PromoStatusMessage(
            icon: Icons.check_circle_outline_rounded,
            message: successText!,
            color: AppColors.primaryAction,
          ),
        ],
      ],
    );
  }
}

class _PromoStatusMessage extends StatelessWidget {
  const _PromoStatusMessage({
    required this.icon,
    required this.message,
    required this.color,
  });

  final IconData icon;
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, size: 15, color: color),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontFamily: _CheckoutTypography.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpperCaseTextFormatter extends TextInputFormatter {
  const _UpperCaseTextFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
      composing: TextRange.empty,
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({required this.method, required this.onTap});

  final PaymentMethodModel method;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.slate100),
          ),
          child: Row(
            children: [
              PaymentMethodIcon(method: method, size: 36),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.name,
                      style: const TextStyle(
                        color: AppColors.slate900,
                        fontFamily: _CheckoutTypography.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                    Text(
                      method.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.slate400,
                        fontFamily: _CheckoutTypography.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SvgPicture.asset(
                'assets/icons/detail_chevron.svg',
                width: 5,
                height: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child});

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
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _MintIcon extends StatelessWidget {
  const _MintIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFFE8FAF7),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 15, color: AppColors.primaryAction),
    );
  }
}

class _PaymentBar extends StatelessWidget {
  const _PaymentBar({required this.total, required this.onPressed});

  final String total;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.slate100)),
        boxShadow: [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
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
                  onPressed: onPressed,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryAction,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Bayar $total',
                    style: const TextStyle(
                      fontFamily: _CheckoutTypography.fontFamily,
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
    );
  }
}
