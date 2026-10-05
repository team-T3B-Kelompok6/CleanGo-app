import 'package:flutter_test/flutter_test.dart';
import 'package:cleango_app/features/profile/models/user_profile_model.dart';
import 'package:cleango_app/features/profile/controllers/profile_controller.dart';

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
      expect(fromJson.birthDate.year, 1995);
      expect(fromJson.birthDate.month, 5);
      expect(fromJson.birthDate.day, 14);
    });
  });

  group('ProfileController Tests', () {
    late ProfileController controller;

    setUp(() {
      controller = ProfileController();
    });

    test('Initial state contains default profile data', () {
      expect(controller.fullName, 'Krisna Pratama');
      expect(controller.customerId, 'CG-8829104');
      expect(controller.phoneNumber, '+62 812–3456–7890');
      expect(controller.isPhoneVerified, true);
      expect(controller.email, 'krisna.pratama@email.com');
      expect(controller.gender, 'Laki-laki');
      expect(controller.formattedBirthDate, '14 Mei 1995');
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

    test('verifyPassword and changePassword operate on current password 321321', () {
      expect(controller.password, '321321');
      expect(controller.verifyPassword('321321'), true);
      expect(controller.verifyPassword('wrong'), false);

      final changed = controller.changePassword(
        currentPassword: '321321',
        newPassword: 'NewPassword123',
      );
      expect(changed, true);
      expect(controller.password, 'NewPassword123');
      expect(controller.verifyPassword('NewPassword123'), true);
    });
  });
}
