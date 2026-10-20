import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/storage/token_storage.dart';

class BookingSlotInfo {
  const BookingSlotInfo({
    required this.time,
    required this.available,
    this.reason,
  });

  final String time;
  final bool available;
  final String? reason;
}

class CreatedBooking {
  const CreatedBooking({
    required this.id,
    required this.code,
    required this.status,
    required this.totalAmount,
  });

  final String id;
  final String code;
  final String status;
  final int totalAmount;

  static CreatedBooking fromJson(Map<String, dynamic> json) => CreatedBooking(
        id: '${json['id'] ?? ''}',
        code: json['code'] as String? ?? '',
        status: json['status'] as String? ?? '',
        totalAmount: (json['totalAmount'] as num?)?.toInt() ?? 0,
      );
}

/// Booking availability and creation against the CleanGo backend.
class CustomerBookingApi {
  CustomerBookingApi({ApiClient? client, TokenStorage? tokenStorage})
      : _client = client ?? ApiClient(),
        _tokens = tokenStorage;

  final ApiClient _client;
  final TokenStorage? _tokens;

  Future<String?> _token() async {
    final token = await _tokens?.readAccessToken();
    return token == null || token.isEmpty ? null : token;
  }

  /// Returns the slot board for [date] (`YYYY-MM-DD`). Throws when there is no
  /// customer session so callers can fall back to the local schedule.
  Future<List<BookingSlotInfo>> availability({
    required String date,
    String? serviceId,
  }) async {
    final token = await _token();
    if (token == null) throw StateError('Sesi pelanggan belum tersedia.');
    final query = StringBuffer('?date=$date');
    if (serviceId != null && serviceId.isNotEmpty) {
      query.write('&service=$serviceId');
    }
    final res = await _client.get(
      '${ApiConfig.customerBookings}/availability$query',
      token: token,
    );
    final data = res['data'] as Map<String, dynamic>? ?? const {};
    final slots = data['slots'] as List<dynamic>? ?? const [];
    return slots.whereType<Map<String, dynamic>>().map((slot) {
      return BookingSlotInfo(
        time: slot['time'] as String? ?? '',
        available: slot['available'] == true,
        reason: slot['reason'] as String?,
      );
    }).toList(growable: false);
  }

  Future<CreatedBooking> create({
    required String serviceId,
    required String date,
    required String time,
    String? addressId,
    String notes = '',
  }) async {
    final token = await _token();
    if (token == null) throw StateError('Sesi pelanggan belum tersedia.');
    final body = <String, dynamic>{
      'serviceId': int.tryParse(serviceId) ?? serviceId,
      'date': date,
      'time': time,
      if (addressId != null && addressId.isNotEmpty)
        'addressId': int.tryParse(addressId) ?? addressId,
      if (notes.trim().isNotEmpty) 'notes': notes.trim(),
    };
    final res = await _client.post(
      ApiConfig.customerBookings,
      body: body,
      token: token,
    );
    final data = res['data'] as Map<String, dynamic>? ?? const {};
    return CreatedBooking.fromJson(data);
  }
}
