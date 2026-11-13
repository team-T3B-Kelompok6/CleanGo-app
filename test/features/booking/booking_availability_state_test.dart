import 'dart:async';

import 'package:cleango_app/features/booking/controllers/booking_controller.dart';
import 'package:cleango_app/features/booking/data/customer_booking_api.dart';
import 'package:cleango_app/features/booking/widgets/booking_widgets.dart';
import 'package:cleango_app/features/service/data/service_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

class _QueuedApi extends CustomerBookingApi {
  final requests = <Completer<List<BookingSlotInfo>>>[];
  final services = <String?>[];
  final creates = <(String, String)>[];

  @override
  Future<CreatedBooking> create({
    required String serviceId,
    required String date,
    required String time,
    String? addressId,
    String notes = '',
  }) async {
    creates.add((serviceId, time));
    return const CreatedBooking(id: '42', code: 'CG-TEST', status: 'confirmed', totalAmount: 105000);
  }

  @override
  Future<List<BookingSlotInfo>> availability({
    required String date,
    String? serviceId,
  }) {
    services.add(serviceId);
    final response = Completer<List<BookingSlotInfo>>();
    requests.add(response);
    return response.future;
  }
}

const open = [BookingSlotInfo(time: '10:00', available: true)];
const closed = [
  BookingSlotInfo(time: '10:00', available: false, reason: 'Slot sudah penuh.'),
];

void main() {
  test('latest date wins; stale success and failure cannot clear loading or replace state', () async {
    final api = _QueuedApi();
    final booking = BookingController(
      bookingApi: api,
      initialService: ServiceData.services.first,
    );
    addTearDown(booking.dispose);
    final first = booking.loadAvailability();
    booking.selectDate(DateTime.now().add(const Duration(days: 1)));
    expect(booking.availabilityLoading, isTrue);
    expect(booking.isTimeAvailable('10:00'), isFalse);
    api.requests[0].complete(open);
    await first;
    expect(booking.availabilityLoading, isTrue);
    expect(booking.hasServerAvailability, isFalse);
    api.requests[1].complete(open);
    await Future<void>.delayed(Duration.zero);
    expect(booking.selectedTime, '10:00');

    final stale = booking.loadAvailability();
    final latest = booking.loadAvailability();
    api.requests[3].complete(closed);
    await latest;
    api.requests[2].completeError(StateError('stale failure'));
    await stale;
    expect(booking.hasServerAvailability, isTrue);
    expect(booking.selectedTime, isEmpty);
    expect(booking.slots, isEmpty);
    expect(booking.availabilityError, isNull);
    expect(booking.validateSchedule(), isNotNull);
  });

  test('service changes invalidate old response; empty board never falls back to selectable times', () async {
    final api = _QueuedApi();
    final booking = BookingController(
      bookingApi: api,
      initialService: ServiceData.services.first,
    );
    addTearDown(booking.dispose);
    final old = booking.loadAvailability();
    booking.startBooking(ServiceData.services[1]);
    api.requests[0].complete(open);
    await old;
    expect(booking.availabilityLoading, isTrue);
    expect(api.services[1], ServiceData.services[1].id);
    api.requests[1].complete([]);
    await Future<void>.delayed(Duration.zero);
    expect(booking.hasServerAvailability, isTrue);
    expect(booking.slots, isEmpty);
    expect(booking.selectedTime, isEmpty);
    expect(booking.isTimeAvailable('10:00'), isFalse);
  });

  test('service switch cannot submit stale time; duplicate board disables only that service', () async {
    final api = _QueuedApi();
    final firstService = ServiceData.services.first;
    final secondService = ServiceData.services[1];
    final booking = BookingController(bookingApi: api, initialService: firstService);
    addTearDown(booking.dispose);
    final initial = booking.loadAvailability();
    api.requests[0].complete(open);
    await initial;
    await booking.createBookingOnServer();

    final duplicate = booking.loadAvailability();
    api.requests[1].complete(const [BookingSlotInfo(
      time: '10:00', available: false,
      reason: 'Anda sudah memesan layanan pada slot ini.',
    )]);
    await duplicate;
    expect(booking.isTimeAvailable('10:00'), isFalse);
    expect(booking.slotReason('10:00'), contains('sudah memesan'));
    await expectLater(booking.createBookingOnServer(), throwsStateError);

    booking.startBooking(secondService);
    expect(booking.selectedTime, isEmpty);
    await expectLater(booking.createBookingOnServer(), throwsStateError);
    expect(api.creates, [(firstService.id, '10:00')]);
    api.requests[2].complete(open);
    await Future<void>.delayed(Duration.zero);
    await booking.createBookingOnServer();
    expect(api.creates.last, (secondService.id, '10:00'));
  });

  test('refresh disables old selection; failure blocks until retry succeeds; dispose ignores late response', () async {
    final api = _QueuedApi();
    final booking = BookingController(bookingApi: api);
    final initial = booking.loadAvailability();
    api.requests[0].complete(open);
    await initial;
    final refresh = booking.loadAvailability();
    expect(booking.isTimeAvailable('10:00'), isFalse);
    expect(booking.validateSchedule(), isNotNull);
    api.requests[1].completeError(StateError('offline'));
    await refresh;
    expect(booking.selectedTime, isEmpty);
    expect(booking.hasServerAvailability, isFalse);
    final retry = booking.loadAvailability();
    api.requests[2].complete(open);
    await retry;
    expect(booking.validateSchedule(), isNull);
    final late = booking.loadAvailability();
    booking.dispose();
    api.requests[3].complete(closed);
    await late;
    await booking.loadAvailability();
    expect(api.requests, hasLength(4));
  });

  testWidgets(
    'closed selected slot is faded, disabled, untappable and has no semantic tap action',
    (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        final selected = <String>[];
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BookingTimeSelector(
                options: const ['10:00', '11:00'],
                selectedTime: '10:00',
                onTimeSelected: selected.add,
                isTimeAvailable: (time) => time == '11:00',
                slotReason: (_) => 'Slot sudah penuh.',
              ),
            ),
          ),
        );
        final disabled = tester.getSemantics(
          find.bySemanticsLabel('Jam 10:00 tidak tersedia, Slot sudah penuh.'),
        );
        expect(
          disabled.getSemanticsData().hasFlag(SemanticsFlag.isEnabled),
          isFalse,
        );
        expect(
          disabled.getSemanticsData().hasFlag(SemanticsFlag.isSelected),
          isFalse,
        );
        expect(
          disabled.getSemanticsData().hasAction(SemanticsAction.tap),
          isFalse,
        );
        final opacity = tester.widget<Opacity>(
          find.ancestor(of: find.text('10:00'), matching: find.byType(Opacity)),
        );
        expect(opacity.opacity, lessThan(1));
        await tester.tap(find.text('10:00'));
        expect(selected, isEmpty);
        await tester.tap(find.text('11:00'));
        expect(selected, ['11:00']);
      } finally {
        semantics.dispose();
      }
    },
  );
}
