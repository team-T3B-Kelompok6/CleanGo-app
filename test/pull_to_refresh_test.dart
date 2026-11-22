import 'package:cleango_app/features/address/controllers/address_controller.dart';
import 'package:cleango_app/features/address/pages/address_list_page.dart';
import 'package:cleango_app/features/booking/controllers/booking_controller.dart';
import 'package:cleango_app/features/home/controllers/home_controller.dart';
import 'package:cleango_app/features/home/pages/home_page.dart';
import 'package:cleango_app/features/message/controllers/message_controller.dart';
import 'package:cleango_app/features/message/pages/messages_page.dart';
import 'package:cleango_app/features/order/controllers/order_controller.dart';
import 'package:cleango_app/features/order/pages/orders_page.dart';
import 'package:cleango_app/features/profile/controllers/profile_controller.dart';
import 'package:cleango_app/features/profile/pages/profile_page.dart';
import 'package:cleango_app/features/service/controllers/service_controller.dart';
import 'package:cleango_app/features/service/pages/service_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _CountingHome extends HomeController {
  int calls = 0;

  @override
  Future<void> loadFromApi() {
    calls++;
    return Future<void>.value();
  }

  void emitChange() => notifyListeners();
}

class _CountingService extends ServiceController {
  int refreshes = 0;

  @override
  Future<bool> refreshServices() {
    refreshes++;
    return Future<bool>.value(true);
  }

  void emitChange() => notifyListeners();
}

class _CountingOrder extends OrderController {
  int calls = 0;

  @override
  Future<void> loadFromApi() {
    calls++;
    return Future<void>.value();
  }
}

class _CountingMessage extends MessageController {
  _CountingMessage({super.initialMessages});

  int calls = 0;

  @override
  Future<void> loadFromApi() {
    calls++;
    return Future<void>.value();
  }
}

class _CountingProfile extends ProfileController {
  int calls = 0;

  @override
  Future<void> loadFromApi() {
    calls++;
    return Future<void>.value();
  }

  void emitChange() => notifyListeners();
}

class _CountingAddress extends AddressController {
  int calls = 0;

  @override
  Future<void> loadFromApi() {
    calls++;
    return Future<void>.value();
  }

