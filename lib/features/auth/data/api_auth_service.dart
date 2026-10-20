import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';

class ApiAuthService {
  ApiAuthService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<AuthResult> login({
    required String phone,
    required String password,
  }) async {
    final response = await _client.post(
      '${ApiConfig.customerAuth}/login',
      body: {'phone': phone, 'password': password},
    );
    return _parseAuthResult(response);
  }

  Future<AuthResult> register({
    required String name,
    required String phone,
    required String password,
    String? email,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'phone': phone,
      'password': password,
    };
    if (email != null && email.isNotEmpty) {
      body['email'] = email;
    }
    final response = await _client.post(
      '${ApiConfig.customerAuth}/register',
      body: body,
    );
    return _parseAuthResult(response);
  }

  Future<AuthResult> socialLogin({
    required String provider,
    required String email,
    required String name,
    String? idToken,
  }) async {
    final body = <String, dynamic>{
      'provider': provider,
      'email': email,
      'name': name,
    };
    if (idToken != null && idToken.isNotEmpty) {
      body['idToken'] = idToken;
    }
    final response = await _client.post(
      '${ApiConfig.customerAuth}/social-login',
      body: body,
    );
    return _parseAuthResult(response);
  }

  AuthResult _parseAuthResult(Map<String, dynamic> response) {
    final data = response['data'] as Map<String, dynamic>?;
    final token = data?['token'] as String?;
    final userMap = data?['user'] as Map<String, dynamic>?;
    if (token == null || token.isEmpty) {
      throw const ApiException(
        statusCode: 500,
        message: 'Token tidak ditemukan dalam respons',
      );
    }
    return AuthResult(
      token: token,
      user: User.fromJson(userMap ?? {}),
      expiresIn: (data?['expiresIn'] as num?)?.toInt(),
    );
  }
}

class AuthResult {
  const AuthResult({required this.token, required this.user, this.expiresIn});

  final String token;
  final User user;

  /// Token lifetime in seconds, as reported by the backend.
  final int? expiresIn;
}

class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
  });

  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'customer',
    );
  }
}
