enum OrderStatusStage {
  dikonfirmasi,
  ditugaskan,
  dalamPerjalanan,
  sedangDikerjakan,
  selesai,
}

extension OrderStatusStageExtension on OrderStatusStage {
  int get stepNumber => index + 1;

  String get title {
    switch (this) {
      case OrderStatusStage.dikonfirmasi:
        return 'Dikonfirmasi';
      case OrderStatusStage.ditugaskan:
        return 'Ditugaskan & Berangkat';
      case OrderStatusStage.dalamPerjalanan:
        return 'Dalam Perjalanan';
      case OrderStatusStage.sedangDikerjakan:
        return 'Sedang Dikerjakan';
      case OrderStatusStage.selesai:
        return 'Selesai';
    }
  }

  String get timeLabel {
    switch (this) {
      case OrderStatusStage.dikonfirmasi:
        return '08:45 WIB';
      case OrderStatusStage.ditugaskan:
        return '08:52 WIB';
      case OrderStatusStage.dalamPerjalanan:
        return 'Sekarang';
      case OrderStatusStage.sedangDikerjakan:
        return 'Estimasi 09:15';
      case OrderStatusStage.selesai:
        return 'Estimasi 12:15';
    }
  }

  String get description {
    switch (this) {
      case OrderStatusStage.dikonfirmasi:
        return 'Pesanan diterima & diverifikasi sistem CleanGo.';
      case OrderStatusStage.ditugaskan:
        return 'Cleaner ditugaskan oleh Admin dan berangkat dari operasional CleanGo.';
      case OrderStatusStage.dalamPerjalanan:
        return 'Cleaner sedang berkendara menuju alamat Anda.';
      case OrderStatusStage.sedangDikerjakan:
        return 'Pembersihan Deep Cleaning dimulai setelah verifikasi alamat.';
      case OrderStatusStage.selesai:
        return 'Pengecekan kualitas kerja dan konfirmasi selesai.';
    }
  }
}

class ScheduledOrderModel {
  const ScheduledOrderModel({
    required this.status,
    required this.arrivalEstimate,
    required this.travelDescription,
    required this.progress,
    required this.serviceName,
    required this.serviceImagePath,
    required this.orderNumber,
    required this.price,
    required this.paymentStatus,
    this.stage = OrderStatusStage.dalamPerjalanan,
    this.cleanerName = 'Siti Rahmawati',
    this.cleanerRating = 4.9,
    this.cleanerCompletedTasks = '340+ tugas selesai',
    this.cleanerAvatarPath = 'assets/images/cleaner_siti.jpeg',
    this.cleanerPhone = '+62 812-3456-7890',
    this.destinationAddress = 'Blk. N No.521, Mojolangu, Malang',
    this.destinationSubAddress = 'Jl. Bendungan Sigura-gura, Lowokwaru',
    this.originLocation = 'Malang City Point',
    this.distanceKm = '2.4 km lagi',
    this.estimatedMinutes = '±15 menit',
    this.estimatedArrivalTime = '09:10 WIB',
    this.scheduledAt,
    this.note = '',
    this.paymentMethod = 'QRIS',
    this.servicePrice = 300000,
    this.platformFee = 5000,
    this.discountAmount = 0,
    this.customerName = 'Krisna Pratama',
    this.customerPhone = '(+62) 81223728077',
  });

  final String status;
  final String arrivalEstimate;
  final String travelDescription;
  final double progress;
  final String serviceName;
  final String serviceImagePath;
  final String orderNumber;
  final String price;
  final String paymentStatus;
  final OrderStatusStage stage;
  final String cleanerName;
  final double cleanerRating;
  final String cleanerCompletedTasks;
  final String cleanerAvatarPath;
  final String cleanerPhone;
  final String destinationAddress;
  final String destinationSubAddress;
  final String originLocation;
  final String distanceKm;
  final String estimatedMinutes;
  final String estimatedArrivalTime;
  final DateTime? scheduledAt;
  final String note;
  final String paymentMethod;
  final int servicePrice;
  final int platformFee;
  final int discountAmount;
  final String customerName;
  final String customerPhone;

