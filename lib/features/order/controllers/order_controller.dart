import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../data/order_data.dart';
import '../data/eta_repository.dart';
import '../domain/models/order_model.dart';

class OrderController extends ChangeNotifier {
  OrderController({EtaRepository? etaRepository})
    : _etaRepository = etaRepository ?? EtaRepository() {
    _scheduledOrder = OrderData.scheduledOrder.copyWith(
      scheduledAt: DateTime.now().add(const Duration(days: 3)),
    );
    _history = List<OrderHistoryModel>.from(OrderData.history);
    _activeStage = OrderStatusStage.dikonfirmasi;
    _stageUpdatedAt[_activeStage] = DateTime.now();
    _resetTripTracking();
  }

  late ScheduledOrderModel _scheduledOrder;
  late List<OrderHistoryModel> _history;
  late OrderStatusStage _activeStage;
  bool _hasScheduledOrder = true;
  final EtaRepository _etaRepository;
  bool _etaLoading = false;
  bool _etaRefreshPending = false;
  String? _etaError;
  DateTime? _departedAt;
  DateTime? _lastLocationAt;
  double? _lastLatitude;
  double? _lastLongitude;
  double? _initialDistanceM;
  double _stoppedDurationSeconds = 0;
  double _rollingSpeedMps = 5.8;
  int _tripRevision = 0;
  final Map<OrderStatusStage, DateTime> _stageUpdatedAt = {};

  ScheduledOrderModel get scheduledOrder =>
      _scheduledOrder.copyWith(stage: _activeStage);
  OrderStatusStage get currentStage => _activeStage;
  int get currentStepNumber => _activeStage.index + 1;
  String get currentStepLabel => 'Langkah $currentStepNumber dari 5';
  List<OrderHistoryModel> get historyOrders => List.unmodifiable(_history);
  bool get hasScheduledOrder => _hasScheduledOrder;
  bool get etaLoading => _etaLoading;
  String? get etaError => _etaError;
  bool get isTravelStage =>
      _activeStage == OrderStatusStage.ditugaskan ||
      _activeStage == OrderStatusStage.dalamPerjalanan;
  bool get canCalculateEta =>
      isTravelStage && _scheduledOrder.hasDestinationCoordinates;
  bool get etaAvailable =>
      canCalculateEta && _scheduledOrder.etaUpdatedAt != null;

  String get etaHeadline {
    if (_activeStage == OrderStatusStage.dikonfirmasi) {
      return 'ETA tersedia setelah cleaner berangkat';
    }
    if (isTravelStage && !_scheduledOrder.hasDestinationCoordinates) {
      return 'Titik tujuan belum tersedia';
    }
    if (!isTravelStage) return 'Cleaner sudah tiba di lokasi';
    if (!etaAvailable) return 'Sedang menghitung rute cleaner…';
    return 'Cleaner tiba pukul ${_scheduledOrder.estimatedArrivalTime}';
  }

  String get etaDetail {
    if (_etaError != null) return _etaError!;
    if (_activeStage == OrderStatusStage.dikonfirmasi) {
      return 'Lokasi cleaner belum dibagikan.';
    }
    if (isTravelStage && !_scheduledOrder.hasDestinationCoordinates) {
      return 'Pilih titik alamat pada peta agar ETA dapat dihitung.';
    }
    if (!isTravelStage) return 'Perjalanan menuju pelanggan telah selesai.';
    final updatedAt = _scheduledOrder.etaUpdatedAt;
    if (updatedAt == null) return 'Menunggu koordinat dan rute pertama.';
    final time =
        '${updatedAt.hour.toString().padLeft(2, '0')}:${updatedAt.minute.toString().padLeft(2, '0')}:${updatedAt.second.toString().padLeft(2, '0')}';
    return '${_scheduledOrder.etaSource} · diperbarui $time';
  }

  String get etaMinutesLabel {
    if (_etaLoading) return 'Menghitung…';
    if (!etaAvailable) return 'Belum tersedia';
    return _scheduledOrder.estimatedMinutes;
  }

  String get etaCardTitle => isTravelStage
      ? _scheduledOrder.hasDestinationCoordinates
            ? 'Perkiraan Waktu Tiba'
            : 'Status ETA'
      : _activeStage == OrderStatusStage.dikonfirmasi
      ? 'Status ETA'
      : 'Status Kedatangan';

