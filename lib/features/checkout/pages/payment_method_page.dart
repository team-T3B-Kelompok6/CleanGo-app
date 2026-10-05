import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/models/payment_method_model.dart';
import '../widgets/payment_method_icon.dart';

class PaymentMethodPage extends StatefulWidget {
  const PaymentMethodPage({
    this.initialMethod = PaymentMethodType.qris,
    super.key,
  });

  final PaymentMethodType initialMethod;

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  late PaymentMethodType _selectedMethod;

  @override
  void initState() {
    super.initState();
    _selectedMethod = widget.initialMethod;
  }

  void _selectMethod(PaymentMethodType method) {
    if (_selectedMethod == method) {
      return;
    }

    setState(() => _selectedMethod = method);
  }

  void _goBack() {
    Navigator.pop(context, _selectedMethod);
  }

  void _selectAndGoBack(PaymentMethodType method) {
    _selectedMethod = method;
    Navigator.pop(context, method);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.screenBackground,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.screenBackground,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.screenBackground,
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                    child: Row(
                      children: [
                        _PaymentBackButton(onPressed: _goBack),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Metode Pembayaran',
                                style: TextStyle(
                                  color: AppColors.slate900,
                                  fontFamily: AppTheme.fontFamily,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  height: 1.25,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Pilih metode pembayaran Anda',
                                style: TextStyle(
                                  color: AppColors.slate500,
                                  fontFamily: AppTheme.fontFamily,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
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
                      padding: const EdgeInsets.fromLTRB(22, 6, 22, 32),
                      itemCount: paymentMethods.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: 22),
                      itemBuilder: (context, index) {
                        final method = paymentMethods[index];

                        return _PaymentOptionCard(
                          method: method,
                          isSelected: method.type == _selectedMethod,
                          onSelected: () => _selectMethod(method.type),
                          onConfirmed: () => _selectAndGoBack(method.type),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentBackButton extends StatelessWidget {
  const _PaymentBackButton({required this.onPressed});

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

class _PaymentOptionCard extends StatelessWidget {
  const _PaymentOptionCard({
    required this.method,
    required this.isSelected,
    required this.onSelected,
    required this.onConfirmed,
  });

  final PaymentMethodModel method;
  final bool isSelected;
  final VoidCallback onSelected;
  final VoidCallback onConfirmed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Pilih metode pembayaran ${method.name}',
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          if ((details.primaryVelocity ?? 0) < -180) {
            onSelected();
          }
        },
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onSelected,
            onDoubleTap: onConfirmed,
            borderRadius: BorderRadius.circular(15),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              height: 68,
              padding: EdgeInsets.fromLTRB(
                isSelected ? 13 : 14,
                12,
                isSelected ? 15 : 16,
                12,
              ),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFF0FDFA) : Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryAction
                      : AppColors.slate100,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? null
                    : const [
                        BoxShadow(
                          color: Color(0x080F172A),
                          blurRadius: 12,
                          offset: Offset(0, 3),
                        ),
                      ],
              ),
              child: Row(
                children: [
                  PaymentMethodIcon(method: method),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      method.name,
                      style: const TextStyle(
                        color: AppColors.slate900,
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: SvgPicture.asset(
                        'assets/icons/detail_check.svg',
                        width: 14,
                        height: 11,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
