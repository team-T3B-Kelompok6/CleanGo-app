import 'package:cleango_app/core/network/api_exception.dart';
import 'package:cleango_app/core/storage/token_storage.dart';
import 'package:cleango_app/features/profile/data/customer_profile_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cleango_app/features/profile/models/user_profile_model.dart';
import 'package:cleango_app/features/profile/controllers/profile_controller.dart';

class _MemoryTokens implements TokenStorage {
  _MemoryTokens(this.token);

  final String? token;

  @override
  Future<String?> readAccessToken() async => token;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _PasswordService extends CustomerProfileService {
  String _password = 'ExistingPassword123';
  int calls = 0;
  String? lastToken;
  bool unavailable = false;

  @override
  Future<void> changePassword(
    String token, {
    required String currentPassword,
    required String newPassword,
  }) async {
    calls++;
    lastToken = token;
    if (unavailable) throw StateError('Service unavailable');
    if (currentPassword != _password) {
      throw const ApiException(
        statusCode: 400,
        message: 'Kata sandi saat ini tidak sesuai.',
      );
    }
    _password = newPassword;
  }
}

void main() {
  group('UserProfileModel Tests', () {
    test('formattedBirthDate formats correctly to Indonesian date string', () {
      final model = UserProfileModel(
        id: 'usr-001',
        customerId: 'CG-8829104',
        fullName: 'Krisna Pratama',
        phoneNumber: '+62 812–3456–7890',
        isPhoneVerified: true,
        email: 'krisna.pratama@email.com',
        gender: 'Laki-laki',
        birthDate: DateTime(1995, 5, 14),
      );

      expect(model.formattedBirthDate, '14 Mei 1995');
    });

    test('copyWith updates specified fields only', () {
      final model = UserProfileModel(
        id: 'usr-001',
        customerId: 'CG-8829104',
        fullName: 'Krisna Pratama',
        phoneNumber: '+62 812–3456–7890',
        isPhoneVerified: true,
        email: 'krisna.pratama@email.com',
        gender: 'Laki-laki',
        birthDate: DateTime(1995, 5, 14),
      );

      final updated = model.copyWith(
        fullName: 'Krisna Pratama S.Kom',
        email: 'krisna.new@cleango.id',
      );

      expect(updated.fullName, 'Krisna Pratama S.Kom');
      expect(updated.email, 'krisna.new@cleango.id');
      expect(updated.customerId, 'CG-8829104');
      expect(updated.gender, 'Laki-laki');
    });

    test('toJson and fromJson serialize and deserialize correctly', () {
      final model = UserProfileModel(
        id: 'usr-001',
        customerId: 'CG-8829104',
        fullName: 'Krisna Pratama',
        phoneNumber: '+62 812–3456–7890',
        isPhoneVerified: true,
        email: 'krisna.pratama@email.com',
        gender: 'Laki-laki',
        birthDate: DateTime(1995, 5, 14),
      );

      final json = model.toJson();
      final fromJson = UserProfileModel.fromJson(json);

      expect(fromJson.id, model.id);
      expect(fromJson.fullName, model.fullName);
      expect(fromJson.email, model.email);
      expect(fromJson.gender, model.gender);
      expect(fromJson.birthDate, isNotNull);
      expect(fromJson.birthDate!.year, 1995);
      expect(fromJson.birthDate!.month, 5);
      expect(fromJson.birthDate!.day, 14);
    });
  });

  group('ProfileController Tests', () {
    late ProfileController controller;

    setUp(() {
      controller = ProfileController();
    });

    test('Initial state has no identity before the account is loaded', () {
      expect(controller.fullName, isEmpty);
      expect(controller.customerId, isEmpty);
      expect(controller.phoneNumber, isEmpty);
      expect(controller.email, isEmpty);
      expect(controller.isPhoneVerified, true);
    });

    test('updateProfile updates profile properties and notifies listeners', () {
      var notified = false;
      controller.addListener(() {
        notified = true;
      });

      controller.updateProfile(
        fullName: 'Budi Santoso',
        email: 'budi@example.com',
        gender: 'Perempuan',
        birthDate: DateTime(2000, 1, 1),
      );

      expect(notified, true);
      expect(controller.fullName, 'Budi Santoso');
      expect(controller.email, 'budi@example.com');
      expect(controller.gender, 'Perempuan');
      expect(controller.formattedBirthDate, '1 Januari 2000');
    });

    test('setPhoneVerified updates verification state', () {
      controller.setPhoneVerified(false);
      expect(controller.isPhoneVerified, false);

      controller.setPhoneVerified(true);
      expect(controller.isPhoneVerified, true);
    });

    test('updateAvatar updates avatarAsset path', () {
      controller.updateAvatar('assets/images/custom_avatar.png');
      expect(controller.avatarAsset, 'assets/images/custom_avatar.png');
    });

    test(
      'remote password change rejects the old password after success',
      () async {
        final service = _PasswordService();
        final remote = ProfileController(
          tokenStorage: _MemoryTokens('test-session'),
          service: service,
        );
        addTearDown(remote.dispose);

        expect(
          await remote.changePasswordRemote(
            currentPassword: 'ExistingPassword123',
            newPassword: 'NewPassword123',
          ),
          isTrue,
        );
        expect(service.lastToken, 'test-session');
        expect(remote.error, isNull);
        expect(
          await remote.changePasswordRemote(
            currentPassword: 'ExistingPassword123',
            newPassword: 'AnotherPassword456',
          ),
          isFalse,
        );
        expect(remote.error, contains('Kata sandi saat ini tidak sesuai.'));
        expect(
          await remote.changePasswordRemote(
            currentPassword: 'NewPassword123',
            newPassword: 'AnotherPassword456',
          ),
          isTrue,
        );
        expect(remote.error, isNull);
        expect(service.calls, 3);
      },
    );

    test(
      'remote password check preserves whitespace and propagates rejection',
      () async {
        final service = _PasswordService();
        final remote = ProfileController(
          tokenStorage: _MemoryTokens('test-session'),
          service: service,
        );
        addTearDown(remote.dispose);
        var notifications = 0;
        remote.addListener(() => notifications++);

        expect(
          await remote.changePasswordRemote(
            currentPassword: ' ExistingPassword123 ',
            newPassword: 'NewPassword123',
          ),
          isFalse,
        );
        expect(remote.error, contains('Kata sandi saat ini tidak sesuai.'));
        expect(notifications, 1);
        expect(service.calls, 1);
      },
    );

    test(
      'remote password change fails without a session and never calls API',
      () async {
        for (final token in [null, '']) {
          final service = _PasswordService();
          final remote = ProfileController(
            tokenStorage: _MemoryTokens(token),
            service: service,
          );
          addTearDown(remote.dispose);
          expect(
            await remote.changePasswordRemote(
              currentPassword: 'ExistingPassword123',
              newPassword: 'NewPassword123',
            ),
            isFalse,
          );
          expect(service.calls, 0);
          expect(remote.error, 'Sesi tidak ditemukan. Silakan masuk kembali.');
        }
      },
    );

    test(
      'remote password change never reports success when API is unavailable',
      () async {
        final service = _PasswordService()..unavailable = true;
        final remote = ProfileController(
          tokenStorage: _MemoryTokens('test-session'),
          service: service,
        );
        addTearDown(remote.dispose);
        expect(
          await remote.changePasswordRemote(
            currentPassword: 'ExistingPassword123',
            newPassword: 'NewPassword123',
          ),
          isFalse,
        );
        expect(remote.error, contains('Service unavailable'));
        expect(service.calls, 1);
      },
    );
  });
}
