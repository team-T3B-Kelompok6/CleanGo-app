import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/database/app_database.dart';
import 'core/storage/app_preferences.dart';
import 'core/storage/token_storage.dart';
import 'features/address/controllers/address_controller.dart';
import 'features/address/data/address_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = AppDatabase.defaults();
  final addressRepository = AddressRepository(database);
  await addressRepository.seedDefaultsIfEmpty(
    AddressController.defaultAddresses,
  );
  final addressSnapshot = await addressRepository.readAddresses();

  runApp(
    CleanGoApp(
      database: database,
      addressRepository: addressRepository,
      initialAddresses: addressSnapshot.addresses,
      preferences: AppPreferences(await SharedPreferences.getInstance()),
      tokenStorage: SecureTokenStorage(),
    ),
  );
}
