import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/database/app_database.dart';
import 'core/network/api_client.dart';
import 'core/notifications/push_notifications.dart';
import 'core/storage/app_preferences.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/chatbot/data/chat_image_cache.dart';
import 'features/address/data/address_repository.dart';
import 'features/address/domain/models/address_model.dart';
import 'features/booking/data/booking_draft_repository.dart';
import 'features/onboarding/pages/splash_page.dart';
import 'features/service/data/customer_service_remote_data_source.dart';
import 'features/service/data/service_repository.dart';
import 'features/service/domain/models/service_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _BootstrapView());
}

class _BootstrapView extends StatefulWidget {
  const _BootstrapView();

  @override
  State<_BootstrapView> createState() => _BootstrapViewState();
}

class _BootstrapViewState extends State<_BootstrapView> {
  Future<CleanGoApp>? _app;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startBootstrap();
    });
  }

  void _startBootstrap() {
    final app = _bootstrap();
    setState(() {
      _app = app;
    });
  }

  Future<CleanGoApp> _bootstrap() async {
    final preferences = AppPreferences(SharedPreferencesAsync());
    final database = AppDatabase.defaults();
    final addressRepository = AddressRepository(database);
    final tokenStorage = SecureTokenStorage();
    final serviceRepository = ServiceRepository(
      database,
      remote: CustomerServiceRemoteDataSource(tokenStorage: tokenStorage),
    );
    final bookingRepository = BookingDraftRepository(database);

    Future<PushNotifications?> firebaseTask() async {
      if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
        return null;
      }
      return _initializeFirebase(tokenStorage);
    }

    // I/O independen aman dijalankan bersamaan; setiap tugas punya fallback agar
    // satu kegagalan tidak menyedot seluruh startup.
    await discardLostChatPhotos();
    final pushFuture = firebaseTask();
    final addressFuture = _guard(
      addressRepository.readAddresses,
      const AddressSnapshot(addresses: [], selectedAddressId: ''),
    );
    final servicesFuture = _guard(
      serviceRepository.readServices,
      const <ServiceModel>[],
    );
    final bookingDraftFuture = _guard(bookingRepository.readDraft, null);
    final filterFuture = _guard(preferences.readLastServiceFilter, null);

    final pushNotifications = await pushFuture;
    final addressSnapshot = await addressFuture;
    final services = await servicesFuture;
    final bookingDraft = await bookingDraftFuture;
    final lastServiceFilter = await filterFuture;

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

    return CleanGoApp(
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
      pushNotifications: pushNotifications,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CleanGoApp>(
      future: _app,
      builder: (context, snapshot) {
        if (_app == null ||
            snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: const SplashPage(visualOnly: true),
            theme: AppTheme.light,
          );
        }
        if (snapshot.hasError || snapshot.data == null) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            home: _BootstrapError(
              snapshot.error?.toString() ?? 'Gagal memulai aplikasi.',
              onRetry: _startBootstrap,
            ),
          );
        }
        return snapshot.data!;
      },
    );
  }
}

/// Tampilan kesalahan bootstrap yang jelas agar pengguna tidak melihat layar hitam.
class _BootstrapError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _BootstrapError(this.message, {required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.redAccent,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Gagal memulai aplikasi',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: onRetry,
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
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

/// Inisialisasi Firebase sekali di Android, konfigurasi native default, dengan
/// timeout guard. Gagal ditangani dengan diagnosa tanpa kunci/token.
Future<PushNotifications?> _initializeFirebase(
  TokenStorage tokenStorage,
) async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return null;
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp().timeout(const Duration(seconds: 8));
    }
    final push = PushNotifications(
      transport: FcmTransport(),
      client: ApiClient(),
      httpClient: http.Client(),
      tokenStorage: tokenStorage,
    );
    await push.initialize();
    return push;
  } catch (_) {
    // Do not log Firebase errors that might include identifiers or tokens.
    return null;
  }
}
