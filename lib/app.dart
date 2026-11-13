import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_routes.dart';
import 'shared/widgets/app_notice.dart';
import 'core/notifications/push_notifications.dart';
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
import 'features/home/data/customer_category_api.dart';
import 'features/booking/domain/models/booking_draft.dart';
import 'features/booking/domain/models/cleaning_address.dart';
import 'features/home/pages/home_page.dart';
import 'features/message/controllers/message_controller.dart';
import 'features/message/data/customer_notification_api.dart';
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
    this.pushNotifications,
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
  final PushNotifications? pushNotifications;

  @override
  State<CleanGoApp> createState() => _CleanGoAppState();
}

// Splash uses an unnamed home replacement; defer cold taps until it completes.
class _NotificationRouteObserver extends NavigatorObserver {
  _NotificationRouteObserver(this.onReady);
  final ValueChanged<bool> onReady;
  void _update(Route<dynamic>? route) {
    final name = route?.settings.name;
    onReady(route != null && name != Navigator.defaultRouteName &&
        name != AppRoutes.splash && name != AppRoutes.login &&
        name != AppRoutes.onboarding && name != AppRoutes.register);
  }
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => _update(route);
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) => _update(newRoute);
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => _update(previousRoute);
}

class _CleanGoAppState extends State<CleanGoApp> {
  late final MessageController _messageController;
  PushNotifications? _push;
  final _navigatorKey = GlobalKey<NavigatorState>();
  RemoteMessage? _pendingTap;
  late final _routeObserver = _NotificationRouteObserver((ready) {
    _notificationRouteReady = ready;
    _openPendingTap();
  });
  bool _notificationRouteReady = false;

  void _openPendingTap() {
    if (!_notificationRouteReady || _pendingTap == null || !mounted) return;
    final message = _pendingTap!;
    _pendingTap = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_openNotification(message));
    });
  }

  Future<void> _openNotification(RemoteMessage message) async {
    final context = _navigatorKey.currentContext;
    if (context == null) return;
    if (!await context.read<AuthSessionController>().hasSession()) {
      _pendingTap = message;
      return;
    }
    if (!context.mounted) return;
    final orders = context.read<OrderController>();
    final bookingId = message.data['bookingId']?.toString();
    if ((message.data['type'] == 'order' || message.data['type'] == 'payment') &&
        bookingId != null && RegExp(r'^[1-9][0-9]*$').hasMatch(bookingId)) {
      await orders.loadFromApi();
      if (!mounted) return;
      for (final order in orders.scheduledOrders) {
        if (order.backendBookingId == bookingId) {
          orders.selectScheduledOrder(order.orderNumber);
          _navigatorKey.currentState?.pushNamed(AppRoutes.orderStatus);
          return;
        }
      }
    }
    _navigatorKey.currentState?.pushNamed(AppRoutes.messages);
  }

  @override
  void initState() {
    super.initState();
    _messageController = MessageController(
      notificationApi: CustomerNotificationApi(
        tokenStorage: widget.tokenStorage,
      ),
    );
    _push = widget.pushNotifications;
    if (_push != null) {
      _push!.onInboxRefresh = () {
        if (!mounted) return;
        _messageController.loadFromApi();
      };
      _push!.onForegroundMessage = (message) {
        final context = _navigatorKey.currentContext;
        final body = message.notification?.body;
        if (context != null && body != null && body.isNotEmpty) {
          AppNotice.show(context, body, type: AppNoticeType.info);
        }
      };
      _push!.onNotificationTap = (message) {
        _pendingTap = message;
        _openPendingTap();
      };
    }
  }

  @override
  void dispose() {
    unawaited(_push?.dispose());
    _messageController.dispose();
    unawaited(widget.database.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppPreferences>.value(value: widget.preferences),
        Provider<TokenStorage>.value(value: widget.tokenStorage),
        ChangeNotifierProvider(
          create: (_) => AuthSessionController(
            widget.tokenStorage,
            pushNotifications: _push,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ServiceController(
            repository: widget.serviceRepository,
            preferences: widget.preferences,
            detailApi: CustomerServiceDetailApi(
              tokenStorage: widget.tokenStorage,
            ),
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
        ChangeNotifierProvider(
          create: (_) => ProfileController(tokenStorage: widget.tokenStorage),
        ),
        ChangeNotifierProvider(
          create: (_) => SupportController(tokenStorage: widget.tokenStorage),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeController(
            bannerApi: CustomerBannerApi(tokenStorage: widget.tokenStorage),
            categoryApi: CustomerCategoryApi(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderController(
            bookingApi: CustomerBookingApi(tokenStorage: widget.tokenStorage),
          ),
        ),
        ChangeNotifierProvider<MessageController>.value(
          value: _messageController,
        ),
      ],
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        navigatorObservers: [_routeObserver],
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
