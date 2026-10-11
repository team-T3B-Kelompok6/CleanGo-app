import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../booking/controllers/booking_controller.dart';
import '../controllers/address_controller.dart';
import '../controllers/address_form_validator.dart';
import '../domain/models/address_model.dart';
import '../widgets/address_type_dropdown.dart';
import 'address_map_picker_page.dart';

class AddAddressPage extends StatefulWidget {
  const AddAddressPage({super.key, this.autoSetPrimary = false});

  final bool autoSetPrimary;

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  static const double _sidePadding = 20.0;
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _addressTitleController;
  late final TextEditingController _fullAddressController;
  late final TextEditingController _noteController;
  late final TextEditingController _contactNameController;
  late final TextEditingController _phoneController;

  String _selectedType = 'Rumah';
  final List<String> _typeOptions = [
    'Rumah',
    'Kantor',
    'Apartemen',
    'Kost',
    'Lainnya',
  ];

  bool _isSaving = false;
  double? _selectedLatitude;
  double? _selectedLongitude;

  @override
  void initState() {
    super.initState();
    _addressTitleController = TextEditingController();
    _fullAddressController = TextEditingController();
    _noteController = TextEditingController();
    _contactNameController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _addressTitleController.dispose();
    _fullAddressController.dispose();
    _noteController.dispose();
    _contactNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    final newAddress = AddressModel(
      id: 'addr-${DateTime.now().millisecondsSinceEpoch}',
      title: _addressTitleController.text.trim(),
      fullAddress: _fullAddressController.text.trim(),
      note: _noteController.text.trim(),
      type: _selectedType,
      contactName: _contactNameController.text.trim(),
      phoneNumber: AddressFormValidator.formatPhone(_phoneController.text),
      isPrimary: widget.autoSetPrimary,
      latitude: _selectedLatitude,
      longitude: _selectedLongitude,
    );

    final addressController = context.read<AddressController>();
    addressController.addAddress(newAddress);

    if (widget.autoSetPrimary) {
      context.read<BookingController>().updateAddress(
        newAddress.toCleaningAddress(),
      );
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alamat baru berhasil ditambahkan!'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.of(context).pop(newAddress);
  }

  Future<void> _pickFromMap() async {
    FocusScope.of(context).unfocus();
    final selection = await Navigator.of(context).push<AddressMapSelection>(
      MaterialPageRoute<AddressMapSelection>(
        builder: (_) => const AddressMapPickerPage(),
      ),
    );
    if (selection == null || !mounted) return;

    setState(() {
      _selectedLatitude = selection.position.latitude;
      _selectedLongitude = selection.position.longitude;
      _addressTitleController.text = selection.shortLabel;
      _fullAddressController.text = selection.addressText;
    });
    _formKey.currentState?.validate();
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
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                      child: Row(
                        children: [
                          _CircularBackButton(
                            onPressed: () => Navigator.of(context).maybePop(),
                          ),
                          const SizedBox(width: 14),
                          const Text(
                            'Tambahkan alamat baru',
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

                  // Form Fields
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      _sidePadding,
                      0,
                      _sidePadding,
                      120,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Alamat *
                            _buildLabel('Alamat', isRequired: true),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _addressTitleController,
                              style: const TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 14,
                                color: AppColors.slate900,
                              ),
                              decoration: _buildInputDecoration(
                                hintText: 'Masukkan alamat Anda',
                                suffixIcon: IconButton(
                                  tooltip: 'Pilih dari peta',
                                  onPressed: _pickFromMap,
                                  icon: const Icon(
                                    Icons.map_outlined,
                                    color: AppColors.primary,
                                    size: 21,
                                  ),
                                ),
                              ),
                              validator: AddressFormValidator.address,
                            ),
                            const SizedBox(height: 12),

                            // Tombol "Pilih dari peta"
                            Material(
                              color: const Color(0xFFF2FBF9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                  color: Color(0xFFA7F3D0),
                                ),
                              ),
                              child: InkWell(
                                onTap: _pickFromMap,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: double.infinity,
                                  height: 44,
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        size: 18,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _selectedLatitude == null
                                            ? 'Pilih dari peta'
                                            : 'Ubah titik di peta',
                                        style: const TextStyle(
                                          fontFamily: AppTheme.fontFamily,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // 2. Alamat lengkap *
                            _buildLabel('Alamat lengkap', isRequired: true),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _fullAddressController,
                              maxLines: 3,
                              style: const TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 14,
                                color: AppColors.slate900,
                              ),
                              decoration: _buildInputDecoration(
                                hintText: 'Nama jalan, nomor, kecamatan, kota, dan kode pos',
                              ),
                              validator: AddressFormValidator.fullAddress,
                            ),
                            const SizedBox(height: 20),

                            // 3. Catatan
                            _buildLabel('Catatan'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _noteController,
                              style: const TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 14,
                                color: AppColors.slate900,
                              ),
                              decoration: _buildInputDecoration(
                                hintText:
                                    'Patokan pagar hitam sebelah minimarket',
                              ),
                            ),
                            const SizedBox(height: 20),

                            // 4. Tipe bangunan
                            _buildLabel('Tipe bangunan'),
                            const SizedBox(height: 8),
                            AddressTypeDropdown(
                              value: _selectedType,
                              options: _typeOptions,
                              onChanged: (value) =>
                                  setState(() => _selectedType = value),
                            ),
                            const SizedBox(height: 20),

                            // 5. Nama kontak *
                            _buildLabel('Nama kontak', isRequired: true),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _contactNameController,
                              style: const TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 14,
                                color: AppColors.slate900,
                              ),
                              decoration: _buildInputDecoration(
                                hintText: 'Masukkan nama penerima',
                              ),
                              validator: AddressFormValidator.contactName,
                            ),
                            const SizedBox(height: 20),

                            // 6. Nomor telepon * (dengan bendera Indonesia & +62)
                            _buildLabel('Nomor telepon', isRequired: true),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(13),
                              ],
                              style: const TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 14,
                                color: AppColors.slate900,
                              ),
                              decoration: _buildInputDecoration(
                                hintText: 'Masukkan nomor telepon Anda',
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 14,
                                    right: 10,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildIndonesiaFlag(),
                                      const SizedBox(width: 8),
                                      const Text(
                                        '+62',
                                        style: TextStyle(
                                          fontFamily: AppTheme.fontFamily,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.slate900,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const SizedBox(
                                        height: 24,
                                        child: VerticalDivider(
                                          width: 1,
                                          color: Color(0xFFE2E8F0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              validator: AddressFormValidator.phone,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Bottom Button Persis Screenshot 2: "Tambahkan alamat baru" dengan icon plus dalam lingkaran
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
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle_outline, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Tambahkan alamat baru',
                              style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
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

  Widget _buildLabel(String title, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        text: title,
        style: const TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.slate900,
        ),
        children: [
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIndonesiaFlag() {
    return Container(
      width: 22,
      height: 14,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.5),
      ),
      child: Column(
        children: [
          Expanded(child: Container(color: const Color(0xFFEF4444))),
          Expanded(child: Container(color: Colors.white)),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    String? hintText,
    Widget? suffixIcon,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        fontFamily: AppTheme.fontFamily,
        fontSize: 14,
        color: Color(0xFF94A3B8),
      ),
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon,
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
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
            child: Icon(Icons.arrow_back, size: 20, color: AppColors.slate900),
          ),
        ),
      ),
    );
  }
}
