import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../service/domain/models/service_model.dart';
import '../controllers/booking_controller.dart';
import '../widgets/booking_widgets.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({
    super.key,
    required this.service,
    this.onAddressTap,
    this.onContinue,
  });

  final ServiceModel service;
  final VoidCallback? onAddressTap;
  final VoidCallback? onContinue;

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  static const _sidePadding = 20.0;

  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    final bookingController = context.read<BookingController>();
    bookingController.startBooking(widget.service);
    _noteController = TextEditingController(text: bookingController.note);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
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
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.screenBackground,
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverToBoxAdapter(
                  child: SafeArea(
                    bottom: false,
                    child: _BookingHeader(
                      serviceName: widget.service.title,
                      onBack: () => Navigator.maybePop(context),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    _sidePadding,
                    8,
                    _sidePadding,
                    28,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate.fixed([
                      const _SectionTitle('Pilih Tanggal'),
                      const SizedBox(height: 12),
                      Selector<BookingController, DateTime>(
                        selector: (_, controller) => controller.selectedDate,
                        builder: (context, selectedDate, _) {
                          return BookingCalendarCard(
                            selectedDate: selectedDate,
                            onDateSelected: context
                                .read<BookingController>()
                                .selectDate,
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      const _SectionTitle('Pilih Jam Mulai'),
                      const SizedBox(height: 12),
                      Selector<BookingController, String>(
                        selector: (_, controller) => controller.selectedTime,
                        builder: (context, selectedTime, _) {
                          return BookingTimeSelector(
                            options: BookingController.availableTimes,
                            selectedTime: selectedTime,
                            onTimeSelected: context
                                .read<BookingController>()
                                .selectTime,
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      const _SectionTitle('Alamat Pembersihan'),
                      const SizedBox(height: 12),
                      Selector<BookingController, CleaningAddress>(
                        selector: (_, controller) => controller.address,
                        builder: (context, address, _) {
                          return CleaningAddressCard(
                            address: address,
                            onTap: _handleAddressTap,
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      const _SectionTitle('Catatan Tambahan'),
                      const SizedBox(height: 12),
                      _NoteField(
                        controller: _noteController,
                        onChanged: context.read<BookingController>().updateNote,
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _CheckoutBar(onPressed: _handleContinue),
      ),
    );
  }

  void _handleAddressTap() {
    widget.onAddressTap?.call();
  }

  void _handleContinue() {
    widget.onContinue?.call();
  }
}

class _BookingHeader extends StatelessWidget {
  const _BookingHeader({required this.serviceName, required this.onBack});

  final String serviceName;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CircularBackButton(onPressed: onBack),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Booking',
                    style: TextStyle(
                      color: AppColors.slate900,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      letterSpacing: -0.35,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    serviceName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.slate500,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
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
          dimension: 42,
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.slate900,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.5,
      ),
    );
  }
}

class _NoteField extends StatelessWidget {
  const _NoteField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      minLines: 4,
      maxLines: 6,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      style: const TextStyle(
        color: AppColors.slate600,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.6,
      ),
      decoration: InputDecoration(
        hintText: 'Ada anjing peliharaan di rumah, harap fokus bersihkan lantai atas...',
        hintStyle: const TextStyle(
          color: AppColors.slate500,
          fontSize: 13,
          fontWeight: FontWeight.w400,
          height: 1.6,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.slate100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            border: const Border(top: BorderSide(color: AppColors.slate100)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x140F172A),
                blurRadius: 18,
                offset: Offset(0, -5),
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
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: onPressed,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Lanjut ke Checkout',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
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
