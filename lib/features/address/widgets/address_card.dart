import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../domain/models/address_model.dart';

class AddressCard extends StatelessWidget {
  const AddressCard({
    super.key,
    required this.address,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
  });

  final AddressModel address;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  Color _getBadgeBackgroundColor(String type) {
    final lower = type.toLowerCase();
    if (lower.contains('rumah')) {
      return const Color(0xFFE8FAF7);
    } else if (lower.contains('kantor')) {
      return const Color(0xFFEEF2FF);
    } else if (lower.contains('apartemen')) {
      return const Color(0xFFFFF7ED);
    }
    return const Color(0xFFF1F5F9);
  }

  Color _getBadgeTextColor(String type) {
    final lower = type.toLowerCase();
    if (lower.contains('rumah')) {
      return AppColors.primary;
    } else if (lower.contains('kantor')) {
      return const Color(0xFF4338CA);
    } else if (lower.contains('apartemen')) {
      return const Color(0xFFC2410C);
    }
    return AppColors.slate600;
  }

  Color _getBadgeBorderColor(String type) {
    final lower = type.toLowerCase();
    if (lower.contains('rumah')) {
      return AppColors.primaryBorder;
    } else if (lower.contains('kantor')) {
      return const Color(0xFFE0E7FF);
    } else if (lower.contains('apartemen')) {
      return const Color(0xFFFFEDD5);
    }
    return AppColors.slate200;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.slate200,
              width: isSelected ? 1.8 : 1.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x060F172A),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Custom Radio Button + Title Alamat + Edit Button
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Radio Button persis seperti di screenshot
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : const Color(0xFFCBD5E1),
                        width: isSelected ? 6.5 : 2.0,
                      ),
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Judul Alamat
                  Expanded(
                    child: Text(
                      address.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: AppColors.slate900,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Tombol Edit Bulat
                  Material(
                    color: const Color(0xFFF1F5F9),
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: onEdit,
                      customBorder: const CircleBorder(),
                      child: const SizedBox.square(
                        dimension: 34,
                        child: Center(
                          child: Icon(
                            Icons.edit_outlined,
                            size: 16,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Konten bodi (indented sebaris dengan teks judul)
              Padding(
                padding: const EdgeInsets.only(left: 34, top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badges: [Tipe] [Utama jika ada]
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _getBadgeBackgroundColor(address.type),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _getBadgeBorderColor(address.type),
                            ),
                          ),
                          child: Text(
                            address.type,
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              color: _getBadgeTextColor(address.type),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (address.isPrimary) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8FAF7),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.primaryBorder),
                            ),
                            child: const Text(
                              'Utama',
                              style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Alamat Lengkap
                    Text(
                      address.fullAddress,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: Color(0xFF64748B),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Baris Telepon
                    Row(
                      children: [
                        const Icon(
                          Icons.phone_outlined,
                          size: 14,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          address.phoneNumber,
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            color: Color(0xFF64748B),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
