import 'package:cleango_app/core/database/app_database.dart';
import 'package:cleango_app/features/service/data/service_data.dart';
import 'package:cleango_app/features/service/data/service_repository.dart';
import 'package:cleango_app/features/service/domain/models/service_model.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;

  setUp(() => database = AppDatabase(NativeDatabase.memory()));
  tearDown(() => database.close());

  test('cache layanan tersedia saat remote gagal', () async {
    final repository = ServiceRepository(database, remote: _FailingRemote());
    await repository.seedDefaultsIfEmpty(ServiceData.services);

    await expectLater(repository.refresh(), throwsException);
    final cached = await repository.readServices();

    expect(cached, hasLength(ServiceData.services.length));
    expect(
      cached.map((service) => service.id),
      ServiceData.services.map((service) => service.id),
    );
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
