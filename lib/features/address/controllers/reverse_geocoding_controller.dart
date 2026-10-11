import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class ResolvedAddress {
  const ResolvedAddress({
    required this.shortAddress,
    required this.fullAddress,
  });

  final String shortAddress;
  final String fullAddress;
}

class ReverseGeocodingController {
  ReverseGeocodingController({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;
  static final Map<String, ResolvedAddress> _cache = {};
  static DateTime? _lastRequestAt;

  Future<ResolvedAddress> resolve(LatLng position) async {
    final key =
        '${position.latitude.toStringAsFixed(5)},'
        '${position.longitude.toStringAsFixed(5)}';
    final cached = _cache[key];
    if (cached != null) return cached;

    final lastRequest = _lastRequestAt;
    if (lastRequest != null) {
      final elapsed = DateTime.now().difference(lastRequest);
      if (elapsed < const Duration(seconds: 1)) {
        await Future<void>.delayed(const Duration(seconds: 1) - elapsed);
      }
    }
    _lastRequestAt = DateTime.now();

    final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
      'format': 'jsonv2',
      'lat': position.latitude.toString(),
      'lon': position.longitude.toString(),
      'zoom': '18',
      'addressdetails': '1',
      'accept-language': 'id',
    });
    final response = await _client.get(
      uri,
      headers: kIsWeb
          ? const {'Accept': 'application/json'}
          : const {
              'User-Agent': 'CleanGo-Mobile/1.0 (academic Flutter project)',
              'Accept': 'application/json',
            },
    );
    if (response.statusCode != 200) {
      throw const FormatException('Alamat tidak dapat ditemukan.');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final parts =
        (json['address'] as Map?)?.cast<String, dynamic>() ?? const {};
    final road = _first(parts, ['road', 'pedestrian', 'residential', 'path']);
    final houseNumber = _first(parts, ['house_number']);
    final area = _first(parts, [
      'neighbourhood',
      'quarter',
      'suburb',
      'village',
      'hamlet',
    ]);
    final district = _first(parts, [
      'city_district',
      'district',
      'municipality',
      'county',
    ]);
    final city = _first(parts, ['city', 'town', 'regency']);
    final province = _first(parts, ['state', 'region']);
    final postcode = _first(parts, ['postcode']);
    final country = _first(parts, ['country']);

    final roadAndNumber = [
      road,
      houseNumber,
    ].where((part) => part.isNotEmpty).join(' No. ');
    final fullParts = [
      roadAndNumber,
      area,
      district,
      city,
      province,
      postcode,
      country,
    ].where((part) => part.isNotEmpty).toList();
    final displayName = (json['display_name'] as String?)?.trim() ?? '';
    final fullAddress = fullParts.length >= 3
        ? fullParts.toSet().join(', ')
        : displayName;
    if (fullAddress.isEmpty) {
      throw const FormatException(
        'Alamat lengkap tidak tersedia di titik ini.',
      );
    }

    final result = ResolvedAddress(
      shortAddress: roadAndNumber.isNotEmpty
          ? roadAndNumber
          : area.isNotEmpty
          ? area
          : fullAddress.split(',').first,
      fullAddress: fullAddress,
    );
    _cache[key] = result;
    return result;
  }

  static String _first(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    }
    return '';
  }

  void dispose() => _client.close();
}
