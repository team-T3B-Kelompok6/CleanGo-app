import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/booking/presentation/controllers/booking_controller.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/message/presentation/pages/messages_page.dart';
import 'features/order/presentation/pages/orders_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/service/presentation/controllers/service_controller.dart';
import 'features/service/presentation/pages/service_list_page.dart';

class CleanGoApp extends StatelessWidget {
  const CleanGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ServiceController()),
        ChangeNotifierProvider(create: (_) => BookingController()),
      ],
      child: MaterialApp(
        title: 'CleanGo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        builder: (context, child) {
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: const LoginPage(),
        routes: {
          AppRoutes.login: (_) => const LoginPage(),
          AppRoutes.home: (_) => const HomePage(),
          AppRoutes.register: (_) => const RegisterPage(),
          AppRoutes.services: (_) => const ServiceListPage(),
          AppRoutes.orders: (_) => const OrdersPage(),
          AppRoutes.messages: (_) => const MessagesPage(),
          AppRoutes.profile: (_) => const ProfilePage(),
        },
      ),
    );
  }
}
