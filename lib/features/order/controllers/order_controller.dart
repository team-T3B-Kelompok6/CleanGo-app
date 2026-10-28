import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../booking/controllers/booking_controller.dart';
import '../../booking/data/customer_booking_api.dart';
import '../../booking/domain/models/review_photo_model.dart';
import '../../../core/network/api_exception.dart';
import '../data/order_data.dart';
import '../data/eta_repository.dart';
import '../domain/models/order_model.dart';

class OrderController extends ChangeNotifier {
  OrderController({
    EtaRepository? etaRepository,
    CustomerBookingApi? bookingApi,
  }) : _etaRepository = etaRepository ?? EtaRepository(),
       _bookingApi = bookingApi {
    _selected = _ActiveOrderState(
      OrderData.scheduledOrder.copyWith(
        scheduledAt: DateTime.now().add(const Duration(days: 3)),
      ),
    );
    _orders[_scheduledOrder.orderNumber] = _selected;
    _history = List<OrderHistoryModel>.from(OrderData.history);
    _stageUpdatedAt[_activeStage] = DateTime.now();
    _resetTripTracking();
  }

  late _ActiveOrderState _selected;
  final Map<String, _ActiveOrderState> _orders = {};
  late List<OrderHistoryModel> _history;
  final EtaRepository _etaRepository;
  final CustomerBookingApi? _bookingApi;
  bool _disposed = false;
  bool _reviewPhotoUploadFailed = false;
  // shortcut: IDs are unique in this local session; use backend IDs on integration.
  int _nextOrderNumber = DateTime.now().millisecondsSinceEpoch % 1000000;

  ScheduledOrderModel get _scheduledOrder => _selected.order;
  set _scheduledOrder(ScheduledOrderModel order) => _selected.order = order;
  OrderStatusStage get _activeStage => _scheduledOrder.stage;
  Map<OrderStatusStage, DateTime> get _stageUpdatedAt =>
      _selected.stageUpdatedAt;
  bool get _hasSelectedOrder =>
      _orders.containsKey(_scheduledOrder.orderNumber);

  ScheduledOrderModel get scheduledOrder => _scheduledOrder;
  List<ScheduledOrderModel> get scheduledOrders => List.unmodifiable(
    _orders.values.toList().reversed.map((state) => state.order),
  );
  OrderStatusStage get currentStage => _activeStage;
  int get currentStepNumber => _activeStage.index + 1;
  String get currentStepLabel => 'Langkah $currentStepNumber dari 5';
  List<OrderHistoryModel> get historyOrders => List.unmodifiable(_history);
  bool get reviewPhotoUploadFailed => _reviewPhotoUploadFailed;
  bool get hasScheduledOrder => _orders.isNotEmpty;
  bool get etaLoading => _selected.etaLoading;
  String? get etaError => _selected.etaError;
  bool get isTravelStage =>
      _activeStage == OrderStatusStage.ditugaskan ||
      _activeStage == OrderStatusStage.dalamPerjalanan;
  bool get canCalculateEta =>
      isTravelStage &&
      _scheduledOrder.hasDestinationCoordinates &&
      (_scheduledOrder.backendBookingId == null ||
          _activeStage == OrderStatusStage.dalamPerjalanan);
  bool get etaAvailable =>
      canCalculateEta && _scheduledOrder.etaUpdatedAt != null;
  DateTime? get estimatedWorkCompletedAt {
    if (_activeStage != OrderStatusStage.sedangDikerjakan) return null;
    final started = _scheduledOrder.workStartedAt;
    final minutes = _scheduledOrder.serviceDurationMinutes;
    if (started == null || minutes == null || minutes <= 0) return null;
    return started.add(Duration(minutes: minutes));
  }