  String stageTimeLabel(OrderStatusStage stage) {
    if (stage.index > _activeStage.index) return 'Menunggu';
    if (stage == _activeStage && stage == OrderStatusStage.dalamPerjalanan) {
      return 'Sekarang';
    }
    final timestamp = _stageUpdatedAt[stage];
    if (timestamp == null) return 'Selesai';
    final clock = _formatClock(timestamp);
    if (stage == OrderStatusStage.sedangDikerjakan) return 'Mulai $clock';
    if (stage == OrderStatusStage.selesai) return 'Selesai $clock';
    return clock;
  }

  String stageDescription(OrderStatusStage stage) {
    return switch (stage) {
      OrderStatusStage.dikonfirmasi =>
        'Pesanan diterima dan dijadwalkan oleh sistem CleanGo.',
      OrderStatusStage.ditugaskan =>
        '${_scheduledOrder.cleanerName} ditugaskan dan bersiap berangkat.',
      OrderStatusStage.dalamPerjalanan =>
        '${_scheduledOrder.cleanerName} sedang menuju alamat Anda.',
      OrderStatusStage.sedangDikerjakan =>
        '${_scheduledOrder.serviceName} sedang dikerjakan.',
      OrderStatusStage.selesai =>
        '${_scheduledOrder.serviceName} telah selesai dikerjakan.',
    };
  }

  Future<void> refreshEta() async {
    if (!canCalculateEta) return;
    if (_etaLoading) {
      _etaRefreshPending = true;
      return;
    }
    _departedAt ??= DateTime.now();
    _etaLoading = true;
    _etaError = null;
    notifyListeners();
    try {
      final now = DateTime.now();
      final tripRevision = _tripRevision;
      final estimate = await _etaRepository.calculate(
        cleanerLatitude: _scheduledOrder.cleanerLatitude,
        cleanerLongitude: _scheduledOrder.cleanerLongitude,
        destinationLatitude: _scheduledOrder.destinationLatitude,
        destinationLongitude: _scheduledOrder.destinationLongitude,
        initialDistanceM: _initialDistanceM ?? 1,
        elapsedSeconds: math.max(
          0.0,
          now.difference(_departedAt!).inMilliseconds / 1000,
        ),
        stoppedDurationSeconds: _stoppedDurationSeconds,
        rollingSpeedMps: _rollingSpeedMps,
      );
      if (!canCalculateEta || tripRevision != _tripRevision) return;
      _initialDistanceM ??= estimate.distanceMeters.toDouble();
      final arrival = now.add(Duration(seconds: estimate.etaSeconds));
      _scheduledOrder = _scheduledOrder.copyWith(
        distanceKm:
            '${(estimate.distanceMeters / 1000).toStringAsFixed(1)} km lagi',
        estimatedMinutes: '±${estimate.etaMinutes} menit',
        estimatedArrivalTime:
            '${arrival.hour.toString().padLeft(2, '0')}:${arrival.minute.toString().padLeft(2, '0')} WIB',
        etaSource: estimate.source == 'ml'
            ? 'ML ${estimate.modelVersion ?? ''}'.trim()
            : 'Rute OSRM',
        etaUpdatedAt: estimate.updatedAt,
        routePoints: estimate.path,
        arrivalEstimate: 'Tiba ~${_formatClock(arrival)}',
        travelDescription:
            '${(estimate.distanceMeters / 1000).toStringAsFixed(1)} km lagi • ±${estimate.etaMinutes} menit',
      );
    } catch (_) {
      _etaError =
          'ETA belum dapat diperbarui. Data terakhir tetap ditampilkan.';
    } finally {
      _etaLoading = false;
      notifyListeners();
      if (_etaRefreshPending) {
        _etaRefreshPending = false;
        unawaited(refreshEta());
      }
    }
  }

