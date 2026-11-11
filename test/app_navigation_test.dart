import 'package:cleango_app/core/constants/app_routes.dart';
import 'package:cleango_app/core/theme/app_theme.dart';
import 'package:cleango_app/features/address/controllers/address_controller.dart';
import 'package:cleango_app/features/booking/controllers/booking_controller.dart';
import 'package:cleango_app/features/booking/domain/models/cleaning_address.dart';
import 'package:cleango_app/features/booking/pages/booking_page.dart';
import 'package:cleango_app/features/checkout/pages/checkout_page.dart';
import 'package:cleango_app/features/home/pages/home_page.dart';
import 'package:cleango_app/features/message/pages/messages_page.dart';
import 'package:cleango_app/features/message/controllers/message_controller.dart';
import 'package:cleango_app/features/order/controllers/order_controller.dart';
import 'package:cleango_app/features/order/pages/orders_page.dart';
import 'package:cleango_app/features/profile/controllers/profile_controller.dart';
import 'package:cleango_app/features/profile/pages/profile_page.dart';
import 'package:cleango_app/core/storage/token_storage.dart';
import 'package:cleango_app/features/service/controllers/service_controller.dart';
import 'package:cleango_app/features/service/domain/models/service_model.dart';
import 'package:cleango_app/features/service/pages/service_detail_page.dart';
import 'package:cleango_app/features/service/pages/service_list_page.dart';
import 'package:cleango_app/features/service/widgets/service_card.dart';
import 'package:cleango_app/features/home/controllers/home_controller.dart';
import 'package:cleango_app/features/support/controllers/support_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _FakeTokenStorage implements TokenStorage {
  final _tokens = <String, String>{};
  final _expires = <String, DateTime>{};

  @override
  Future<void> writeAccessToken(String token) async => _tokens['access'] = token;

  @override
  Future<String?> readAccessToken() async => _tokens['access'];

  @override
  Future<void> writeRefreshToken(String token) async => _tokens['refresh'] = token;

  @override
  Future<String?> readRefreshToken() async => _tokens['refresh'];

  @override
  Future<void> writeExpiresAt(DateTime expiresAt) async => _expires['at'] = expiresAt;

  @override
  Future<DateTime?> readExpiresAt() async => _expires['at'];

  @override
  Future<void> clearSession() async {
    _tokens.clear();
    _expires.clear();
  }
}

void main() {
  Widget buildHome() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ServiceController(
            initialServices: [
              const ServiceModel(
                id: 'uji-layanan',
                title: 'Layanan Uji',
                description: 'Layanan sintetis untuk uji navigasi',
                duration: '±1 jam',
                price: 'Rp100.000',
                category: 'Rumah',
                imagePath: 'assets/images/service_detail_hero.jpeg',
                detail: ServiceDetailModel(
                  heroImagePath: 'assets/images/service_detail_hero.jpeg',
                  description: 'Deskripsi layanan untuk uji navigasi.',
                  rating: '5.0',
                  reviewCount: '0 ulasan',
                  satisfactionPercentage: 100,
                  benefits: <String>['Manfaat uji navigasi'],
                  reviews: <ServiceReviewModel>[],
                ),
              ),
            ],
          ),
        ),
        ChangeNotifierProvider(create: (_) => BookingController()),
        ChangeNotifierProvider(create: (_) => AddressController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => SupportController()),
        ChangeNotifierProvider(create: (_) => HomeController()),
        ChangeNotifierProvider(create: (_) => OrderController()),
        ChangeNotifierProvider(create: (_) => MessageController()),
        Provider<TokenStorage>(create: (_) => _FakeTokenStorage()),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const HomePage(),
        routes: {
          AppRoutes.services: (_) => const ServiceListPage(),
          AppRoutes.orders: (_) => const OrdersPage(),
          AppRoutes.messages: (_) => const MessagesPage(),
          AppRoutes.profile: (_) => const ProfilePage(),
        },
      ),
    );
  }

  Future<void> disposeApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  }

  Future<void> finishNavigation(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('opens the service, booking, and checkout flow from Home', (
    tester,
  ) async {
    await tester.pumpWidget(buildHome());

    await tester.tap(find.text('Layanan').last);
    await finishNavigation(tester);
    expect(find.byType(ServiceListPage), findsOneWidget);

    await tester.tap(find.byType(ServiceCard).first);
    await finishNavigation(tester);
    expect(find.byType(ServiceDetailPage), findsOneWidget);

    final orderNow = find.text('Pesan Sekarang');
    await tester.ensureVisible(orderNow);
    await tester.tap(orderNow);
    await finishNavigation(tester);
    expect(find.byType(BookingPage), findsOneWidget);

    final bookingController = tester.element(find.byType(BookingPage)).read<BookingController>()
      ..selectDate(DateTime.now().add(const Duration(days: 1)))
      ..selectTime('10:00');
    await tester.pump();

    await tester.tap(find.text('Lanjut ke Checkout'));
    await finishNavigation(tester);
    expect(find.byType(CheckoutPage), findsNothing);
    expect(find.text('Tambahkan alamat terlebih dahulu.'), findsOneWidget);

    bookingController.updateAddress(
      const CleaningAddress(
        label: 'Rumah',
        street: 'Jl. Uji No. 1',
        city: 'Kota Uji',
        landmark: '',
        customerName: 'Pemilik Uji',
        phoneNumber: '081200000001',
      ),
      addressId: 'uji-1',
    );
    await tester.pump();

    await tester.tap(find.text('Lanjut ke Checkout'));
    await finishNavigation(tester);
    expect(find.byType(CheckoutPage), findsOneWidget);

    await disposeApp(tester);
  });

  for (final destination in <(String, Type)>[
    ('Pesanan', OrdersPage),
    ('Notifikasi', MessagesPage),
    ('Akun', ProfilePage),
  ]) {
    testWidgets('opens ${destination.$1} from Home bottom navigation', (
      tester,
    ) async {
      await tester.pumpWidget(buildHome());

      await tester.tap(find.text(destination.$1).last);
      await finishNavigation(tester);

      expect(find.byType(destination.$2), findsOneWidget);
      await disposeApp(tester);
    });
  }
}
