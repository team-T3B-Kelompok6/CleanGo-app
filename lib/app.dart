import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_routes.dart';
import 'core/database/app_database.dart';
import 'core/storage/app_preferences.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/address/controllers/address_controller.dart';
import 'features/address/data/address_repository.dart';
import 'features/address/domain/models/address_model.dart';
import 'features/address/pages/address_list_page.dart';
import 'features/address/pages/add_address_page.dart';
import 'features/auth/pages/login_page.dart';
import 'features/auth/pages/register_page.dart';
import 'features/auth/controllers/auth_session_controller.dart';
import 'features/booking/controllers/booking_controller.dart';
import 'features/booking/data/booking_draft_repository.dart';
import 'features/booking/data/customer_booking_api.dart';
import 'features/home/controllers/home_controller.dart';
import 'features/home/data/customer_banner_api.dart';
import 'features/booking/domain/models/booking_draft.dart';
import 'features/booking/domain/models/cleaning_address.dart';
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
import 'features/service/data/customer_service_remote_data_source.dart';
import 'features/service/data/service_repository.dart';
import 'features/service/domain/models/service_model.dart';
import 'features/service/pages/service_list_page.dart';
import 'features/support/controllers/support_controller.dart';
import 'features/support/pages/help_center_page.dart';

class CleanGoApp extends StatefulWidget {
  const CleanGoApp({
    required this.database,
    required this.addressRepository,
    required this.initialAddresses,
    required this.serviceRepository,
    required this.initialServices,
    required this.bookingRepository,
    required this.preferences,
    required this.tokenStorage,
    this.initialServiceFilter,
    this.initialBookingDraft,
    this.initialBookingService,
    this.initialBookingAddress,
    super.key,
  });

  final AppDatabase database;
  final AddressRepository addressRepository;
  final List<AddressModel> initialAddresses;
  final ServiceRepository serviceRepository;
  final List<ServiceModel> initialServices;
  final String? initialServiceFilter;
  final BookingDraftRepository bookingRepository;
  final BookingDraft? initialBookingDraft;
  final ServiceModel? initialBookingService;
  final CleaningAddress? initialBookingAddress;
  final AppPreferences preferences;
  final TokenStorage tokenStorage;

  @override
  State<CleanGoApp> createState() => _CleanGoAppState();
}

class _CleanGoAppState extends State<CleanGoApp> {
  @override
  void dispose() {
    unawaited(widget.database.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppPreferences>.value(value: widget.preferences),
        ChangeNotifierProvider(
          create: (_) => AuthSessionController(widget.tokenStorage),
        ),
        ChangeNotifierProvider(
          create: (_) => ServiceController(
            repository: widget.serviceRepository,
            preferences: widget.preferences,
            detailApi: CustomerServiceDetailApi(tokenStorage: widget.tokenStorage),
            initialServices: widget.initialServices,
            initialFilter: widget.initialServiceFilter,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => BookingController(
            repository: widget.bookingRepository,
            initialDraft: widget.initialBookingDraft,
            initialService: widget.initialBookingService,
            initialAddress: widget.initialBookingAddress,
            bookingApi: CustomerBookingApi(tokenStorage: widget.tokenStorage),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AddressController(
            repository: widget.addressRepository,
            initialAddresses: widget.initialAddresses,
            tokenStorage: widget.tokenStorage,
          ),
        ),
        ChangeNotifierProvider(create: (_) => ProfileController(tokenStorage: widget.tokenStorage)),
        ChangeNotifierProvider(
          create: (_) => SupportController(tokenStorage: widget.tokenStorage),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeController(
            bannerApi: CustomerBannerApi(tokenStorage: widget.tokenStorage),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderController(
            bookingApi: CustomerBookingApi(tokenStorage: widget.tokenStorage),
          ),
        ),
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
