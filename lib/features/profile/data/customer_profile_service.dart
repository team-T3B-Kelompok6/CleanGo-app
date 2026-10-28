import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../models/user_profile_model.dart';

class CustomerProfileService {
  CustomerProfileService({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;

  Future<UserProfileModel> fetchProfile(String token) async {
    final res = await _client.get(ApiConfig.customerProfile, token: token);
    return UserProfileModel.fromCustomerJson(
      (res['data'] ?? res) as Map<String, dynamic>,
    );
  }

  Future<UserProfileModel> updateProfile(
    String token, {
    String? fullName,
    String? email,
    String? phoneNumber,
  }) async {
    final body = <String, dynamic>{};
    if (fullName != null) body['name'] = fullName;
    if (email != null) body['email'] = email;
    if (phoneNumber != null) body['phone'] = phoneNumber;
    final res = await _client.patch(
      ApiConfig.customerProfile,
      body: body.isEmpty ? null : body,
      token: token,
    );
    return UserProfileModel.fromCustomerJson(
      (res['data'] ?? res) as Map<String, dynamic>,
    );
  }

  Future<UserProfileModel> uploadPhoto(
    String token, {
    required List<int> bytes,
    required String contentType,
  }) async {
    final res = await _client.postBytes(
      '${ApiConfig.customerProfile}/photo',
      bytes: bytes,
      contentType: contentType,
      token: token,
    );
    return UserProfileModel.fromCustomerJson(
      (res['data'] ?? res) as Map<String, dynamic>,
    );
  }

  Future<void> changePassword(
    String token, {
    required String currentPassword,
    required String newPassword,
  }) async {
    await _client.patch(
      '${ApiConfig.customerProfile}/password',
      body: {'currentPassword': currentPassword, 'newPassword': newPassword},
      token: token,
    );
  }
}
