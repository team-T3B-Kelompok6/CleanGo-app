import 'package:cleango_app/core/theme/app_theme.dart';
import 'package:cleango_app/features/address/controllers/address_controller.dart';
import 'package:cleango_app/features/booking/controllers/booking_controller.dart';
import 'package:cleango_app/features/booking/pages/booking_page.dart';
import 'package:cleango_app/features/service/data/service_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
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
