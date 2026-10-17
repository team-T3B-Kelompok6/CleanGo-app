import 'package:flutter/foundation.dart';

import '../../../core/storage/token_storage.dart';
import '../data/api_auth_service.dart';

class AuthSessionController extends ChangeNotifier {
  AuthSessionController(this._tokenStorage);

  final TokenStorage _tokenStorage;

  Future<bool> hasSession() async {
    final token = await _tokenStorage.readAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> createSession(String token) {
    return _tokenStorage.writeAccessToken(token);
  }

  Future<void> signOut() async {
    final token = await _tokenStorage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      try {
        await ApiAuthService().logout(token);
      } catch (_) {}
    }
    await _tokenStorage.deleteAccessToken();
  }
}
