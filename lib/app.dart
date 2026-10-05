import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/address/controllers/address_controller.dart';
import 'features/address/pages/address_list_page.dart';
import 'features/address/pages/add_address_page.dart';
import 'features/auth/pages/login_page.dart';
import 'features/auth/pages/register_page.dart';
import 'features/booking/controllers/booking_controller.dart';
import 'features/home/pages/home_page.dart';
import 'features/message/pages/messages_page.dart';
import 'features/onboarding/pages/onboarding_page.dart';
import 'features/onboarding/pages/splash_page.dart';
import 'features/order/controllers/order_controller.dart';
import 'features/order/pages/order_status_page.dart';
import 'features/order/pages/orders_page.dart';
import 'features/order/pages/review_rating_page.dart';
import 'features/profile/controllers/profile_controller.dart';
import 'features/profile/pages/change_password_page.dart';
import 'features/profile/pages/personal_data_page.dart';
import 'features/profile/pages/profile_page.dart';
import 'features/service/controllers/service_controller.dart';
import 'features/service/pages/service_list_page.dart';
import 'features/support/controllers/support_controller.dart';
import 'features/support/pages/help_center_page.dart';

class CleanGoApp extends StatelessWidget {
  const CleanGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ServiceController()),
        ChangeNotifierProvider(create: (_) => BookingController()),
        ChangeNotifierProvider(create: (_) => AddressController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => SupportController()),
        ChangeNotifierProvider(create: (_) => OrderController()),
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
        home: const SplashPage(),
        routes: {
          AppRoutes.splash: (_) => const SplashPage(),
          AppRoutes.onboarding: (_) => const OnboardingPage(),
          AppRoutes.login: (_) => const LoginPage(),
          AppRoutes.home: (_) => const HomePage(),
          AppRoutes.register: (_) => const RegisterPage(),
          AppRoutes.services: (_) => const ServiceListPage(),
          AppRoutes.orders: (_) => const OrdersPage(),
          AppRoutes.messages: (_) => const MessagesPage(),
          AppRoutes.profile: (_) => const ProfilePage(),
          AppRoutes.addressList: (_) => const AddressListPage(),
          AppRoutes.addAddress: (_) => const AddAddressPage(),
          AppRoutes.personalData: (_) => const PersonalDataPage(),
          AppRoutes.helpCenter: (_) => const HelpCenterPage(),
          AppRoutes.changePassword: (_) => const ChangePasswordPage(),
          AppRoutes.orderStatus: (_) => const OrderStatusPage(),
          AppRoutes.reviewRating: (_) => const ReviewRatingPage(),
        },
      ),
    );
  }
}
