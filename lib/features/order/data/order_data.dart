import '../domain/models/order_model.dart';

abstract final class OrderData {
  static const ScheduledOrderModel scheduledOrder = ScheduledOrderModel(
    status: 'PESANAN DIKONFIRMASI',
    arrivalEstimate: 'Menunggu jadwal layanan',
    travelDescription: 'Pesanan diterima dan menunggu penugasan cleaner.',
    progress: 0.2,
    serviceName: 'Deep Cleaning',
    serviceImagePath: 'assets/images/deep_cleaning.jpeg',
    orderNumber: '#CG-82910',
    price: 'Rp305.000',
    paymentStatus: '',
    stage: OrderStatusStage.dikonfirmasi,
  );

  static const List<OrderHistoryModel> history = [
    OrderHistoryModel(
      orderId: '#CG-99012',
      serviceName: 'Cuci AC',
      serviceAssetPath: 'assets/icons/ac_wash.svg',
      schedule: 'Kamis, 15 Sep 2024 • 09:00',
      status: 'SELESAI',
      customerName: '',
      price: 'Rp305.000',
      canReview: true,
    ),
    OrderHistoryModel(
      orderId: '#CG-82909',
      serviceName: 'Deep Cleaning',
      serviceAssetPath: 'assets/images/deep_cleaning.jpeg',
      schedule: 'Selasa, 10 Sep 2024 • 10:00',
      status: 'SELESAI',
      customerName: '',
      price: 'Rp155.000',
      servicePrice: 150000,
      platformFee: 5000,
      canReview: false,
      rating: 5,
    ),
  ];
}
