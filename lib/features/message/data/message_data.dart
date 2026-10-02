import '../domain/models/message_notification_model.dart';

abstract final class MessageData {
  static const List<MessageNotificationModel> notifications = [
    MessageNotificationModel(
      id: 'cleaner-on-the-way',
      title: 'Cleaner dalam perjalanan',
      description:
          'Siti Rahmawati sedang menuju ke lokasi Anda. ETA ~09:35 WIB.',
      timeLabel: '5 menit lalu',
      category: MessageCategory.order,
      iconType: MessageIconType.delivery,
      isUnread: true,
    ),
    MessageNotificationModel(
      id: 'order-confirmed',
      title: 'Pesanan Dikonfirmasi',
      description:
          'Deep Cleaning untuk 15 Sep telah dikonfirmasi staf CleanGo.',
      timeLabel: '1 jam lalu',
      category: MessageCategory.order,
      iconType: MessageIconType.confirmed,
    ),
    MessageNotificationModel(
      id: 'delay-detected',
      title: 'Keterlambatan Terdeteksi',
      description:
          'Cleaner Anda mungkin terlambat sekitar 5–10 menit karena pengalihan lalu lintas.',
      timeLabel: '3 menit lalu',
      category: MessageCategory.order,
      iconType: MessageIconType.delayed,
      isUnread: true,
      isWarning: true,
    ),
    MessageNotificationModel(
      id: 'qris-payment-success',
      title: 'Pembayaran QRIS Berhasil',
      description:
          'Pesanan Deep Cleaning telah dibayar Rp305.000. Cleaner telah dijadwalkan.',
      timeLabel: '45 menit lalu',
      category: MessageCategory.order,
      iconType: MessageIconType.payment,
    ),
    MessageNotificationModel(
      id: 'special-promo',
      title: 'Promo Spesial!',
      description:
          'Diskon 35% untuk semua jenis layanan pertama dengan kode CLEANHEMAT.',
      timeLabel: '1 hari lalu',
      category: MessageCategory.promo,
      iconType: MessageIconType.promo,
      isUnread: true,
    ),
    MessageNotificationModel(
      id: 'rating-received',
      title: 'Rating Diterima',
      description:
          'Terima kasih! Ulasan Anda sangat berharga bagi cleaner kami.',
      timeLabel: '2 hari lalu',
      category: MessageCategory.order,
      iconType: MessageIconType.rating,
    ),
  ];
}
