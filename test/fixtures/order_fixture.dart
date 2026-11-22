import 'package:cleango_app/features/order/domain/models/order_model.dart';

ScheduledOrderModel testScheduledOrder() => ScheduledOrderModel(
  status: 'Dijadwalkan',
  arrivalEstimate: 'Menunggu jadwal layanan',
  travelDescription: 'Pesanan uji untuk peta dan pelacakan.',
  progress: 0.2,
  serviceName: 'Basic Home Cleaning',
  serviceImagePath: 'assets/icons/service_placeholder.svg',
  orderNumber: '#TEST-ORDER',
  price: 'Rp100.000',
  paymentStatus: 'Belum dibayar',
);
