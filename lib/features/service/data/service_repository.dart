import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/models/service_model.dart';

abstract interface class ServiceRemoteDataSource {
  Future<List<ServiceModel>> fetchServices();
}

class ServiceRepository {
  ServiceRepository(this._database, {this.remote});

  final AppDatabase _database;
  final ServiceRemoteDataSource? remote;

  Stream<List<ServiceModel>> watchServices() {
    return _database.watchServiceCache().map(_decodeRows);
  }

  Future<List<ServiceModel>> readServices() async {
    return _decodeRows(await _database.readServiceCache());
  }

  Future<void> seedDefaultsIfEmpty(List<ServiceModel> services) {
    return _database.seedServiceCacheIfEmpty(_companions(services));
  }

  Future<bool> refresh() async {
    final source = remote;
    if (source == null) return false;
    final services = await source.fetchServices();
    await _database.replaceServiceCache(_companions(services));
    return true;
  }

  List<ServiceCachesCompanion> _companions(List<ServiceModel> services) {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    return services.indexed
        .map(
          (entry) => ServiceCachesCompanion.insert(
            sortOrder: entry.$1,
            id: entry.$2.id,
            payload: jsonEncode(_toJson(entry.$2)),
            synced: const Value(true),
            lastFetched: now,
            updatedAt: now,
          ),
        )
        .toList(growable: false);
  }

  List<ServiceModel> _decodeRows(List<ServiceCacheRow> rows) {
    return rows
        .map(
          (row) => _fromJson(
            Map<String, Object?>.from(jsonDecode(row.payload) as Map),
          ),
        )
        .toList(growable: false);
  }

  Map<String, Object?> _toJson(ServiceModel service) => {
    'id': service.id,
    'title': service.title,
    'description': service.description,
    'duration': service.duration,
    'durationMinutes': service.durationMinutes,
    'price': service.price,
    'category': service.category,
    'imagePath': service.imagePath,
    'iconPath': service.iconPath,
    'badge': service.badge,
    'rating': service.rating,
    'popularity': service.popularity,
    'releaseOrder': service.releaseOrder,
    'detail': service.detail == null ? null : _detailToJson(service.detail!),
  };

  Map<String, Object?> _detailToJson(ServiceDetailModel detail) => {
    'heroImagePath': detail.heroImagePath,
    'description': detail.description,
    'rating': detail.rating,
    'reviewCount': detail.reviewCount,
    'satisfactionPercentage': detail.satisfactionPercentage,
    'benefits': detail.benefits,
    'reviews': detail.reviews
        .map(
          (review) => {
            'name': review.name,
            'comment': review.comment,
            'rating': review.rating,
            'date': review.date,
            'avatarUrl': review.avatarUrl,
            'imagePaths': review.imagePaths,
          },
        )
        .toList(growable: false),
  };

  ServiceModel _fromJson(Map<String, Object?> json) {
    final detailJson = json['detail'];
    return ServiceModel(
      id: json['id']! as String,
      title: json['title']! as String,
      description: json['description']! as String,
      duration: json['duration']! as String,
      durationMinutes: json['durationMinutes'] as int?,
      price: json['price']! as String,
      category: json['category']! as String,
      imagePath: json['imagePath'] as String?,
      iconPath: json['iconPath'] as String?,
      badge: json['badge'] as String?,
      rating: json['rating'] as String?,
      popularity: json['popularity']! as int,
      releaseOrder: json['releaseOrder']! as int,
      detail: detailJson == null
          ? null
          : _detailFromJson(Map<String, Object?>.from(detailJson as Map)),
    );
  }

  ServiceDetailModel _detailFromJson(Map<String, Object?> json) {
    return ServiceDetailModel(
      heroImagePath: json['heroImagePath']! as String,
      description: json['description']! as String,
      rating: json['rating']! as String,
      reviewCount: json['reviewCount']! as String,
      satisfactionPercentage: json['satisfactionPercentage']! as int,
      benefits: (json['benefits']! as List).cast<String>(),
      reviews: (json['reviews']! as List)
          .map((raw) {
            final review = Map<String, Object?>.from(raw as Map);
            return ServiceReviewModel(
              name: review['name']! as String,
              comment: review['comment']! as String,
              rating: review['rating']! as int,
              date: review['date']! as String,
              avatarUrl: review['avatarUrl'] as String?,
              imagePaths: (review['imagePaths']! as List).cast<String>(),
            );
          })
          .toList(growable: false),
    );
  }
}