  void emitChange() => notifyListeners();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> dragDown(WidgetTester tester) async {
    await tester.drag(
      find.byType(RefreshIndicator).first,
      const Offset(0, 300),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('drag di HomePage memanggil HomeController.loadFromApi', (
    tester,
  ) async {
    final home = _CountingHome();
    final services = _CountingService();
    addTearDown(home.dispose);
    addTearDown(services.dispose);
    final notifications = <String>[];
    await tester.pumpWidget(
      NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          notifications.add(notification.runtimeType.toString());
          return false;
        },
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider<HomeController>.value(value: home),
            ChangeNotifierProvider<ServiceController>.value(value: services),
            ChangeNotifierProvider(create: (_) => MessageController()),
            ChangeNotifierProvider(create: (_) => ProfileController()),
          ],
          child: const MaterialApp(home: HomePage()),
        ),
      ),
    );
    await tester.pump();
    final beforeHome = home.calls;
    final beforeService = services.refreshes;
    await tester.pump();
    expect(home.calls, equals(beforeHome));
    expect(services.refreshes, equals(beforeService));
    for (int i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    final header = find.text('Halo, Pengguna');
    final yBefore = tester.getTopLeft(header).dy;
    // Tahan gesture saat refresh tertunda: konten halaman tidak ikut turun.
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(CustomScrollView)),
    );
    for (int i = 0; i < 3; i++) {
      await gesture.moveBy(const Offset(0, 100));
      await tester.pump();
    }
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      tester.getTopLeft(header).dy,
      yBefore,
      reason:
          'pixels='
          '${tester.state<ScrollableState>(find.byType(Scrollable).first).position.pixels} '
          'scrollY=${tester.getTopLeft(find.byType(CustomScrollView)).dy} '
          'headerRect=${tester.getRect(header)} '
          'viewPadding=${tester.view.padding} '
          'mqPadding=${MediaQuery.of(tester.element(find.byType(HomePage))).padding}',
    );
    await gesture.up();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(home.calls, beforeHome + 1);
    expect(services.refreshes, beforeService + 1);
    expect(find.byType(RefreshIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    expect(tester.getTopLeft(header).dy, yBefore);

    final afterDragHome = home.calls;
    final afterDragService = services.refreshes;
    home.emitChange();
    services.emitChange();
    await tester.pump();
    expect(home.calls, equals(afterDragHome));
    expect(services.refreshes, equals(afterDragService));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('drag di ServiceListPage memanggil refreshServices', (
    tester,
  ) async {
    final services = _CountingService();
    addTearDown(services.dispose);
    await tester.pumpWidget(
      ChangeNotifierProvider<ServiceController>.value(
        value: services,
        child: const MaterialApp(home: ServiceListPage()),
      ),
    );
    await tester.pump();
    final before = services.refreshes;
    await dragDown(tester);
    expect(services.refreshes, greaterThan(before));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('drag tab Terjadwal dan Riwayat memanggil loadFromApi', (
    tester,
  ) async {
    final orders = _CountingOrder();
    addTearDown(orders.dispose);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<OrderController>.value(value: orders),
          ChangeNotifierProvider(create: (_) => BookingController()),
          ChangeNotifierProvider(create: (_) => ProfileController()),
          ChangeNotifierProvider(create: (_) => ServiceController()),
        ],
        child: const MaterialApp(home: OrdersPage()),
      ),
    );
    await tester.pump();
    final beforeScheduled = orders.calls;
    await dragDown(tester);
    expect(orders.calls, greaterThan(beforeScheduled));

    await tester.tap(find.text('Riwayat'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    final beforeHistory = orders.calls;
    await dragDown(tester);
    expect(orders.calls, greaterThan(beforeHistory));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('drag di MessagesPage memanggil loadFromApi', (tester) async {
    final messages = _CountingMessage();
    addTearDown(messages.dispose);
    await tester.pumpWidget(
      ChangeNotifierProvider<MessageController>.value(
        value: messages,
        child: const MaterialApp(home: MessagesPage()),
      ),
    );
    await tester.pump();
    final before = messages.calls;
    await dragDown(tester);
    expect(messages.calls, greaterThan(before));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('drag di MessagesPage kosong tetap bisa memuat ulang', (
    tester,
  ) async {
    final messages = _CountingMessage(initialMessages: const []);
    addTearDown(messages.dispose);
    await tester.pumpWidget(
      ChangeNotifierProvider<MessageController>.value(
        value: messages,
        child: const MaterialApp(home: MessagesPage()),
      ),
    );
    await tester.pump();
    final before = messages.calls;
    await dragDown(tester);
    expect(messages.calls, greaterThan(before));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('drag di ProfilePage memanggil loadFromApi profil dan alamat', (
    tester,
  ) async {
    final profile = _CountingProfile();
    final addresses = _CountingAddress();
    addTearDown(profile.dispose);
    addTearDown(addresses.dispose);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ProfileController>.value(value: profile),
          ChangeNotifierProvider<AddressController>.value(value: addresses),
          ChangeNotifierProvider(create: (_) => BookingController()),
        ],
        child: const MaterialApp(home: ProfilePage()),
      ),
    );
    await tester.pump();
    final beforeProfile = profile.calls;
    final beforeAddress = addresses.calls;
    await dragDown(tester);
    expect(profile.calls, greaterThan(beforeProfile));
    expect(addresses.calls, greaterThan(beforeAddress));

    final afterDragProfile = profile.calls;
    final afterDragAddress = addresses.calls;
    profile.emitChange();
    addresses.emitChange();
    await tester.pump();
    expect(profile.calls, equals(afterDragProfile));
    expect(addresses.calls, equals(afterDragAddress));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('drag di AddressListPage memanggil loadFromApi', (tester) async {
    final addresses = _CountingAddress();
    addTearDown(addresses.dispose);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AddressController>.value(value: addresses),
          ChangeNotifierProvider(create: (_) => BookingController()),
        ],
        child: const MaterialApp(home: AddressListPage()),
      ),
    );
    await tester.pump();
    final before = addresses.calls;
    await dragDown(tester);
    expect(addresses.calls, greaterThan(before));
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
