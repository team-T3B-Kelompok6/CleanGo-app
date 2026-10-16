import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/database/app_database.dart';
import 'core/storage/app_preferences.dart';
import 'core/storage/token_storage.dart';
import 'features/address/controllers/address_controller.dart';
import 'features/address/data/address_repository.dart';
import 'features/address/domain/models/address_model.dart';
import 'features/booking/data/booking_draft_repository.dart';
import 'features/service/data/service_data.dart';
import 'features/service/data/service_repository.dart';
import 'features/service/domain/models/service_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = AppPreferences(SharedPreferencesAsync());
  final database = AppDatabase.defaults();
  final addressRepository = AddressRepository(database);
  await addressRepository.seedDefaultsIfEmpty(
    AddressController.defaultAddresses,
  );
  final addressSnapshot = await addressRepository.readAddresses();
  final serviceRepository = ServiceRepository(database);
  await serviceRepository.seedDefaultsIfEmpty(ServiceData.services);
  final services = await serviceRepository.readServices();
  final bookingRepository = BookingDraftRepository(database);
  final bookingDraft = await bookingRepository.readDraft();
  ServiceModel? initialBookingService;
  AddressModel? selectedDraftAddress;
  if (bookingDraft != null) {
    for (final service in services) {
      if (service.id == bookingDraft.serviceId) {
        initialBookingService = service;
        break;
      }
    }
    for (final address in addressSnapshot.addresses) {
      if (address.id == bookingDraft.addressId) {
        selectedDraftAddress = address;
        break;
      }
    }
  }

  runApp(
    CleanGoApp(
      database: database,
      addressRepository: addressRepository,
      initialAddresses: addressSnapshot.addresses,
      serviceRepository: serviceRepository,
      initialServices: services,
      initialServiceFilter: await preferences.readLastServiceFilter(),
      bookingRepository: bookingRepository,
      initialBookingDraft: bookingDraft,
      initialBookingService: initialBookingService,
      initialBookingAddress: selectedDraftAddress?.toCleaningAddress(),
      preferences: preferences,
      tokenStorage: SecureTokenStorage(),
    ),
  );
}
