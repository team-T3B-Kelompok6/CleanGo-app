import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/storage/token_storage.dart';

typedef NotificationInbox = ({
  List<Map<String, dynamic>> rows,
  int? unreadOrders,
  int? unreadPromo,
});

/// Notification inbox for the signed-in customer.
class CustomerNotificationApi {
  CustomerNotificationApi({ApiClient? client, TokenStorage? tokenStorage})
    : _client = client ?? ApiClient(),
      _tokens = tokenStorage ?? SecureTokenStorage();

  final ApiClient _client;
  final TokenStorage _tokens;

  Future<String?> _token() async {
    final token = await _tokens.readAccessToken();
    return token == null || token.isEmpty ? null : token;
  }

  Future<NotificationInbox> fetchNotifications() async {
    final token = await _token();
    if (token == null) throw StateError('Sesi pelanggan belum tersedia.');
    final res = await _client.get(
      ApiConfig.customerNotifications,
      token: token,
    );
    final list = res['data'] as List<dynamic>? ?? const [];
    final meta = res['meta'];
    final counts = meta is Map ? meta['unreadByCategory'] : null;
    return (
      rows: list.whereType<Map<String, dynamic>>().toList(growable: false),
      unreadOrders: counts is Map && counts['orders'] is int
          ? counts['orders'] as int
          : null,
      unreadPromo: counts is Map && counts['promo'] is int
          ? counts['promo'] as int
          : null,
    );
  }

  /// Menandai seluruh inbox pelanggan sebagai sudah dibaca.
  Future<void> markAllRead() async {
    final token = await _token();
    if (token == null) throw StateError('Sesi pelanggan belum tersedia.');
    await _client.patch(
      '${ApiConfig.customerNotifications}/read-all',
      token: token,
    );
  }

  Future<void> markRead(String id) async {
    final token = await _token();
    if (token == null) throw StateError('Sesi pelanggan belum tersedia.');
    await _client.patch(
      '${ApiConfig.customerNotifications}/$id/read',
      token: token,
    );
  }
}
