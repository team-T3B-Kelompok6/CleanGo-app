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
}

class OrderHistoryModel {
  const OrderHistoryModel({
    required this.serviceName,
    required this.serviceAssetPath,
    required this.schedule,
    required this.status,
    required this.customerName,
    required this.price,
    required this.canReview,
    this.rating,
  });

  final String serviceName;
  final String serviceAssetPath;
  final String schedule;
  final String status;
  final String customerName;
  final String price;
  final bool canReview;
  final double? rating;
}
