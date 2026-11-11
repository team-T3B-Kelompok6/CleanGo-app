import 'package:cleango_app/features/home/data/home_catalog.dart';
import 'package:cleango_app/features/service/domain/models/service_model.dart';
import 'package:cleango_app/features/home/widgets/popular_service_card.dart';
import 'package:cleango_app/features/service/widgets/service_card.dart';
import 'package:cleango_app/features/service/widgets/service_icon.dart';
import 'package:cleango_app/shared/widgets/remote_or_asset_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cleango_app/features/home/pages/home_page.dart';
import 'package:cleango_app/features/home/controllers/home_controller.dart';
import 'package:cleango_app/features/message/controllers/message_controller.dart';
import 'package:cleango_app/features/message/domain/models/message_notification_model.dart';
import 'package:cleango_app/features/profile/controllers/profile_controller.dart';
import 'package:cleango_app/features/service/controllers/service_controller.dart';
import 'package:cleango_app/features/service/data/customer_service_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

ServiceModel _service(
  String id,
  String category, {
  String? rating,
  String? image,
  ServiceDetailModel? detail,
  int popularity = 0,
  int reviewCount = 0,
}) => ServiceModel(
  id: id,
  title: 'Layanan $id',
  description: 'Deskripsi $id',
  duration: '2 jam',
  price: 'Rp100.000',
  category: category,
  iconPath: 'assets/icons/$category.svg',
  imagePath: image,
  rating: rating,
  popularity: popularity,
  reviewCount: reviewCount,
  detail: detail,
);

