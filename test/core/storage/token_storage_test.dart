import 'package:cleango_app/core/storage/token_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('menulis, membaca, dan menghapus access token dengan aman', () async {
    final storage = SecureTokenStorage();

    await storage.writeAccessToken('token-rahasia');
    expect(await storage.readAccessToken(), 'token-rahasia');

    await storage.deleteAccessToken();
    expect(await storage.readAccessToken(), isNull);
  });
}
