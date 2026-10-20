import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/models/promo_model.dart';

/// Promo listing and validation against the CleanGo backend.
class CustomerPromoApi {
  CustomerPromoApi({ApiClient? client, TokenStorage? tokenStorage})
      : _client = client ?? ApiClient(),
        _tokens = tokenStorage ?? SecureTokenStorage();

  final ApiClient _client;
  final TokenStorage _tokens;

  Future<String?> _token() async {
    final token = await _tokens.readAccessToken();
    return token == null || token.isEmpty ? null : token;
  }

  Future<List<PromoModel>> fetchPromos() async {
    final token = await _token();
    if (token == null) throw StateError('Sesi pelanggan belum tersedia.');
    final res = await _client.get(ApiConfig.customerPromos, token: token);
    final list = res['data'] as List<dynamic>? ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(PromoModel.fromApiJson)
        .toList(growable: false);
  }

  /// Returns the promo with the discount the backend computed for [amount].
  Future<PromoModel> validate({
    required String code,
    required int amount,
    String? serviceId,
  }) async {
    final token = await _token();
    if (token == null) throw StateError('Sesi pelanggan belum tersedia.');
    final res = await _client.post(
      ApiConfig.customerPromoValidate,
      body: {
        'code': code,
        'amount': amount,
        if (serviceId != null && serviceId.isNotEmpty) 'serviceId': serviceId,
      },
      token: token,
    );
    final data = res['data'] as Map<String, dynamic>? ?? const {};
    return PromoModel.fromApiJson(data);
  }
}
