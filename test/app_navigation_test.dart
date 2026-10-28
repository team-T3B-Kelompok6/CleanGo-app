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
import 'package:cleango_app/features/service/controllers/service_controller.dart';
import 'package:cleango_app/features/service/pages/service_detail_page.dart';
import 'package:cleango_app/features/service/pages/service_list_page.dart';
import 'package:cleango_app/features/service/widgets/service_card.dart';
import 'package:cleango_app/features/home/controllers/home_controller.dart';
import 'package:cleango_app/features/support/controllers/support_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  Widget buildHome() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ServiceController()),
        ChangeNotifierProvider(create: (_) => BookingController()),
        ChangeNotifierProvider(create: (_) => AddressController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => SupportController()),
        ChangeNotifierProvider(create: (_) => HomeController()),
        ChangeNotifierProvider(create: (_) => OrderController()),
        ChangeNotifierProvider(create: (_) => MessageController()),
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