  String get etaHeadline {
    if (_activeStage == OrderStatusStage.sedangDikerjakan) {
      final completed = estimatedWorkCompletedAt;
      return completed == null
          ? 'Menunggu waktu mulai dan durasi layanan'
          : 'Perkiraan selesai ${_formatClock(completed)}';
    }
    if (_activeStage == OrderStatusStage.dikonfirmasi ||
        (_scheduledOrder.backendBookingId != null &&
            _activeStage == OrderStatusStage.ditugaskan)) {
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
    if (_activeStage == OrderStatusStage.sedangDikerjakan) {
      final completed = estimatedWorkCompletedAt;
      if (completed == null) {
        return 'Estimasi tersedia setelah waktu mulai dan durasi layanan tercatat.';
      }
      return DateTime.now().isAfter(completed)
          ? 'Perkiraan waktu terlewati. Menunggu konfirmasi selesai dari cleaner.'
          : 'Perkiraan dari waktu mulai dan durasi layanan. Selesai dikonfirmasi cleaner.';
    }
    if (etaError != null) return etaError!;
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
    if (_activeStage == OrderStatusStage.sedangDikerjakan) {
      final completed = estimatedWorkCompletedAt;
      return completed == null ? 'Belum tersedia' : _formatClock(completed);
    }
    if (etaLoading) return 'Menghitung…';
    if (!etaAvailable) return 'Belum tersedia';
    return _scheduledOrder.estimatedMinutes;
  }

  String get etaCardTitle => _activeStage == OrderStatusStage.sedangDikerjakan
      ? 'Perkiraan Selesai'
      : isTravelStage
      ? _scheduledOrder.hasDestinationCoordinates
            ? 'Perkiraan Waktu Tiba'
            : 'Status ETA'
      : _activeStage == OrderStatusStage.dikonfirmasi
      ? 'Status ETA'
      : 'Status Kedatangan';

  String stageTimeLabel(OrderStatusStage stage) {
    if (stage == OrderStatusStage.selesai && estimatedWorkCompletedAt != null) {
      return 'Estimasi ${_formatClock(estimatedWorkCompletedAt!)}';
    }
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

  bool selectScheduledOrder(String orderNumber) {
    final order = _orders[orderNumber];
    if (order == null) return false;
    if (identical(order, _selected)) return true;
    _selected = order;
    notifyListeners();
    return true;
  }

  Future<void> refreshEta() async {
    if (_disposed || !_hasSelectedOrder || !canCalculateEta) return;
    final selected = _selected;
    if (selected.etaLoading) {
      selected.etaRefreshPending = true;
      return;
    }
    selected.etaLoading = true;
    selected.etaError = null;
    notifyListeners();
    try {
      final now = DateTime.now();
      final tripRevision = selected.tripRevision;
      final bookingId = _scheduledOrder.backendBookingId;
      final estimate = bookingId != null
          ? await _etaRepository.calculateForBooking(bookingId)
          : await _etaRepository.calculate(
              cleanerLatitude: _scheduledOrder.cleanerLatitude,
              cleanerLongitude: _scheduledOrder.cleanerLongitude,
              destinationLatitude: _scheduledOrder.destinationLatitude,
              destinationLongitude: _scheduledOrder.destinationLongitude,
            );
      if (_disposed ||
          !identical(selected, _selected) ||
          !_hasSelectedOrder ||
          !canCalculateEta ||
          tripRevision != selected.tripRevision) {
        return;
      }
      final arrival =
          estimate.estimatedArrivalAt ??
          now.add(Duration(seconds: estimate.etaSeconds));
      _scheduledOrder = _scheduledOrder.copyWith(
        cleanerLatitude: estimate.cleanerLatitude,
        cleanerLongitude: estimate.cleanerLongitude,
        hasCleanerCoordinates:
            estimate.cleanerLatitude != null || bookingId == null,
        distanceKm:
            '${(estimate.distanceMeters / 1000).toStringAsFixed(1)} km lagi',
        estimatedMinutes: '±${estimate.etaMinutes} menit',
        estimatedArrivalTime:
            '${arrival.hour.toString().padLeft(2, '0')}:${arrival.minute.toString().padLeft(2, '0')} WIB',
        etaSource: 'Perhitungan rute OSRM',
        etaUpdatedAt: estimate.updatedAt,
        routePoints: estimate.path,
        arrivalEstimate: 'Tiba ~${_formatClock(arrival)}',
        travelDescription:
            '${(estimate.distanceMeters / 1000).toStringAsFixed(1)} km lagi • ±${estimate.etaMinutes} menit',
      );
    } catch (error) {
      selected.etaError =
          error is ApiException && error.code == 'TRACKING_NOT_READY'
          ? error.message
          : 'ETA belum dapat diperbarui. Data terakhir tetap ditampilkan.';
    } finally {
      selected.etaLoading = false;
      final refreshPending = selected.etaRefreshPending;
      selected.etaRefreshPending = false;
      if (!_disposed && identical(selected, _selected)) notifyListeners();
      if (!_disposed && identical(selected, _selected) && refreshPending) {
        unawaited(refreshEta());
      }
    }
  }

  Future<void> updateCleanerLocation(double latitude, double longitude) async {
    if (_scheduledOrder.backendBookingId != null) return;
    if (_disposed || !_hasSelectedOrder || !canCalculateEta) return;
    _scheduledOrder = _scheduledOrder.copyWith(
      cleanerLatitude: latitude,
      cleanerLongitude: longitude,
    );
    notifyListeners();
    await refreshEta();
  }

  void _resetTripTracking() {
    _selected.tripRevision += 1;
    _selected.etaError = null;
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

  bool get canModifyScheduledOrder {
    final schedule = _scheduledOrder.scheduledAt;
    if (!_hasSelectedOrder || schedule == null) return false;
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
    if (!_hasSelectedOrder || _scheduledOrder.backendBookingId != null) return;
    final previousStage = _activeStage;
    _scheduledOrder = _scheduledOrder.copyWith(stage: stage);
    _stageUpdatedAt.removeWhere((key, _) => key.index > stage.index);
    if (stage != previousStage) {
      _stageUpdatedAt[stage] = DateTime.now();
      if (stage == OrderStatusStage.sedangDikerjakan) {
        _scheduledOrder = _scheduledOrder.copyWith(
          workStartedAt: _stageUpdatedAt[stage],
        );
      }
    }
    if (stage == OrderStatusStage.dikonfirmasi) {
      _resetTripTracking();
    } else if (canCalculateEta) {
      if (stage == OrderStatusStage.ditugaskan &&
          previousStage.index > stage.index) {
        _resetTripTracking();
      }
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
    _orders.remove(_scheduledOrder.orderNumber);
    notifyListeners();
    return true;
  }

  void completeScheduledOrder() {
    if (!_hasSelectedOrder || _scheduledOrder.backendBookingId != null) return;
    setStage(OrderStatusStage.selesai);
    if (!_history.any((item) => item.orderId == _scheduledOrder.orderNumber)) {
      _history.insert(0, _toHistory(status: 'SELESAI', canReview: true));
    }
    _orders.remove(_scheduledOrder.orderNumber);
    notifyListeners();
  }

  Future<bool> submitReview({
    required String orderId,
    required int rating,
    required List<String> tags,
    required String comment,
    List<ReviewPhotoModel> photos = const [],
    List<String> removedPhotoIds = const [],
  }) async {
    if (rating < 1 || rating > 5 || photos.length > 3) return false;
    final matching = _history.where((order) => order.orderId == orderId);
    final existing = matching.isEmpty ? null : matching.first;
    if (existing != null && !existing.canReview) return false;
    if (existing == null &&
        (orderId != _scheduledOrder.orderNumber ||
            _activeStage != OrderStatusStage.selesai)) {
      return false;
    }
    final bookingId =
        existing?.backendBookingId ?? _scheduledOrder.backendBookingId;
    final api = _bookingApi;
    _reviewPhotoUploadFailed = false;
    var savedPhotos = List<ReviewPhotoModel>.from(photos);

    if (api != null && bookingId != null) {
      try {
        if (existing?.hasReview == true) {
          await api.updateReview(
            bookingId: bookingId,
            rating: rating,
            comment: comment,
          );
        } else {
          await api.createReview(
            bookingId: bookingId,
            rating: rating,
            comment: comment,
          );
        }
      } catch (_) {
        return false;
      }

      for (final photoId in removedPhotoIds) {
        if (photoId.isEmpty) continue;
        try {
          await api.deleteReviewPhoto(bookingId: bookingId, photoId: photoId);
        } catch (_) {
          _reviewPhotoUploadFailed = true;
        }
      }

      final uploaded = <ReviewPhotoModel>[];
      for (final photo in photos) {
        final bytes = photo.bytes;
        if (!photo.isNew || bytes == null) {
          uploaded.add(photo);
          continue;
        }
        try {
          uploaded.add(
            await api.uploadReviewPhoto(
              bookingId: bookingId,
              bytes: bytes,
              contentType: photo.contentType ?? 'image/jpeg',
            ),
          );
        } catch (_) {
          _reviewPhotoUploadFailed = true;
        }
      }
      savedPhotos = uploaded;
    }

    final reviewModel = OrderReviewModel(
      orderId: orderId,
      rating: rating,
      satisfactionTags: tags,
      comment: comment,
      photos: savedPhotos,
      createdAt: DateTime.now(),
    );

    bool matched = false;
    _history = _history.map((order) {
      if (order.orderId == orderId) {
        matched = true;
        return order.copyWith(
          canReview: true,
          hasReview: true,
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
          customerName: _scheduledOrder.customerName,
          price: _scheduledOrder.price,
          canReview: true,
          hasReview: true,
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
          backendBookingId: _scheduledOrder.backendBookingId,
        ),
      );
    }

    notifyListeners();
    return true;
  }

  /// Loads the customer's bookings from the backend and replaces the demo data.
  /// Keeps the bundled demo orders when the request fails or returns nothing.
  Future<void> loadFromApi() async {
    final api = _bookingApi;
    if (api == null) return;
    try {
      final bookings = await api.fetchBookings();
      if (bookings.isEmpty) return;

      final active = bookings.where((b) => !b.isFinished).toList();
      final finished = bookings.where((b) => b.isFinished).toList();

      if (active.isNotEmpty) {
        _orders.clear();
        for (final booking in active) {
          final state = _ActiveOrderState(_fromBooking(booking));
          _orders[state.order.orderNumber] = state;
        }
        _selected = _orders.values.last;
        _stageUpdatedAt
          ..clear()
          ..[_activeStage] = DateTime.now();
        _resetTripTracking();
      }

      if (finished.isNotEmpty) {
        _history = finished.map(_historyFromBooking).toList(growable: false);
      }
      notifyListeners();
    } catch (_) {
      // offline / no session: keep the bundled demo orders
    }
  }

  static OrderStatusStage _stageFor(String status) {
    switch (status) {
      case 'Menunggu Lokasi':
        return OrderStatusStage.ditugaskan;
      case 'Menuju Lokasi':
        return OrderStatusStage.dalamPerjalanan;
      case 'Sedang Dikerjakan':
        return OrderStatusStage.sedangDikerjakan;
      case 'Selesai':
        return OrderStatusStage.selesai;
      case 'Dibatalkan':
      case 'Batal':
      case 'Dijadwalkan Ulang':
        return OrderStatusStage.dikonfirmasi;
      case 'Menunggu Assign':
        return OrderStatusStage.dikonfirmasi;
      default:
        return OrderStatusStage.dikonfirmasi;
    }
  }

  static String _paymentLabel(String? status, String bookingStatus) {
    switch (status) {
      case 'paid':
        return 'Lunas';
      case 'pending':
        return 'Menunggu pembayaran';
      case 'failed':
        return 'Pembayaran gagal';
      case 'expired':
        return 'Pembayaran kedaluwarsa';
      default:
        return bookingStatus == 'Selesai' ? 'Lunas (tunai)' : 'Belum dibayar';
    }
  }

  ScheduledOrderModel _fromBooking(CustomerBookingSummary booking) {
    final stage = _stageFor(booking.status);
    return OrderData.scheduledOrder.copyWith(
      backendBookingId: booking.id,
      hasCleanerCoordinates: false,
      serviceName: booking.service,
      serviceDurationMinutes: booking.serviceDurationMinutes,
      workStartedAt: booking.startedAt,
      price: BookingController.formatRupiah(booking.totalAmount),
      cleanerName: booking.cleanerName,
      customerName: booking.recipientName,
      customerPhone: booking.recipientPhone,
      paymentStatus: _paymentLabel(booking.paymentStatus, booking.status),
      orderNumber: '#${booking.code}',
      stage: stage,
      progress: stage.progress,
      status: stage.statusLabel,
      arrivalEstimate: booking.status == 'Menunggu Assign'
          ? 'Menunggu penugasan cleaner'
          : 'Menunggu pembaruan lokasi',
      travelDescription: 'Status pesanan: ${booking.status}.',
      scheduledAt: booking.scheduledAt,
      note: booking.notes,
      destinationAddress: booking.address,
      destinationSubAddress: booking.landmark,
      destinationLatitude: booking.latitude,
      destinationLongitude: booking.longitude,
      hasDestinationCoordinates:
          booking.latitude != null && booking.longitude != null,
      servicePrice: booking.servicePrice,
      platformFee: booking.platformFee,
      discountAmount: booking.discountAmount,
      routePoints: const [],
      clearEtaUpdatedAt: true,
    );
  }

  OrderHistoryModel _historyFromBooking(CustomerBookingSummary booking) {
    final scheduled = booking.scheduledAt;
    return OrderHistoryModel(
      orderId: '#${booking.code}',
      serviceName: booking.service,
      serviceAssetPath: OrderData.scheduledOrder.serviceImagePath,
      schedule: scheduled == null
          ? 'Jadwal layanan'
          : _formatDateTime(scheduled),
      status: booking.status.toUpperCase(),
      customerName: booking.recipientName,
      cleanerName: booking.cleanerName,
      price: BookingController.formatRupiah(booking.totalAmount),
      canReview: booking.reviewEditable,
      hasReview: booking.hasReview,
      backendBookingId: booking.id,
      rating: booking.reviewRating?.toDouble(),
      review: booking.hasReview
          ? OrderReviewModel(
              orderId: '#${booking.code}',
              rating: booking.reviewRating ?? 0,
              satisfactionTags: const [],
              comment: booking.reviewComment ?? '',
              photos: booking.reviewPhotos,
              createdAt: DateTime.now(),
            )
          : null,
      address: booking.address,
      note: booking.notes,
      servicePrice: booking.servicePrice,
      platformFee: booking.platformFee,
      discountAmount: booking.discountAmount,
    );
  }

  void createOrderFromBooking({
    int? serviceDurationMinutes,
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
    String customerName = '',
    String customerPhone = '',
  }) {
    final createdAt = DateTime.now();
    _selected = _ActiveOrderState(
      OrderData.scheduledOrder.copyWith(
        serviceDurationMinutes: serviceDurationMinutes,
        serviceName: serviceName,
        serviceImagePath: serviceImagePath,
        price: price,
        destinationAddress: address,
        destinationSubAddress: destinationSubAddress,
        destinationLatitude: destinationLatitude,
        destinationLongitude: destinationLongitude,
        hasDestinationCoordinates:
            destinationLatitude != null && destinationLongitude != null,
        orderNumber: '#CG-${(_nextOrderNumber++).toString().padLeft(6, '0')}',
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
        paymentStatus: paymentMethod == 'Tunai'
            ? 'Tunai · Bayar di lokasi'
            : '$paymentMethod Terbayar',
        routePoints: const [],
        clearEtaUpdatedAt: true,
      ),
    );
    _orders[_scheduledOrder.orderNumber] = _selected;
    _stageUpdatedAt
      ..clear()
      ..[_activeStage] = createdAt;
    _resetTripTracking();
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
    _disposed = true;
    _etaRepository.dispose();
    super.dispose();
  }
}

class _ActiveOrderState {
  _ActiveOrderState(this.order);

  ScheduledOrderModel order;
  final Map<OrderStatusStage, DateTime> stageUpdatedAt = {};
  bool etaLoading = false;
  bool etaRefreshPending = false;
  String? etaError;
  int tripRevision = 0;
}
