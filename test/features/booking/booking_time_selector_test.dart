import 'package:cleango_app/core/theme/app_theme.dart';
import 'package:cleango_app/features/address/controllers/address_controller.dart';

import 'dart:async';

import 'package:cleango_app/features/booking/controllers/booking_controller.dart';
import 'package:cleango_app/features/booking/data/customer_booking_api.dart';
import 'package:cleango_app/features/booking/pages/booking_page.dart';
import 'package:cleango_app/features/service/data/service_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _AvailabilityApi extends CustomerBookingApi {
  final requests = <Completer<List<BookingSlotInfo>>>[];
  final dates = <String>[];
  final services = <String?>[];

  @override
  Future<List<BookingSlotInfo>> availability({
    required String date,
    String? serviceId,
  }) {
    dates.add(date);
    services.add(serviceId);
    final request = Completer<List<BookingSlotInfo>>();
    requests.add(request);
    return request.future;
  }
}

void main() {
  testWidgets(
    '11:00 duplicate stays gray only on its own date, including refresh with unchanged selection',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(480, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final api = _AvailabilityApi();
      final service = ServiceData.services.first;
      final booking = BookingController(
        bookingApi: api,
        initialService: service,
      );
      addTearDown(booking.dispose);
      final tomorrow = DateUtils.dateOnly(DateTime.now())
          .add(const Duration(days: 1));
      booking.selectDate(tomorrow);
      api.requests[0].complete(const [
        BookingSlotInfo(time: '08:00', available: true),
        BookingSlotInfo(
          time: '11:00',
          available: false,
          reason: 'Anda sudah memesan layanan pada slot ini.',
        ),
      ]);
      await tester.pump();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: booking),
            ChangeNotifierProvider(create: (_) => AddressController()),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: BookingPage(service: service),
          ),
        ),
      );
      api.requests[1].complete(const [
        BookingSlotInfo(time: '08:00', available: true),
        BookingSlotInfo(
          time: '11:00',
          available: false,
          reason: 'Anda sudah memesan layanan pada slot ini.',
        ),
      ]);
      await tester.pumpAndSettle();
      expect(booking.selectedTime, '08:00');
      expect(api.services[1], service.id);
      expect(
        find.bySemanticsLabel(
          'Jam 11:00 tidak tersedia, Anda sudah memesan layanan pada slot ini.',
        ),
        findsOneWidget,
      );

      booking.selectDate(tomorrow.add(const Duration(days: 1)));
      await tester.pump();
      api.requests[2].complete(const [
        BookingSlotInfo(time: '08:00', available: true),
        BookingSlotInfo(time: '11:00', available: true),
      ]);
      await tester.pumpAndSettle();
      expect(
        api.dates[2],
        BookingController.isoDate(tomorrow.add(const Duration(days: 1))),
      );
      expect(find.bySemanticsLabel('Pilih jam 11:00'), findsOneWidget);
      await tester.tap(find.text('11:00'));
      await tester.pumpAndSettle();
      expect(booking.selectedTime, '11:00');

      booking.selectTime('08:00');
      await tester.pumpAndSettle();
      final refresh = booking.loadAvailability();
      await tester.pump();
      api.requests[3].complete(const [
        BookingSlotInfo(time: '08:00', available: true),
        BookingSlotInfo(
          time: '11:00',
          available: false,
          reason: 'Slot sudah penuh.',
        ),
      ]);
      await refresh;
      await tester.pumpAndSettle();
      expect(booking.selectedTime, '08:00');
      expect(
        find.bySemanticsLabel('Jam 11:00 tidak tersedia, Slot sudah penuh.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'reusing booking page for another service reloads its own availability',
    (tester) async {
      final api = _AvailabilityApi();
      final firstService = ServiceData.services.first;
      final nextService = ServiceData.services[1];
      final booking = BookingController(
        bookingApi: api,
        initialService: firstService,
      );
      addTearDown(booking.dispose);
      Widget page(service) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: booking),
          ChangeNotifierProvider(create: (_) => AddressController()),
        ],
        child: MaterialApp(home: BookingPage(service: service)),
      );
      await tester.pumpWidget(page(firstService));
      api.requests.single.complete(const [
        BookingSlotInfo(
          time: '11:00',
          available: false,
          reason: 'Anda sudah memesan layanan pada slot ini.',
        ),
      ]);
      await tester.pumpAndSettle();
      await tester.pumpWidget(page(nextService));
      await tester.pump();
      expect(booking.service?.id, nextService.id);
      expect(api.services, [firstService.id, nextService.id]);
      expect(booking.selectedTime, isEmpty);
      expect(booking.hasServerAvailability, isFalse);
      api.requests.last.complete(const [
        BookingSlotInfo(time: '11:00', available: true),
      ]);
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Pilih jam 11:00'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('booking arranges hourly slots into a selectable 3 by 3 grid', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(375, 812));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final service = ServiceData.services.first;
    final booking = BookingController()
      ..startBooking(service)
      ..selectDate(DateTime.now().add(const Duration(days: 1)));
    addTearDown(booking.dispose);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: booking),
          ChangeNotifierProvider(create: (_) => AddressController()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: BookingPage(service: service),
        ),
      ),
    );
    for (final slot in BookingController.availableTimes) {
      expect(find.text(slot), findsOneWidget);
    }
    expect(
      tester.getTopLeft(find.text('08:00')).dy,
      tester.getTopLeft(find.text('10:00')).dy,
    );
    expect(
      tester.getTopLeft(find.text('11:00')).dy,
      greaterThan(tester.getTopLeft(find.text('08:00')).dy),
    );
    expect(
      tester.getTopLeft(find.text('14:00')).dy,
      greaterThan(tester.getTopLeft(find.text('11:00')).dy),
    );
    await tester.tap(find.text('10:00'));
    await tester.pump();
    expect(booking.selectedTime, '10:00');
    expect(tester.takeException(), isNull);
  });
}