void main() {
  testWidgets(
    'bell badge follows unread messages and opening inbox does not read them',
    (tester) async {
      final messages = MessageController(
        initialMessages: const [
          MessageNotificationModel(
            id: '1',
            title: 'Satu',
            description: '',
            timeLabel: '',
            category: MessageCategory.order,
            iconType: MessageIconType.confirmed,
            isUnread: true,
          ),
          MessageNotificationModel(
            id: '2',
            title: 'Dua',
            description: '',
            timeLabel: '',
            category: MessageCategory.order,
            iconType: MessageIconType.confirmed,
            isUnread: true,
          ),
        ],
      );
      addTearDown(messages.dispose);
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: messages),
            ChangeNotifierProvider(create: (_) => HomeController()),
            ChangeNotifierProvider(create: (_) => ProfileController()),
            ChangeNotifierProvider(create: (_) => ServiceController()),
          ],
          child: MaterialApp(
            home: const HomePage(),
            routes: {'/messages': (_) => const Scaffold(body: Text('Inbox'))},
          ),
        ),
      );
      await tester.pump();
      final badge = find.byKey(const ValueKey('notification-unread-badge'));
      expect(badge, findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Notifikasi'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Inbox'), findsOneWidget);
      expect(messages.unreadCount, 2);
      Navigator.of(tester.element(find.text('Inbox'))).pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      messages.markAsRead('1');
      await tester.pump();
      expect(badge, findsOneWidget);
      messages.markAsRead('2');
      await tester.pump();
      expect(badge, findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  group('HomeCatalog.categories', () {
    test('creates one entry per category, in catalogue order', () {
      final categories = HomeCatalog.categories([
        _service('1', 'Rumah'),
        _service('2', 'Rumah'),
        _service('3', 'Gudang'),
      ]);

      expect(categories.map((c) => c.label), ['Rumah', 'Gudang']);
      expect(categories.first.iconPath, 'assets/icons/Rumah.svg');
    });

    test('links each category to its first service', () {
      final categories = HomeCatalog.categories([
        _service('7', 'Rumah'),
        _service('9', 'Rumah'),
      ]);

      expect(categories.single.serviceId, '7');
    });

    test('ignores blank categories', () {
      final categories = HomeCatalog.categories([
        _service('1', '   '),
        _service('2', 'AC'),
      ]);

      expect(categories.map((c) => c.label), ['AC']);
    });

    test('returns an empty list for an empty catalogue', () {
      expect(HomeCatalog.categories(const []), isEmpty);
    });
  });

  group('HomeCatalog.popularServices', () {
    test('maps the catalogue into cards', () {
      final popular = HomeCatalog.popularServices([
        _service('1', 'Rumah', rating: '4.9'),
      ]);

      expect(popular.single.serviceId, '1');
      expect(popular.single.title, 'Layanan 1');
      expect(popular.single.price, 'Rp100.000');
      expect(popular.single.duration, '2 jam');
      expect(popular.single.rating, '4.9');
      expect(popular.single.iconPath, 'assets/icons/Rumah.svg');
    });

    test('limits the number of cards', () {
      final services = List.generate(8, (i) => _service('$i', 'Rumah'));

      expect(HomeCatalog.popularServices(services).length, 5);
      expect(HomeCatalog.popularServices(services, limit: 2).length, 2);
    });

    test('falls back to the icon when there is no image', () {
      final popular = HomeCatalog.popularServices([_service('1', 'AC')]);

      expect(popular.single.imagePath, 'assets/icons/AC.svg');
    });

    test('uses the same hero photo as the service detail', () {
      final popular = HomeCatalog.popularServices([
        _service(
          '1',
          'AC',
          image: 'assets/images/ac_service.jpeg',
          detail: const ServiceDetailModel(
            heroImagePath: 'assets/images/service_detail_hero.jpeg',
            description: '',
            rating: '-',
            reviewCount: '0',
            satisfactionPercentage: 0,
            benefits: [],
            reviews: [],
          ),
        ),
      ]);
      expect(
        popular.single.imagePath,
        'assets/images/service_detail_hero.jpeg',
      );
    });

    testWidgets('popular cards show a photo while service lists keep icons', (
      tester,
    ) async {
      const service = ServiceModel(
        id: '1',
        title: 'Cuci AC',
        description: 'Perawatan AC',
        duration: '1 jam',
        price: 'Rp100.000',
        category: 'AC',
        imagePath: 'assets/images/ac_service.jpeg',
        iconPath: 'assets/icons/service_ac.png',
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                PopularServiceCard(
                  width: 280,
                  service: HomeCatalog.popularServices([service]).single,
                ),
                ServiceCard(service: service, onTap: () {}),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(PopularServiceCard),
          matching: find.byType(RemoteOrAssetImage),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(ServiceCard),
          matching: find.byType(RemoteOrAssetImage),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byType(ServiceCard),
          matching: find.byType(ServiceIcon),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'pembukaan pertama Beranda menampilkan rating dan reviewCount asli tanpa detail',
      (tester) async {
        int detailCalls = 0;

        final fakeDetailApi = _FakeDetailApi(() => detailCalls++);

        final services = [
          ServiceModel(
            id: '7',
            title: 'Basic Home Cleaning',
            description: 'Pembersihan rutin',
            duration: '2 jam',
            price: 'Rp100.000',
            category: 'Rumah',
            rating: '4.5',
            reviewCount: 8,
            popularity: 100,
            iconPath: 'assets/icons/service_rumah.png',
          ),
        ];

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => HomeController()),
              ChangeNotifierProvider(create: (_) => ProfileController()),
              ChangeNotifierProvider(create: (_) => MessageController()),
              ChangeNotifierProvider(
                create: (_) => ServiceController(
                  initialServices: services,
                  detailApi: fakeDetailApi,
                ),
              ),
            ],
            child: MaterialApp(
              home: const HomePage(),
              routes: {'/messages': (_) => const Scaffold(body: Text('Inbox'))},
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('4.5'), findsOneWidget);
        expect(find.text('8'), findsOneWidget);

        expect(detailCalls, 0);

        await tester.pumpWidget(const SizedBox.shrink());
      },
    );

    test('prefers the service image when present', () {
      final popular = HomeCatalog.popularServices([
        _service('1', 'AC', image: 'assets/images/ac.jpeg'),
      ]);

      expect(popular.single.imagePath, 'assets/images/ac.jpeg');
    });

    test('mengurutkan salinan menurun menurut popularity sebelum take limit', () {
      final services = [
        _service('1', 'Rumah', popularity: 1),
        _service('2', 'Rumah', popularity: 5),
        _service('3', 'Rumah', popularity: 3),
      ];
      final popular = HomeCatalog.popularServices(services, limit: 2);

      expect(popular.map((p) => p.serviceId), ['2', '3']);
    });

    test('mempertahankan urutan masukan saat popularity sama (stabil)', () {
      final services = [
        _service('a', 'Rumah', popularity: 4),
        _service('b', 'Rumah', popularity: 4),
        _service('c', 'Rumah', popularity: 9),
      ];
      final popular = HomeCatalog.popularServices(services);

      expect(popular.map((p) => p.serviceId), ['c', 'a', 'b']);
    });

    test('tidak mengubah urutan daftar asli controller', () {
      final services = [
        _service('1', 'Rumah', popularity: 1),
        _service('2', 'Rumah', popularity: 5),
        _service('3', 'Rumah', popularity: 3),
      ];
      final awal = List.of(services.map((service) => service.id));

      HomeCatalog.popularServices(services, limit: 3);

      expect(services.map((service) => service.id), awal);
    });

    test('mengambil limit setelah diurutkan, bukan sebelum', () {
      final services = List.generate(6, (i) {
        return _service('$i', 'Rumah', popularity: i);
      });
      final popular = HomeCatalog.popularServices(services, limit: 3);

      expect(popular.map((p) => p.serviceId), ['5', '4', '3']);
    });

    test('membawa reviewCount asli ke kartu', () {
      final popular = HomeCatalog.popularServices([
        _service('1', 'Rumah', reviewCount: 7),
      ]);

      expect(popular.single.reviewCount, '7');
    });

    test('menampilkan - saat rating belum tersedia', () {
      final popular = HomeCatalog.popularServices([
        _service('1', 'Rumah'),
      ]);

      expect(popular.single.rating, '-');
    });
  });
}

class _FakeDetailApi extends CustomerServiceDetailApi {
  _FakeDetailApi(this._counter) : super();
  final int Function() _counter;

  @override
  Future<ServiceModel?> fetchDetail(String serviceId) async {
    _counter();
    return null;
  }
}
