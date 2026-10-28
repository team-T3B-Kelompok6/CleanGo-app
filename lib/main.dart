import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/database/app_database.dart';
import 'core/storage/app_preferences.dart';
import 'core/storage/token_storage.dart';
import 'features/address/data/address_repository.dart';
import 'features/address/domain/models/address_model.dart';
import 'features/booking/data/booking_draft_repository.dart';
import 'features/service/data/service_data.dart';
import 'features/service/data/customer_service_remote_data_source.dart';
import 'features/service/data/service_repository.dart';
import 'features/service/domain/models/service_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = AppPreferences(SharedPreferencesAsync());
  final database = AppDatabase.defaults();
  final addressRepository = AddressRepository(database);
  final tokenStorage = SecureTokenStorage();
  final serviceRepository = ServiceRepository(
    database,
    remote: CustomerServiceRemoteDataSource(tokenStorage: tokenStorage),
  );
  final bookingRepository = BookingDraftRepository(database);

  // Local storage must never block the first frame: a slow or failing device
  // store falls back to sensible defaults instead of a black screen.
  final addressSnapshot = await _guard(
    addressRepository.readAddresses,
    const AddressSnapshot(addresses: [], selectedAddressId: ''),
  );
  final services = await _guard(() async {
    await serviceRepository.seedDefaultsIfEmpty(ServiceData.services);
    return serviceRepository.readServices();
  }, ServiceData.services);
  final bookingDraft = await _guard(bookingRepository.readDraft, null);
  final lastServiceFilter = await _guard(preferences.readLastServiceFilter, null);

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
      initialServiceFilter: lastServiceFilter,
      bookingRepository: bookingRepository,
      initialBookingDraft: bookingDraft,
      initialBookingService: initialBookingService,
      initialBookingAddress: selectedDraftAddress?.toCleaningAddress(),
      preferences: preferences,
      tokenStorage: tokenStorage,
    ),
  );
}

/// Runs [task] with a timeout; on failure/timeout returns [fallback] so startup
/// always reaches `runApp`.
Future<T> _guard<T>(Future<T> Function() task, T fallback) async {
  try {
    return await task().timeout(const Duration(seconds: 8));
  } catch (_) {
    return fallback;
  }
}