  ScheduledOrderModel copyWith({
    String? status,
    String? arrivalEstimate,
    String? travelDescription,
    double? progress,
    String? serviceName,
    String? serviceImagePath,
    String? orderNumber,
    String? price,
    String? paymentStatus,
    OrderStatusStage? stage,
    String? cleanerName,
    double? cleanerRating,
    String? cleanerCompletedTasks,
    String? cleanerAvatarPath,
    String? cleanerPhone,
    String? destinationAddress,
    String? destinationSubAddress,
    String? originLocation,
    String? distanceKm,
    String? estimatedMinutes,
    String? estimatedArrivalTime,
    DateTime? scheduledAt,
    String? note,
    String? paymentMethod,
    int? servicePrice,
    int? platformFee,
    int? discountAmount,
    String? customerName,
    String? customerPhone,
  }) {
    return ScheduledOrderModel(
      status: status ?? this.status,
      arrivalEstimate: arrivalEstimate ?? this.arrivalEstimate,
      travelDescription: travelDescription ?? this.travelDescription,
      progress: progress ?? this.progress,
      serviceName: serviceName ?? this.serviceName,
      serviceImagePath: serviceImagePath ?? this.serviceImagePath,
      orderNumber: orderNumber ?? this.orderNumber,
      price: price ?? this.price,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      stage: stage ?? this.stage,
      cleanerName: cleanerName ?? this.cleanerName,
      cleanerRating: cleanerRating ?? this.cleanerRating,
      cleanerCompletedTasks:
          cleanerCompletedTasks ?? this.cleanerCompletedTasks,
      cleanerAvatarPath: cleanerAvatarPath ?? this.cleanerAvatarPath,
      cleanerPhone: cleanerPhone ?? this.cleanerPhone,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      destinationSubAddress:
          destinationSubAddress ?? this.destinationSubAddress,
      originLocation: originLocation ?? this.originLocation,
      distanceKm: distanceKm ?? this.distanceKm,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      estimatedArrivalTime: estimatedArrivalTime ?? this.estimatedArrivalTime,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      note: note ?? this.note,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      servicePrice: servicePrice ?? this.servicePrice,
      platformFee: platformFee ?? this.platformFee,
      discountAmount: discountAmount ?? this.discountAmount,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
    );
  }
}

class OrderReviewModel {
  const OrderReviewModel({
    required this.orderId,
    required this.rating,
    required this.satisfactionTags,
    required this.comment,
    this.photoPaths = const [],
    required this.createdAt,
  });

  final String orderId;
  final int rating;
  final List<String> satisfactionTags;
  final String comment;
  final List<String> photoPaths;
  final DateTime createdAt;
}

class OrderHistoryModel {
  const OrderHistoryModel({
    this.orderId = '#CG-82910',
    required this.serviceName,
    required this.serviceAssetPath,
    required this.schedule,
    required this.status,
    required this.customerName,
    required this.price,
    required this.canReview,
    this.rating,
    this.cleanerName = 'Siti Rahmawati',
    this.cleanerAvatarPath = 'assets/images/cleaner_siti.jpeg',
    this.review,
    this.address = '',
    this.note = '',
    this.paymentMethod = 'QRIS',
    this.servicePrice = 300000,
    this.platformFee = 5000,
    this.discountAmount = 0,
  });

  final String orderId;
  final String serviceName;
  final String serviceAssetPath;
  final String schedule;
  final String status;
  final String customerName;
  final String price;
  final bool canReview;
  final double? rating;
  final String cleanerName;
  final String cleanerAvatarPath;
  final OrderReviewModel? review;
  final String address;
  final String note;
  final String paymentMethod;
  final int servicePrice;
  final int platformFee;
  final int discountAmount;

  OrderHistoryModel copyWith({
    String? orderId,
    String? serviceName,
    String? serviceAssetPath,
    String? schedule,
    String? status,
    String? customerName,
    String? price,
    bool? canReview,
    double? rating,
    String? cleanerName,
    String? cleanerAvatarPath,
    OrderReviewModel? review,
    String? address,
    String? note,
    String? paymentMethod,
    int? servicePrice,
    int? platformFee,
    int? discountAmount,
  }) {
    return OrderHistoryModel(
      orderId: orderId ?? this.orderId,
      serviceName: serviceName ?? this.serviceName,
      serviceAssetPath: serviceAssetPath ?? this.serviceAssetPath,
      schedule: schedule ?? this.schedule,
      status: status ?? this.status,
      customerName: customerName ?? this.customerName,
      price: price ?? this.price,
      canReview: canReview ?? this.canReview,
      rating: rating ?? this.rating,
      cleanerName: cleanerName ?? this.cleanerName,
      cleanerAvatarPath: cleanerAvatarPath ?? this.cleanerAvatarPath,
      review: review ?? this.review,
      address: address ?? this.address,
      note: note ?? this.note,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      servicePrice: servicePrice ?? this.servicePrice,
      platformFee: platformFee ?? this.platformFee,
      discountAmount: discountAmount ?? this.discountAmount,
    );
  }
}