  Future<void> updateCleanerLocation(
    double latitude,
    double longitude, {
    DateTime? recordedAt,
  }) async {
    if (!canCalculateEta) return;
    final timestamp = recordedAt ?? DateTime.now();
    if (_lastLocationAt != null &&
        _lastLatitude != null &&
        _lastLongitude != null) {
      final elapsed = math.max(
        0.001,
        timestamp.difference(_lastLocationAt!).inMilliseconds / 1000,
      );
      final distance = _distanceMeters(
        _lastLatitude!,
        _lastLongitude!,
        latitude,
        longitude,
      );
      final speed = distance / elapsed;
      _rollingSpeedMps = speed.clamp(0.0, 15.0).toDouble();
      if (_rollingSpeedMps < 0.5) {
        _stoppedDurationSeconds += elapsed;
      }
    }
    _lastLocationAt = timestamp;
    _lastLatitude = latitude;
    _lastLongitude = longitude;
    _scheduledOrder = _scheduledOrder.copyWith(
      cleanerLatitude: latitude,
      cleanerLongitude: longitude,
    );
    notifyListeners();
    await refreshEta();
  }

  void _startTripTracking() {
    final now = DateTime.now();
    _departedAt ??= now;
    _lastLocationAt ??= now;
    _lastLatitude ??= _scheduledOrder.cleanerLatitude;
    _lastLongitude ??= _scheduledOrder.cleanerLongitude;
  }

  void _resetTripTracking() {
    _tripRevision += 1;
    _departedAt = null;
    _lastLocationAt = null;
    _lastLatitude = null;
    _lastLongitude = null;
    _initialDistanceM = null;
    _stoppedDurationSeconds = 0;
    _rollingSpeedMps = 5.8;
    _etaError = null;
    _scheduledOrder = _scheduledOrder.copyWith(
      distanceKm: 'Menunggu keberangkatan',
      estimatedMinutes: 'Belum tersedia',
      estimatedArrivalTime: 'Belum tersedia',
      etaSource: 'Lokasi cleaner belum dibagikan',
      routePoints: const [],
      clearEtaUpdatedAt: true,
      arrivalEstimate: _confirmedArrivalLabel(_scheduledOrder.scheduledAt),
      travelDescription: 'Menunggu cleaner ditugaskan.',
    );
  }

