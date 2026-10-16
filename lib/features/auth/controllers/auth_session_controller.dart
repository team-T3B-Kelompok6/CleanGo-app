import 'package:flutter/foundation.dart';

import '../../../core/storage/token_storage.dart';

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

  Future<void> signOut() {
    return _tokenStorage.deleteAccessToken();
  }
}
