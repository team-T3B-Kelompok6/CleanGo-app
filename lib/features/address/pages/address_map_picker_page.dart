import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_theme.dart';
import '../controllers/reverse_geocoding_controller.dart';

class AddressMapSelection {
  const AddressMapSelection({
    required this.position,
    required this.shortLabel,
    required this.addressText,
  });

  final LatLng position;
  final String shortLabel;
  final String addressText;
}

class AddressMapPickerPage extends StatefulWidget {
  const AddressMapPickerPage({
    this.initialPosition = const LatLng(-7.9526, 112.6137),
    super.key,
  });

  final LatLng initialPosition;

  @override
  State<AddressMapPickerPage> createState() => _AddressMapPickerPageState();
}

class _AddressMapPickerPageState extends State<AddressMapPickerPage> {
  late LatLng _selectedPosition;
  final ReverseGeocodingController _geocodingController =
      ReverseGeocodingController();
  bool _isResolvingAddress = false;
  String? _addressError;

  @override
  void initState() {
    super.initState();
    _selectedPosition = widget.initialPosition;
  }

  @override
  void dispose() {
    _geocodingController.dispose();
    super.dispose();
  }

  Future<void> _confirmLocation() async {
    if (_isResolvingAddress) return;
    setState(() {
      _isResolvingAddress = true;
      _addressError = null;
    });
    try {
      final address = await _geocodingController.resolve(_selectedPosition);
      if (!mounted) return;
      Navigator.of(context).pop(
        AddressMapSelection(
          position: _selectedPosition,
          shortLabel: address.shortAddress,
          addressText: address.fullAddress,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isResolvingAddress = false;
        _addressError = 'Alamat belum ditemukan. Periksa internet atau pilih titik yang lebih dekat dengan jalan.';
      });
    }
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
          child: Column(
            children: [
              _MapHeader(onBack: () => Navigator.of(context).pop()),
              Expanded(
                child: Stack(
                  children: [
                    FlutterMap(
                      options: MapOptions(
                        initialCenter: _selectedPosition,
                        initialZoom: 16,
                        onTap: (_, position) {
                          setState(() {
                            _selectedPosition = position;
                            _addressError = null;
                          });
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.cleango.app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _selectedPosition,
                              width: 52,
                              height: 52,
                              alignment: Alignment.topCenter,
                              child: const Icon(
                                Icons.location_on_rounded,
                                color: AppColors.primaryAction,
                                size: 48,
                                shadows: [
                                  Shadow(
                                    color: Color(0x40000000),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const RichAttributionWidget(
                          attributions: [
                            TextSourceAttribution('OpenStreetMap contributors'),
                          ],
                        ),
                      ],
                    ),
                    const Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: _MapHint(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x160F172A),
                  blurRadius: 18,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Titik alamat dipilih',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: AppColors.slate900,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _addressError ?? 'Alamat lengkap akan dicari setelah Anda menggunakan titik ini.',
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: AppColors.slate500,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: _isResolvingAddress ? null : _confirmLocation,
                    icon: _isResolvingAddress
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_circle_outline_rounded),
                    label: Text(
                      _isResolvingAddress
                          ? 'Mencari alamat...'
                          : 'Gunakan titik ini',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
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
    );
  }
}

class _MapHeader extends StatelessWidget {
  const _MapHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      child: Row(
        children: [
          Material(
            color: Colors.white,
            shape: const CircleBorder(
              side: BorderSide(color: AppColors.slate200),
            ),
            child: InkWell(
              onTap: onBack,
              customBorder: const CircleBorder(),
              child: const SizedBox.square(
                dimension: 40,
                child: Icon(Icons.arrow_back_rounded, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pilih dari Peta',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: AppColors.slate900,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Ketuk peta untuk memindahkan pin',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: AppColors.slate500,
                    fontSize: 12,
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

class _MapHint extends StatelessWidget {
  const _MapHint();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color(0x19000000), blurRadius: 12)],
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            Icon(Icons.touch_app_outlined, color: AppColors.primary, size: 19),
            SizedBox(width: 9),
            Expanded(
              child: Text(
                'Geser peta lalu ketuk lokasi rumah Anda.',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  color: AppColors.slate600,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