  static double _distanceMeters(
    double latitudeA,
    double longitudeA,
    double latitudeB,
    double longitudeB,
  ) {
    const earthRadiusM = 6371000.0;
    final latitudeDelta = _toRadians(latitudeB - latitudeA);
    final longitudeDelta = _toRadians(longitudeB - longitudeA);
    final a =
        math.sin(latitudeDelta / 2) * math.sin(latitudeDelta / 2) +
        math.cos(_toRadians(latitudeA)) *
            math.cos(_toRadians(latitudeB)) *
            math.sin(longitudeDelta / 2) *
            math.sin(longitudeDelta / 2);
    return earthRadiusM * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180;

  bool get canModifyScheduledOrder {
    final schedule = _scheduledOrder.scheduledAt;
    if (!_hasScheduledOrder || schedule == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final serviceDay = DateTime(schedule.year, schedule.month, schedule.day);
    final minimumChangeableDay = today.add(const Duration(days: 2));
    return !serviceDay.isBefore(minimumChangeableDay) &&
        _activeStage.index <= OrderStatusStage.ditugaskan.index;
  }

  String get modificationDeadlineLabel {
    final schedule = _scheduledOrder.scheduledAt;
    if (schedule == null) return 'Perubahan tersedia maksimal H-1.';
    final deadline = schedule.subtract(const Duration(days: 1));
    return 'Bisa dibatalkan atau dijadwal ulang sebelum ${_formatDateTime(deadline)}.';
  }

  void setStage(OrderStatusStage stage) {
    final previousStage = _activeStage;
    _activeStage = stage;
    _stageUpdatedAt.removeWhere((key, _) => key.index > stage.index);
    if (stage != previousStage) {
      _stageUpdatedAt[stage] = DateTime.now();
    }
    if (stage == OrderStatusStage.dikonfirmasi) {
      _resetTripTracking();
    } else if (canCalculateEta) {
      if (stage == OrderStatusStage.ditugaskan &&
          previousStage.index > stage.index) {
        _resetTripTracking();
      }
      _startTripTracking();
    }
    _scheduledOrder = _scheduledOrder.copyWith(
      stage: stage,
      progress: stage.progress,
      status: stage.statusLabel,
      arrivalEstimate: _arrivalLabelForStage(stage),
      travelDescription: _travelDescriptionForStage(stage),
    );

    notifyListeners();
  }

  void nextStage() {
    if (_activeStage.index < OrderStatusStage.values.length - 1) {
      setStage(OrderStatusStage.values[_activeStage.index + 1]);
    }
  }

  bool rescheduleOrder(DateTime newSchedule) {
    if (!canModifyScheduledOrder ||
        newSchedule.isBefore(DateTime.now().add(const Duration(days: 1)))) {
      return false;
    }
    _scheduledOrder = _scheduledOrder.copyWith(
      scheduledAt: newSchedule,
      arrivalEstimate: _activeStage == OrderStatusStage.dikonfirmasi
          ? _confirmedArrivalLabel(newSchedule)
          : null,
    );
    notifyListeners();
    return true;
  }

  bool cancelScheduledOrder() {
    if (!canModifyScheduledOrder) return false;
    _history.insert(0, _toHistory(status: 'DIBATALKAN', canReview: false));
    _hasScheduledOrder = false;
    notifyListeners();
    return true;
  }

  void completeScheduledOrder() {
    setStage(OrderStatusStage.selesai);
    if (!_history.any((item) => item.orderId == _scheduledOrder.orderNumber)) {
      _history.insert(0, _toHistory(status: 'SELESAI', canReview: true));
    }
    _hasScheduledOrder = false;
    notifyListeners();
  }

  void submitReview({
    required String orderId,
    required int rating,
    required List<String> tags,
    required String comment,
    List<String> photos = const [],
  }) {
    final reviewModel = OrderReviewModel(
      orderId: orderId,
      rating: rating,
      satisfactionTags: tags,
      comment: comment,
      photoPaths: photos,
      createdAt: DateTime.now(),
    );

    bool matched = false;
    _history = _history.map((order) {
      if (order.orderId == orderId) {
        matched = true;
        return order.copyWith(
          canReview: false,
          rating: rating.toDouble(),
          review: reviewModel,
        );
      }
      return order;
    }).toList();

    if (!matched && orderId == _scheduledOrder.orderNumber) {
      _history.insert(
        0,
        OrderHistoryModel(
          orderId: _scheduledOrder.orderNumber,
          serviceName: _scheduledOrder.serviceName,
          serviceAssetPath: _scheduledOrder.serviceImagePath,
          schedule: 'Hari ini • Selesai',
          status: 'SELESAI',
          customerName: 'Krisna pratama',
          price: _scheduledOrder.price,
          canReview: false,
          rating: rating.toDouble(),
          cleanerName: _scheduledOrder.cleanerName,
          cleanerAvatarPath: _scheduledOrder.cleanerAvatarPath,
          review: reviewModel,
          address: _scheduledOrder.destinationAddress,
          note: _scheduledOrder.note,
          paymentMethod: _scheduledOrder.paymentMethod,
          servicePrice: _scheduledOrder.servicePrice,
          platformFee: _scheduledOrder.platformFee,
          discountAmount: _scheduledOrder.discountAmount,
        ),
      );
    }

    notifyListeners();
  }

  void createOrderFromBooking({
    required String serviceName,
    required String serviceImagePath,
    required String price,
    required String address,
    String destinationSubAddress = '',
    double? destinationLatitude,
    double? destinationLongitude,
    DateTime? scheduledAt,
    String note = '',
    String paymentMethod = 'QRIS',
    int servicePrice = 300000,
    int platformFee = 5000,
    int discountAmount = 0,
    String customerName = 'Krisna Pratama',
    String customerPhone = '(+62) 81223728077',
  }) {
    final createdAt = DateTime.now();
    _scheduledOrder = _scheduledOrder.copyWith(
      serviceName: serviceName,
      serviceImagePath: serviceImagePath,
      price: price,
      destinationAddress: address,
      destinationSubAddress: destinationSubAddress,
      destinationLatitude:
          destinationLatitude ?? _scheduledOrder.destinationLatitude,
      destinationLongitude:
          destinationLongitude ?? _scheduledOrder.destinationLongitude,
      hasDestinationCoordinates:
          destinationLatitude != null && destinationLongitude != null,
      orderNumber:
          '#CG-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      stage: OrderStatusStage.dikonfirmasi,
      progress: OrderStatusStage.dikonfirmasi.progress,
      status: OrderStatusStage.dikonfirmasi.statusLabel,
      arrivalEstimate: _confirmedArrivalLabel(scheduledAt),
      travelDescription: 'Menunggu cleaner ditugaskan.',
      scheduledAt: scheduledAt,
      note: note,
      paymentMethod: paymentMethod,
      servicePrice: servicePrice,
      platformFee: platformFee,
      discountAmount: discountAmount,
      customerName: customerName,
      customerPhone: customerPhone,
      paymentStatus: '$paymentMethod Terbayar',
      routePoints: const [],
      clearEtaUpdatedAt: true,
    );
    _activeStage = OrderStatusStage.dikonfirmasi;
    _stageUpdatedAt
      ..clear()
      ..[_activeStage] = createdAt;
    _resetTripTracking();
    _hasScheduledOrder = true;
    notifyListeners();
  }

  OrderHistoryModel _toHistory({
    required String status,
    required bool canReview,
  }) {
    return OrderHistoryModel(
      orderId: _scheduledOrder.orderNumber,
      serviceName: _scheduledOrder.serviceName,
      serviceAssetPath: _scheduledOrder.serviceImagePath,
      schedule: _scheduledOrder.scheduledAt == null
          ? 'Jadwal layanan'
          : _formatDateTime(_scheduledOrder.scheduledAt!),
      status: status,
      customerName: _scheduledOrder.customerName,
      price: _scheduledOrder.price,
      canReview: canReview,
      cleanerName: _scheduledOrder.cleanerName,
      cleanerAvatarPath: _scheduledOrder.cleanerAvatarPath,
      address: _scheduledOrder.destinationAddress,
      note: _scheduledOrder.note,
      paymentMethod: _scheduledOrder.paymentMethod,
      servicePrice: _scheduledOrder.servicePrice,
      platformFee: _scheduledOrder.platformFee,
      discountAmount: _scheduledOrder.discountAmount,
    );
  }

  static String _formatDateTime(DateTime value) {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '${days[value.weekday - 1]}, ${value.day} ${months[value.month - 1]} ${value.year} • $hour:$minute WIB';
  }

  String _arrivalLabelForStage(OrderStatusStage stage) {
    return switch (stage) {
      OrderStatusStage.dikonfirmasi => _confirmedArrivalLabel(
        _scheduledOrder.scheduledAt,
      ),
      OrderStatusStage.ditugaskan || OrderStatusStage.dalamPerjalanan =>
        !_scheduledOrder.hasDestinationCoordinates
            ? 'Titik tujuan belum tersedia'
            : etaAvailable
            ? 'Tiba ~${_scheduledOrder.estimatedArrivalTime}'
            : 'ETA sedang dihitung',
      OrderStatusStage.sedangDikerjakan => 'Cleaner sudah tiba',
      OrderStatusStage.selesai => 'Pekerjaan selesai',
    };
  }

  String _travelDescriptionForStage(OrderStatusStage stage) {
    return switch (stage) {
      OrderStatusStage.dikonfirmasi => 'Menunggu cleaner ditugaskan.',
      OrderStatusStage.ditugaskan || OrderStatusStage.dalamPerjalanan =>
        !_scheduledOrder.hasDestinationCoordinates
            ? 'Pilih titik alamat pada peta untuk menghitung ETA.'
            : etaAvailable
            ? '${_scheduledOrder.distanceKm} • ${_scheduledOrder.estimatedMinutes}'
            : stage.travelDescription,
      OrderStatusStage.sedangDikerjakan =>
        'Cleaner telah tiba dan pekerjaan sedang berlangsung.',
      OrderStatusStage.selesai => 'Pekerjaan telah dikonfirmasi selesai.',
    };
  }

  static String _confirmedArrivalLabel(DateTime? schedule) {
    if (schedule == null) return 'Jadwal belum ditentukan';
    final now = DateTime.now();
    if (schedule.year == now.year &&
        schedule.month == now.month &&
        schedule.day == now.day) {
      return 'Jadwal hari ini • ${_formatClock(schedule)}';
    }
    return 'Jadwal ${_formatDateTime(schedule)}';
  }

  static String _formatClock(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute WIB';
  }

  @override
  void dispose() {
    _etaRepository.dispose();
    super.dispose();
  }
}
