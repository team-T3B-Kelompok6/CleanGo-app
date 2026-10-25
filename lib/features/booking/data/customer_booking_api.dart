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

  Future<List<CustomerBookingSummary>> fetchBookings() async {
    final token = await _token();
    if (token == null) throw StateError('Sesi pelanggan belum tersedia.');
    final res = await _client.get(ApiConfig.customerBookings, token: token);
    final list = res['data'] as List<dynamic>? ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(CustomerBookingSummary.fromJson)
        .toList(growable: false);
  }

  /// Dummy payment (trial only): marks the booking as paid without a gateway.
  Future<CreatedBooking> pay({
    required String bookingId,
    required String method,
  }) async {
    final token = await _token();
    if (token == null) throw StateError('Sesi pelanggan belum tersedia.');
    final res = await _client.post(
      '${ApiConfig.customerBookings}/$bookingId/pay',
      body: {'method': method},
      token: token,
    );
    final data = res['data'] as Map<String, dynamic>? ?? const {};
    return CreatedBooking.fromJson(data);
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

/// One booking as listed by `GET /api/customer/bookings`.
class CustomerBookingSummary {
  const CustomerBookingSummary({
    required this.id,
    required this.code,
    required this.date,
    required this.time,
    required this.service,
    required this.servicePrice,
    required this.platformFee,
    required this.discountAmount,
    required this.totalAmount,
    required this.status,
    required this.notes,
    required this.address,
    this.addressLabel = '',
    this.latitude,
    this.longitude,
  });

  final String id;
  final String code;
  final String date;
  final String time;
  final String service;
  final int servicePrice;
  final int platformFee;
  final int discountAmount;
  final int totalAmount;
  final String status;
  final String notes;
  final String address;
  final String addressLabel;
  final double? latitude;
  final double? longitude;

  DateTime? get scheduledAt {
    final parsed = DateTime.tryParse('${date}T$time:00');
    return parsed;
  }

  bool get isFinished => status == 'Selesai' || status == 'Batal';

  static CustomerBookingSummary fromJson(Map<String, dynamic> json) {
    return CustomerBookingSummary(
      id: '${json['id'] ?? ''}',
      code: json['code'] as String? ?? '',
      date: json['date'] as String? ?? '',
      time: json['time'] as String? ?? '',
      service: json['service'] as String? ?? 'Layanan',
      servicePrice: (json['servicePrice'] as num?)?.toInt() ?? 0,
      platformFee: (json['platformFee'] as num?)?.toInt() ?? 0,
      discountAmount: (json['discountAmount'] as num?)?.toInt() ?? 0,
      totalAmount: (json['totalAmount'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'Menunggu Assign',
      notes: json['notes'] as String? ?? '',
      address: json['address'] as String? ?? '',
      addressLabel: json['addressLabel'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}
