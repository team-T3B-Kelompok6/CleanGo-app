import 'package:flutter/foundation.dart';

import '../data/order_data.dart';
import '../domain/models/order_model.dart';

class OrderController extends ChangeNotifier {
  OrderController() {
    _scheduledOrder = OrderData.scheduledOrder.copyWith(
      scheduledAt: DateTime.now().add(const Duration(days: 3)),
    );
    _history = List<OrderHistoryModel>.from(OrderData.history);
    _activeStage = OrderStatusStage.dalamPerjalanan;
  }

  late ScheduledOrderModel _scheduledOrder;
  late List<OrderHistoryModel> _history;
  late OrderStatusStage _activeStage;
  bool _hasScheduledOrder = true;

  ScheduledOrderModel get scheduledOrder =>
      _scheduledOrder.copyWith(stage: _activeStage);
  OrderStatusStage get currentStage => _activeStage;
  int get currentStepNumber => _activeStage.index + 1;
  String get currentStepLabel => 'Langkah $currentStepNumber dari 5';
  List<OrderHistoryModel> get historyOrders => List.unmodifiable(_history);
  bool get hasScheduledOrder => _hasScheduledOrder;
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
    _activeStage = stage;
    double progress = 0.2;
    String status = 'DIKONFIRMASI';
    String arrival = 'Tiba ~09:30 WIB';
    String travelDesc = 'Pesanan terkonfirmasi, menunggu penugasan staf.';

    switch (stage) {
      case OrderStatusStage.dikonfirmasi:
        progress = 0.2;
        status = 'PESANAN DIKONFIRMASI';
        arrival = 'Tiba ~09:30 WIB';
        travelDesc = 'Pesanan diterima & diverifikasi sistem CleanGo.';
        break;
      case OrderStatusStage.ditugaskan:
        progress = 0.4;
        status = 'CLEANER DITUGASKAN';
        arrival = 'Tiba ~09:20 WIB';
        travelDesc = 'Cleaner Siti Rahmawati ditugaskan dan bersiap berangkat.';
        break;
      case OrderStatusStage.dalamPerjalanan:
        progress = 0.66;
        status = 'CLEANER MENUJU LOKASI';
        arrival = 'Tiba ~09:10 WIB';
        travelDesc = 'Estimasi waktu perjalanan sekitar 15 menit.';
        break;
      case OrderStatusStage.sedangDikerjakan:
        progress = 0.85;
        status = 'SEDANG DIKERJAKAN';
        arrival = 'Estimasi selesai 12:15 WIB';
        travelDesc = 'Pembersihan Deep Cleaning sedang berlangsung.';
        break;
      case OrderStatusStage.selesai:
        progress = 1.0;
        status = 'PESANAN SELESAI';
        arrival = 'Pengerjaan Selesai 12:15 WIB';
        travelDesc =
            'Pembersihan telah selesai dikerjakan dengan hasil optimal.';
        break;
    }

    _scheduledOrder = _scheduledOrder.copyWith(
      stage: stage,
      progress: progress,
      status: status,
      arrivalEstimate: arrival,
      travelDescription: travelDesc,
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
    _scheduledOrder = _scheduledOrder.copyWith(scheduledAt: newSchedule);
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
    DateTime? scheduledAt,
    String note = '',
    String paymentMethod = 'QRIS',
    int servicePrice = 300000,
    int platformFee = 5000,
    int discountAmount = 0,
    String customerName = 'Krisna Pratama',
    String customerPhone = '(+62) 81223728077',
  }) {
    _scheduledOrder = _scheduledOrder.copyWith(
      serviceName: serviceName,
      serviceImagePath: serviceImagePath,
      price: price,
      destinationAddress: address,
      destinationSubAddress: '',
      orderNumber:
          '#CG-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      stage: OrderStatusStage.dikonfirmasi,
      progress: 0.2,
      status: 'PESANAN DIKONFIRMASI',
      scheduledAt: scheduledAt,
      note: note,
      paymentMethod: paymentMethod,
      servicePrice: servicePrice,
      platformFee: platformFee,
      discountAmount: discountAmount,
      customerName: customerName,
      customerPhone: customerPhone,
      paymentStatus: '$paymentMethod Terbayar',
    );
    _activeStage = OrderStatusStage.dikonfirmasi;
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
    return '${days[value.weekday - 1]}, ${value.day} ${months[value.month - 1]} ${value.year} • $hour:$minute';
  }
}
