import 'dart:convert';

import 'package:cleango_app/core/database/app_database.dart';
import 'package:cleango_app/features/service/data/service_repository.dart';
import 'package:cleango_app/features/service/domain/models/service_model.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;

  setUp(() => database = AppDatabase(NativeDatabase.memory()));
  tearDown(() => database.close());

  test('cache layanan tersedia saat remote gagal', () async {
    final backendService = ServiceModel(
      id: '101',
      title: 'Layanan Backend',
      description: 'Data dari API',
      duration: '1 jam',
      price: 'Rp100.000',
      category: 'Rumah',
      imagePath: 'assets/images/service_rumah.jpeg',
      popularity: 5,
      reviewCount: 12,
      releaseOrder: 0,
      detail: ServiceDetailModel(
        heroImagePath: 'assets/images/service_rumah.jpeg',
        description: 'Detail backend',
        rating: '4.5',
        reviewCount: '12',
        satisfactionPercentage: 90,
        benefits: <String>['Bersih', 'Cepat'],
        reviews: <ServiceReviewModel>[
          ServiceReviewModel(
            name: 'Pengguna',
            comment: 'Layanan bagus',
            rating: 5,
            date: '2026-01-01',
            avatarUrl: null,
            imagePaths: <String>[],
          ),
        ],
      ),
    );
    final repository = ServiceRepository(database, remote: _FailingRemote());
    await repository.seedDefaultsIfEmpty([backendService]);

    await expectLater(repository.refresh(), throwsException);
    final cached = await repository.readServices();

    expect(cached, hasLength(1));
    expect(cached.first.id, '101');
    expect(cached.first.detail?.reviews, isNotEmpty);
  });

  test('respons remote memperbarui stream cache secara atomik', () async {
    const remoteServices = [
      ServiceModel(
        id: 'remote-service',
        title: 'Layanan Remote',
        description: 'Data terbaru',
        duration: '1 jam',
        price: 'Rp100.000',
        category: 'Rumah',
        imagePath: 'assets/images/service_deep_cleaning.jpeg',
      ),
    ];
    final repository = ServiceRepository(
      database,
      remote: _SuccessfulRemote(remoteServices),
    );
    final emission = repository.watchServices().firstWhere(
      (services) => services.any((service) => service.id == 'remote-service'),
    );

    expect(await repository.refresh(), isTrue);
    expect((await emission).single.title, 'Layanan Remote');
  });

  test('cache menyimpan reviewCount dan popularity melalui siklus simpan-baca', () async {
    final services = [
      ServiceModel(
        id: 'cached-review',
        title: 'Layanan Cache',
        description: 'Data tersimpan',
        duration: '1 jam',
        price: 'Rp100.000',
        category: 'Rumah',
        imagePath: 'assets/images/service_rumah.jpeg',
        popularity: 9,
        reviewCount: 14,
      ),
    ];
    final repository = ServiceRepository(database);
    await repository.seedDefaultsIfEmpty(services);

    final cached = await repository.readServices();
    expect(cached, hasLength(1));
    expect(cached.first.popularity, 9);
    expect(cached.first.reviewCount, 14);
  });

  test('cache lama tanpa reviewCount dibaca sebagai nol', () async {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await database.replaceServiceCache([
      ServiceCachesCompanion.insert(
        sortOrder: 0,
        id: 'legacy-service',
        payload: jsonEncode({
          'id': 'legacy-service',
          'title': 'Lama',
          'description': '',
          'duration': '1 jam',
          'durationMinutes': 60,
          'price': 'Rp0',
          'category': 'Rumah',
          'imagePath': null,
          'iconPath': 'assets/icons/rumah.svg',
          'badge': null,
          'rating': null,
          'popularity': 2,
          'releaseOrder': 0,
        }),
        synced: const Value(true),
        lastFetched: now,
        updatedAt: now,
      ),
    ]);

    final repository = ServiceRepository(database);
    final cached = await repository.readServices();

    expect(cached, hasLength(1));
    expect(cached.first.reviewCount, 0);
  });

  test('remote aktif dan cache hanya legacy menghasilkan daftar kosong', () async {
    final legacyServices = <ServiceModel>[
      ServiceModel(
        id: 'deep-cleaning',
        title: 'Deep Cleaning',
        description: 'Legacy seed',
        duration: '1 jam',
        price: 'Rp100.000',
        category: 'Rumah',
        imagePath: 'assets/images/service_deep_cleaning.jpeg',
      ),
      ServiceModel(
        id: 'ac-care',
        title: 'AC Care',
        description: 'Legacy seed',
        duration: '1 jam',
        price: 'Rp150.000',
        category: 'Rumah',
        imagePath: 'assets/images/service_ac.jpeg',
      ),
    ];
    final repository = ServiceRepository(
      database,
      remote: _SuccessfulRemote(<ServiceModel>[]),
    );
    await repository.seedDefaultsIfEmpty(legacyServices);
    final cached = await repository.readServices();

    expect(cached, isEmpty);
  });

  test('remote aktif dan cache campuran hanya non-legacy', () async {
    final services = <ServiceModel>[
      ServiceModel(
        id: 'deep-cleaning',
        title: 'Deep Cleaning',
        description: 'Legacy seed',
        duration: '1 jam',
        price: 'Rp100.000',
        category: 'Rumah',
        imagePath: 'assets/images/service_deep_cleaning.jpeg',
      ),
      ServiceModel(
        id: '102',
        title: 'Layanan Backend',
        description: 'Non legacy',
        duration: '1 jam',
        price: 'Rp100.000',
        category: 'Rumah',
        imagePath: 'assets/images/service_rumah.jpeg',
      ),
    ];
    final repository = ServiceRepository(
      database,
      remote: _SuccessfulRemote(<ServiceModel>[]),
    );
    await repository.seedDefaultsIfEmpty(services);
    final cached = await repository.readServices();

    expect(cached, hasLength(1));
    expect(cached.first.id, '102');
  });
}

class _SuccessfulRemote implements ServiceRemoteDataSource {
  const _SuccessfulRemote(this.services);

  final List<ServiceModel> services;

  @override
  Future<List<ServiceModel>> fetchServices() async => services;
}

class _FailingRemote implements ServiceRemoteDataSource {
  @override
  Future<List<ServiceModel>> fetchServices() {
    throw Exception('Tidak ada koneksi');
  }
}
