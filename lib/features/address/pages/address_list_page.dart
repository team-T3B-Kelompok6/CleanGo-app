import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../booking/controllers/booking_controller.dart';
import '../controllers/address_controller.dart';
import '../domain/models/address_model.dart';
import '../widgets/address_card.dart';
import 'add_address_page.dart';
import 'edit_address_page.dart';

class AddressListPage extends StatefulWidget {
  const AddressListPage({
    super.key,
    this.isSelectionMode = true,
  });

  final bool isSelectionMode;

  @override
  State<AddressListPage> createState() => _AddressListPageState();
}

class _AddressListPageState extends State<AddressListPage> {
  static const double _sidePadding = 20.0;

  @override
  Widget build(BuildContext context) {
    final addressController = context.watch<AddressController>();
    final addresses = addressController.addresses;
    final selectedId = addressController.selectedAddressId;

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
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                      child: Row(
                        children: [
                          _CircularBackButton(
                            onPressed: () => Navigator.of(context).maybePop(),
                          ),
                          const SizedBox(width: 14),
                          const Text(
                            'Alamat Pembersihan',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              color: AppColors.slate900,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Subjudul: "Daftar alamat tersimpan"
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(_sidePadding, 4, _sidePadding, 16),
                      child: Text(
                        'Daftar alamat tersimpan',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          color: Color(0xFF64748B),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  // Daftar Alamat / Empty State
                  if (addresses.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE8FAF7),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.location_off_outlined,
                                  color: AppColors.primary,
                                  size: 34,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Belum Ada Alamat Tersimpan',
                                style: TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  color: AppColors.slate900,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Tambahkan alamat pembersihan Anda untuk kemudahan pemesanan.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  color: Color(0xFF64748B),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        _sidePadding,
                        0,
                        _sidePadding,
                        130, // Ruang untuk 2 tombol bottom bar
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final address = addresses[index];
                            final isSelected = address.id == selectedId;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: AddressCard(
                                address: address,
                                isSelected: isSelected,
                                onTap: () {
                                  addressController.selectAddress(address.id);
                                },
                                onEdit: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => EditAddressPage(address: address),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                          childCount: addresses.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        // Bottom Bar Persis Screenshot 1: Outlined "+ Tambahkan alamat" & Solid "Gunakan Alamat Ini"
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 16,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tombol 1: + Tambahkan alamat
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<AddressModel?>(
                            builder: (_) => AddAddressPage(
                              autoSetPrimary: addresses.isEmpty,
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: AppColors.primary, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Tambahkan alamat',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tombol 2: Gunakan Alamat Ini
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: addresses.isNotEmpty
                          ? () {
                              final active = addressController.selectedAddress ?? addresses.first;
                              context
                                  .read<BookingController>()
                                  .updateAddress(active.toCleaningAddress());
                              Navigator.of(context).pop(active);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Gunakan Alamat Ini',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
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
      shape: const CircleBorder(side: BorderSide(color: AppColors.slate200)),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: const SizedBox.square(
          dimension: 40,
          child: Center(
            child: Icon(
              Icons.arrow_back,
              size: 20,
              color: AppColors.slate900,
            ),
          ),
        ),
      ),
    );
  }
}
