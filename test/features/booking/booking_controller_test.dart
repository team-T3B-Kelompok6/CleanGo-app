import 'package:cleango_app/features/address/domain/models/address_model.dart';
import 'package:cleango_app/features/booking/controllers/booking_controller.dart';
import 'package:cleango_app/features/booking/domain/models/booking_draft.dart';
import 'package:cleango_app/features/service/data/service_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('offers all nine hourly slots and keeps one selected time', () {
    final booking = BookingController()
      ..startBooking(ServiceData.services.first)
      ..selectDate(DateTime(2030, 1, 2));
    addTearDown(booking.dispose);
    expect(BookingController.availableTimes, [
      '08:00',
      '09:00',
      '10:00',
      '11:00',
      '12:00',
      '13:00',
      '14:00',
      '15:00',
      '16:00',
    ]);
    for (final slot in BookingController.availableTimes) {
      booking.selectTime(slot);
      expect(booking.selectedTime, slot);
    }
    booking.selectTime('17:00');
    expect(booking.selectedTime, '16:00');
    booking.selectTime('10:30');
    expect(booking.selectedTime, '16:00');
  });

  test('rejects elapsed hours and dates when submitting a booking', () {
    final booking = BookingController()
      ..startBooking(ServiceData.services.first)
      ..selectDate(DateTime(2030, 1, 2))
      ..selectTime('09:00');
    addTearDown(booking.dispose);
    expect(
      booking.isTimeAvailable('08:00', now: DateTime(2030, 1, 2, 9)),
      isFalse,
    );
    expect(
      booking.isTimeAvailable('09:00', now: DateTime(2030, 1, 2, 9)),
      isTrue,
    );
    expect(
      booking.isTimeAvailable('16:00', now: DateTime(2030, 1, 2, 16, 1)),
      isFalse,
    );
    expect(booking.validateSchedule(now: DateTime(2030, 1, 2, 8)), isNull);
    expect(
      booking.validateSchedule(now: DateTime(2030, 1, 2, 9, 1)),
      contains('Jam mulai sudah lewat'),
    );
    expect(
      booking.validateSchedule(now: DateTime(2030, 1, 3)),
      contains('Tanggal booking sudah lewat'),
    );
  });

  test('normalizes an invalid restored time without losing booking notes', () {
    final booking = BookingController(
      initialService: ServiceData.services.first,
      initialDraft: BookingDraft(
        serviceId: ServiceData.services.first.id,
        selectedDate: DateTime(2030, 1, 2),
        selectedTime: '17:00',
        note: 'Fokus di dapur',
        updatedAt: DateTime.now().toUtc(),
      ),
    );
    addTearDown(booking.dispose);
    expect(booking.selectedTime, '08:00');
    expect(booking.note, 'Fokus di dapur');
  });

  test('converts an address once without duplicating the street or city', () {
    const address = AddressModel(
      id: 'test-address',
      title: 'Jl. Sigura-gura No. 12',
      fullAddress: 'Jl. Sigura-gura No. 12, Lowokwaru, Kota Malang, Jawa Timur',
      type: 'Rumah',
      contactName: 'Krisna',
      phoneNumber: '81234567890',
    );
    expect(address.toCleaningAddress().fullAddress, address.fullAddress);
    expect(
      address.toCleaningAddress().fullAddress.split(address.title),
      hasLength(2),
    );
    expect(
      BookingController.initialAddress.fullAddress,
      contains('Kota Malang'),
    );
  });
}
