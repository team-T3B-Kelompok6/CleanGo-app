import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../domain/models/address_model.dart';

class CustomerAddressService {
  CustomerAddressService({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;

  Future<List<AddressModel>> fetchAddresses(String token) async {
    final res = await _client.get(ApiConfig.customerAddresses, token: token);
    final list = res['data'] as List<dynamic>? ?? [];
    return list.map((e) => AddressModel.fromApiJson(e as Map<String, dynamic>)).toList();
  }

  Future<AddressModel> createAddress(String token, Map<String, dynamic> payload) async {
    final res = await _client.post(ApiConfig.customerAddresses, body: payload, token: token);
    return AddressModel.fromApiJson((res['data'] ?? res) as Map<String, dynamic>);
  }

  Future<AddressModel> updateAddress(String token, String id, Map<String, dynamic> payload) async {
    final res = await _client.patch('${ApiConfig.customerAddresses}/$id', body: payload, token: token);
    return AddressModel.fromApiJson((res['data'] ?? res) as Map<String, dynamic>);
  }

  Future<void> deleteAddress(String token, String id) async {
    await _client.delete('${ApiConfig.customerAddresses}/$id', token: token);
  }
}
