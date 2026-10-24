import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthResult {
  const GoogleAuthResult({
    required this.idToken,
    required this.email,
    required this.name,
  });

  final String idToken;
  final String email;
  final String name;
}

class GoogleSignInService {
  GoogleSignInService()
    : _signIn = GoogleSignIn(
        serverClientId: '789086192188-unnm6jjih7nusvhr370b0dj44be1umob.apps.googleusercontent.com',
      );

  final GoogleSignIn _signIn;

  Future<GoogleAuthResult?> signIn() async {
    if (await _signIn.isSignedIn()) {
      await _signIn.signOut();
    }

    final account = await _signIn.signIn();
    if (account == null) return null;

    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw StateError('Google ID token tidak tersedia');
    }

    return GoogleAuthResult(
      idToken: idToken,
      email: account.email,
      name: account.displayName?.trim().isNotEmpty == true
          ? account.displayName!.trim()
          : account.email.split('@').first,
    );
  }

  Future<void> signOut() => _signIn.signOut();
}
