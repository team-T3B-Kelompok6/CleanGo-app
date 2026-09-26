import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/service/presentation/controllers/service_controller.dart';
import 'features/service/presentation/pages/service_list_page.dart';

class CleanGoApp extends StatelessWidget {
  const CleanGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ServiceController(),
      child: MaterialApp(
        title: 'CleanGo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const HomePage(),
        routes: {AppRoutes.services: (_) => const ServiceListPage()},
      ),
    );
  }
}
