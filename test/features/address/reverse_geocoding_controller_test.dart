import 'package:cleango_app/features/address/controllers/reverse_geocoding_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:latlong2/latlong.dart';

void main() {
  test('builds a readable address from reverse-geocoding data', () async {
    final client = MockClient(
      (_) async => http.Response(
        '''{"address":{"road":"Jl. Mawar","house_number":"10","suburb":"Lowokwaru","city_district":"Kec. Lowokwaru","city":"Kota Malang","state":"Jawa Timur","postcode":"65141","country":"Indonesia"}}''',
        200,
      ),
    );
    final controller = ReverseGeocodingController(client: client);
    addTearDown(controller.dispose);

    final address = await controller.resolve(const LatLng(-7.95, 112.61));

    expect(address.shortAddress, 'Jl. Mawar No. 10');
    expect(
      address.fullAddress,
      'Jl. Mawar No. 10, Lowokwaru, Kec. Lowokwaru, Kota Malang, Jawa Timur, 65141, Indonesia',
    );
  });

  test('reports a lookup failure instead of returning empty data', () async {
    final client = MockClient((_) async => http.Response('Unavailable', 503));
    final controller = ReverseGeocodingController(client: client);
    addTearDown(controller.dispose);

    expect(
      controller.resolve(const LatLng(-7.96, 112.62)),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          'Alamat tidak dapat ditemukan.',
        ),
      ),
    );
  });
}
