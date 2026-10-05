import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class AddressTypeDropdown extends StatelessWidget {
  const AddressTypeDropdown({
    required this.value,
    required this.options,
    required this.onChanged,
    super.key,
  });

  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      menuMaxHeight: 320,
      borderRadius: BorderRadius.circular(16),
      icon: Container(
        width: 30,
        height: 30,
        decoration: const BoxDecoration(
          color: Color(0xFFF0FDFA),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.primary,
          size: 21,
        ),
      ),
      dropdownColor: Colors.white,
      style: const TextStyle(
        fontFamily: AppTheme.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.slate900,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.slate200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.slate200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
      selectedItemBuilder: (context) => options
          .map((type) => _AddressTypeOption(type: type, compact: true))
          .toList(growable: false),
      items: options
          .map(
            (type) => DropdownMenuItem<String>(
              value: type,
              child: _AddressTypeOption(type: type),
            ),
          )
          .toList(growable: false),
      onChanged: (newValue) {
        if (newValue != null) onChanged(newValue);
      },
    );
  }
}

class _AddressTypeOption extends StatelessWidget {
  const _AddressTypeOption({required this.type, this.compact = false});

  final String type;
  final bool compact;

  IconData get _icon {
    switch (type) {
      case 'Kantor':
        return Icons.business_outlined;
      case 'Apartemen':
        return Icons.apartment_outlined;
      case 'Kost':
        return Icons.meeting_room_outlined;
      default:
        return Icons.home_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: compact ? 28 : 32,
          height: compact ? 28 : 32,
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDFA),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(
            _icon,
            size: compact ? 17 : 18,
            color: AppColors.primaryAction,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(type)),
      ],
    );
  }
}
