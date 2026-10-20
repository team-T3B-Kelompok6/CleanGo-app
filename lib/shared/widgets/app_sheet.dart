import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class AppSheet extends StatelessWidget {
  const AppSheet({
    required this.title,
    required this.child,
    this.subtitle,
    this.actions,
    this.scrollController,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? actions;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 480,
              maxHeight:
                  (MediaQuery.sizeOf(context).height - bottomInset) * 0.9,
            ),
            child: Material(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(top: 10, bottom: 8),
                      decoration: BoxDecoration(
                        color: AppColors.slate200,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Semantics(
                              namesRoute: true,
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  color: AppColors.slate900,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Tutup',
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded, size: 22),
                          color: AppColors.slate500,
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (subtitle != null) ...[
                            Text(
                              subtitle!,
                              style: const TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                color: AppColors.slate600,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                          child,
                        ],
                      ),
                    ),
                  ),
                  if (actions != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: actions,
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
