import 'package:cleango_app/features/profile/controllers/personal_data_form_controller.dart';
import 'package:cleango_app/features/profile/controllers/profile_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PersonalDataFormController', () {
    late ProfileController profileController;
    late PersonalDataFormController formController;

    setUp(() {
      profileController = ProfileController();
      formController = PersonalDataFormController(profileController.profile);
    });

    tearDown(() {
      formController.dispose();
      profileController.dispose();
    });

    test('loads editable values from the current profile', () {
      expect(formController.name.text, profileController.fullName);
      expect(formController.phone.text, profileController.phoneNumber);
      expect(formController.email.text, profileController.email);
      expect(formController.selectedGender, profileController.gender);
    });

    test('saves trimmed form values through ProfileController', () {
      formController
        ..name.text = '  Budi Santoso  '
        ..phone.text = '81200001111'
        ..email.text = '  budi@example.com  '
        ..selectGender('Perempuan')
        ..selectBirthDate(DateTime(2000, 1, 2))
        ..saveTo(profileController);

      expect(profileController.fullName, 'Budi Santoso');
      expect(profileController.phoneNumber, '+62 81200001111');
      expect(profileController.email, 'budi@example.com');
      expect(profileController.gender, 'Perempuan');
      expect(profileController.birthDate, DateTime(2000, 1, 2));
    });

    test('normalizes a typed country or trunk prefix before saving', () {
      formController.phone.text = '6281200001111';
      formController.saveTo(profileController);
      expect(profileController.phoneNumber, '+62 81200001111');

      formController.phone.text = '081200001111';
      formController.saveTo(profileController);
      expect(profileController.phoneNumber, '+62 81200001111');
    });

    test('toggles phone edit state', () {
      expect(formController.togglePhoneEditing(), isTrue);
      expect(formController.isPhoneEditable, isTrue);
      expect(formController.togglePhoneEditing(), isFalse);
    });
  });
}
