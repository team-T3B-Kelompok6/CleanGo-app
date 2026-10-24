import 'package:cleango_app/features/booking/controllers/booking_controller.dart';
import 'package:cleango_app/features/booking/data/customer_booking_api.dart';
import 'package:cleango_app/features/service/domain/models/service_model.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeBookingApi extends CustomerBookingApi {
  _FakeBookingApi({
    this.slots = const [],
    this.failAvailability = false,
    this.failCreate = false,
  });

  final List<BookingSlotInfo> slots;
  final bool failAvailability;
  final bool failCreate;
  int availabilityCalls = 0;
  int createCalls = 0;
  Map<String, dynamic>? lastCreate;

  @override
  Future<List<BookingSlotInfo>> availability({
    required String date,
    String? serviceId,
  }) async {
    availabilityCalls++;
    if (failAvailability) throw StateError('jaringan mati');
    return slots;
  }

  @override
  Future<CreatedBooking> create({
    required String serviceId,
    required String date,
    required String time,
    String? addressId,
    String notes = '',
  }) async {
    createCalls++;
    lastCreate = {
      'serviceId': serviceId,
      'date': date,
      'time': time,
      'addressId': addressId,
      'notes': notes,
    };
    if (failCreate) throw StateError('slot sudah penuh');
    return const CreatedBooking(
      id: '42',
      code: 'CG-TEST',
      status: 'confirmed',
      totalAmount: 105000,
    );
  }
}

const _service = ServiceModel(
  id: '7',
  title: 'Basic Home Cleaning',
  description: 'Pembersihan rutin',
  duration: '2 jam',
  price: 'Rp100.000',
  category: 'Rumah',
  iconPath: 'assets/icons/home.svg',
);

void main() {
  group('BookingController availability', () {
    test('loads server slots and moves to an available one', () async {
      // Only one slot is open, so the selection must end up on it no matter
      // what the local wall clock is.
      final api = _FakeBookingApi(
        slots: const [
          BookingSlotInfo(time: '08:00', available: false, reason: 'Waktu pemesanan sudah lewat.'),
          BookingSlotInfo(time: '10:00', available: true),
          BookingSlotInfo(time: '12:00', available: false, reason: 'Slot sudah penuh.'),
        ],
      );
      final controller = BookingController(bookingApi: api, initialService: _service);

      await controller.loadAvailability();

      expect(api.availabilityCalls, 1);
      expect(controller.hasServerAvailability, isTrue);
      expect(controller.slots, ['10:00']);
      expect(controller.selectedTime, '10:00');
      expect(controller.slotReason('08:00'), 'Waktu pemesanan sudah lewat.');
      expect(controller.slotReason('12:00'), 'Slot sudah penuh.');
      expect(controller.availabilityError, isNull);
    });

    test('rejects a slot the server marked unavailable', () async {
      final api = _FakeBookingApi(
        slots: const [
          BookingSlotInfo(time: '10:00', available: true),
          BookingSlotInfo(time: '12:00', available: false, reason: 'Slot sudah penuh.'),
        ],
      );
      final controller = BookingController(bookingApi: api, initialService: _service);
      await controller.loadAvailability();

      controller.selectTime('12:00');

      expect(controller.selectedTime, isNot('12:00'));
    });

    test('falls back to the local schedule when availability fails', () async {
      final api = _FakeBookingApi(failAvailability: true);
      final controller = BookingController(bookingApi: api, initialService: _service);

      await controller.loadAvailability();

      expect(controller.hasServerAvailability, isFalse);
      expect(controller.slots, BookingController.availableTimes);
      expect(controller.availabilityError, isNotNull);
    });

    test('exposes every server slot so closed times can explain themselves', () async {
      final api = _FakeBookingApi(
        slots: const [
          BookingSlotInfo(time: '08:00', available: false, reason: 'Waktu pemesanan sudah lewat.'),
          BookingSlotInfo(time: '10:00', available: true),
          BookingSlotInfo(time: '12:00', available: false, reason: 'Slot sudah penuh.'),
        ],
      );
      final controller = BookingController(bookingApi: api, initialService: _service);

      await controller.loadAvailability();

      expect(controller.allSlots, ['08:00', '10:00', '12:00']);
      expect(controller.slots, ['10:00']);
      expect(controller.hasSlotInfo('12:00'), isTrue);
      expect(controller.slotReason('12:00'), 'Slot sudah penuh.');
      expect(controller.slotReason('14:00'), isNull);
    });

    test('falls back to the full local schedule when there is no server data', () async {
      final controller = BookingController(initialService: _service);

      expect(controller.allSlots, BookingController.availableTimes);
      expect(controller.hasSlotInfo('08:00'), isFalse);
      expect(controller.slotReason('08:00'), isNull);
    });

    test('keeps the local schedule when no booking api is configured', () async {
      final controller = BookingController(initialService: _service);

      await controller.loadAvailability();

      expect(controller.slots, BookingController.availableTimes);
    });
  });

  group('BookingController server booking', () {
    test('sends the selected schedule to the backend', () async {
      final api = _FakeBookingApi(
        slots: const [BookingSlotInfo(time: '14:00', available: true)],
      );
      final controller = BookingController(bookingApi: api, initialService: _service);
      await controller.loadAvailability();
      controller.updateAddress(
        controller.address,
        addressId: '5',
      );
      controller.updateNote('Bawa vacuum');

      final created = await controller.createBookingOnServer();

      expect(api.createCalls, 1);
      expect(created?.code, 'CG-TEST');
      expect(api.lastCreate?['serviceId'], '7');
      expect(api.lastCreate?['time'], '14:00');
      expect(api.lastCreate?['addressId'], '5');
      expect(api.lastCreate?['notes'], 'Bawa vacuum');
      expect(api.lastCreate?['date'], BookingController.isoDate(controller.selectedDate));
    });

    test('returns null without a configured api (local-only mode)', () async {
      final controller = BookingController(initialService: _service);

      expect(await controller.createBookingOnServer(), isNull);
    });

    test('propagates backend conflicts', () async {
      final api = _FakeBookingApi(
        slots: const [BookingSlotInfo(time: '10:00', available: true)],
        failCreate: true,
      );
      final controller = BookingController(bookingApi: api, initialService: _service);
      await controller.loadAvailability();

      expect(
        () => controller.createBookingOnServer(),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('BookingController.isoDate', () {
    test('pads month and day', () {
      expect(BookingController.isoDate(DateTime(2026, 1, 5)), '2026-01-05');
      expect(BookingController.isoDate(DateTime(2026, 12, 31)), '2026-12-31');
    });
  });
}
