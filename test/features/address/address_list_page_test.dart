import 'package:cleango_app/features/address/controllers/address_controller.dart';
import 'package:cleango_app/features/address/domain/models/address_model.dart';
import 'package:cleango_app/features/address/pages/address_list_page.dart';
import 'package:cleango_app/features/booking/controllers/booking_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('empty state follows address data and disables selection', (
    tester,
  ) async {
    final addressController = AddressController();
    for (final address in List.of(addressController.addresses)) {
      addressController.deleteAddress(address.id);
    }

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: addressController),
          ChangeNotifierProvider(create: (_) => BookingController()),
        ],
        child: const MaterialApp(home: AddressListPage()),
      ),
    );

    expect(find.text('Belum Ada Alamat Tersimpan'), findsOneWidget);
    var useButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Gunakan Alamat Ini'),
    );
    expect(useButton.onPressed, isNull);

    addressController.addAddress(
      const AddressModel(
        id: 'new-address',
        title: 'Rumah',
        fullAddress: 'Jl. Mawar No. 10, Kota Malang',
        type: 'Rumah',
        contactName: 'Krisna',
        phoneNumber: '(+62) 81234567890',
        isPrimary: true,
      ),
    );
    await tester.pump();

    expect(find.text('Belum Ada Alamat Tersimpan'), findsNothing);
    useButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Gunakan Alamat Ini'),
    );
    expect(useButton.onPressed, isNotNull);
  });

  testWidgets('shows the address limit message instead of opening the form', (
    tester,
  ) async {
    final addressController = AddressController();
    for (
      var index = addressController.addresses.length;
      index < AddressController.maxAddresses;
      index++
    ) {
      addressController.addAddress(
        AddressModel(
          id: 'address-$index',
          title: 'Alamat $index',
          fullAddress: 'Jl. Mawar No. $index, Kota Malang',
          type: 'Rumah',
          contactName: 'Krisna',
          phoneNumber: '(+62) 81234567890',
          isPrimary: false,
        ),
      );
    }

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: addressController),
          ChangeNotifierProvider(create: (_) => BookingController()),
        ],
        child: const MaterialApp(home: AddressListPage()),
      ),
    );

    await tester.tap(find.widgetWithText(OutlinedButton, 'Tambahkan alamat'));
    await tester.pump();

    expect(find.text('Maksimal 5 alamat tersimpan.'), findsOneWidget);
    expect(find.byType(AddressListPage), findsOneWidget);
  });
}
