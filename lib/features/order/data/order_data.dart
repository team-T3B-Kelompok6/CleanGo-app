import '../domain/models/order_model.dart';

abstract final class OrderData {
  static const ScheduledOrderModel scheduledOrder = ScheduledOrderModel(
    status: 'CLEANER MENUJU LOKASI',
    arrivalEstimate: 'Tiba ~09:10 WIB',
    travelDescription: 'Estimasi waktu perjalanan sekitar 15 menit',
    progress: 0.66,
    serviceName: 'Deep Cleaning',
    serviceImagePath: 'assets/images/deep_cleaning.jpeg',
    orderNumber: '#CG-82910',
    price: 'Rp305.000',
    paymentStatus: 'QRIS Terbayar',
  );

  static const List<OrderHistoryModel> history = [
    OrderHistoryModel(
      orderId: '#CG-99012',
      serviceName: 'Cuci AC',
      serviceAssetPath: 'assets/icons/ac_wash.svg',
      schedule: 'Kamis, 15 Sep 2024 • 09:00',
      status: 'SELESAI',
      customerName: 'Krisna pratama',
      price: 'Rp305.000',
      canReview: true,
    ),
    OrderHistoryModel(
      serviceName: 'Deep Cleaning',
      serviceAssetPath: 'assets/images/deep_cleaning.jpeg',
      schedule: 'Selasa, 10 Sep 2024 • 10:00',
      status: 'SELESAI',
      customerName: 'Krisna pratama',
      price: 'Rp155.000',
      servicePrice: 150000,
      platformFee: 5000,
      canReview: false,
      rating: 5,
    ),
  ];
}
