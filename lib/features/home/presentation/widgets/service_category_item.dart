import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_theme.dart';

class ServiceCategoryItem extends StatelessWidget {
  const ServiceCategoryItem({
    required this.iconPath,
    required this.label,
    this.accentText,
    this.onTap,
    super.key,
  });

  final String iconPath;
  final String label;
  final String? accentText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: accentText == null ? label : '$label $accentText',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryBorder.withValues(alpha: 0.6),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D000000),
                    offset: Offset(0, 1),
                    blurRadius: 1,
                  ),
                ],
              ),
              child: SizedBox.square(
                dimension: 24,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SvgPicture.asset(iconPath),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text.rich(
              TextSpan(
                text: label,
                children: accentText == null
                    ? const []
                    : [
                        TextSpan(
                          text: '\n$accentText',
                          style: const TextStyle(
                            color: AppColors.primaryAction,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.categoryText,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
