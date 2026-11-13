import '../../address/controllers/address_controller.dart';
import '../../booking/data/customer_booking_api.dart';
import '../../booking/controllers/booking_controller.dart';
import '../../order/controllers/order_controller.dart';
import '../domain/models/payment_method_model.dart';

class PaymentFlowController {
  String? _bookingId;
  BookingPayment? payment;
  bool _completed = false;
  bool? _isSameDay;

  String? get bookingId => _bookingId;

  static Uri? checkoutUri(String? url) {
    final uri = Uri.tryParse(url ?? '');
    return uri != null &&
            uri.scheme == 'https' &&
            const {
              'app.midtrans.com',
              'app.sandbox.midtrans.com',
              'checkout.xendit.co',
              'checkout-staging.xendit.co',
              'xen.to',
              'dev.xen.to',
            }.contains(uri.host) &&
            uri.userInfo.isEmpty &&
            (!uri.hasPort || uri.port == 443)
        ? uri
        : null;
  }

  /// Null means payment is not yet confirmed by the server.
  Future<bool?> createOrder({
    required BookingController booking,
    required AddressController addresses,
    required OrderController orders,
    required PaymentMethodModel method,
    required String totalPayment,
    required int servicePrice,
    required int platformFee,
    required int discountAmount,
    bool checkStatus = false,
    DateTime? now,
  }) async {
    if (_completed) return _isSameDay;
    if (_bookingId == null) {
      final scheduleError = booking.validateSchedule(now: now);
      if (scheduleError != null) throw StateError(scheduleError);
    }
    final selectedAddress = booking.addressId == null
        ? addresses.selectedAddress
        : addresses.findById(booking.addressId);
    if (selectedAddress == null) {
      throw StateError(
        booking.addressId == null
            ? 'Pilih alamat pengerjaan terlebih dahulu.'
            : 'Alamat booking sudah tidak tersedia. Pilih alamat kembali.',
      );
    }
    final formattedAddress = selectedAddress.fullAddress.trim();
    if (formattedAddress.trim().isEmpty) {
      throw StateError('Pilih alamat pengerjaan terlebih dahulu.');
    }
    if (booking.service == null ||
        servicePrice != booking.servicePriceValue ||
        platformFee != BookingController.platformFee ||
        servicePrice < 0 ||
        platformFee < 0 ||
        discountAmount < 0 ||
        discountAmount > servicePrice ||
        totalPayment !=
            BookingController.formatRupiah(
              servicePrice - discountAmount + platformFee,
            )) {
      throw StateError('Rincian pembayaran berubah. Periksa kembali Checkout.');
    }
    final selectedTimeParts = booking.selectedTime.split(':');
    final scheduledAt = DateTime(
      booking.selectedDate.year,
      booking.selectedDate.month,
      booking.selectedDate.day,
      int.tryParse(selectedTimeParts.first) ?? 8,
      int.tryParse(selectedTimeParts.last) ?? 0,
    );
    final currentTime = now ?? DateTime.now();
    final isSameDay =
        scheduledAt.year == currentTime.year &&
        scheduledAt.month == currentTime.month &&
        scheduledAt.day == currentTime.day;

    if (_bookingId == null) {
      final created = await booking.createBookingOnServer();
      if (created == null || created.id.isEmpty) {
        throw StateError('Pembayaran memerlukan booking dari server.');
      }
      // Keep this before /pay: a timeout must retry the same booking.
      _bookingId = created.id;
    }
    final CreatedBooking serverBooking;
    if (checkStatus && method.type != PaymentMethodType.cash) {
      serverBooking = await booking.fetchBooking(_bookingId!);
      if (payment != null) {
        payment = BookingPayment(
          booking: serverBooking,
          status: serverBooking.paymentStatus ?? 'pending',
          checkoutUrl: payment!.checkoutUrl,
          expiresAt: payment!.expiresAt,
        );
      }
    } else {
      payment = await booking.payBooking(_bookingId!, method.type.name);
      serverBooking = payment!.booking;
    }
    if (serverBooking.id != _bookingId) {
      throw StateError('Respons pembayaran tidak cocok dengan booking.');
    }
    if (method.type != PaymentMethodType.cash &&
        serverBooking.paymentStatus != 'paid') {
      return null;
    }
    await booking.clearDraft();
    orders.createOrderFromBooking(
      serviceDurationMinutes: booking.service?.durationMinutes,
      serviceName: booking.service?.title ?? 'Deep Cleaning',
      serviceImagePath:
          booking.service?.imagePath ??
          'assets/images/service_deep_cleaning.jpeg',
      price: totalPayment,
      address: formattedAddress,
      destinationSubAddress: selectedAddress.note,
      destinationLatitude: selectedAddress.latitude,
      destinationLongitude: selectedAddress.longitude,
      scheduledAt: scheduledAt,
      note: booking.note.trim(),
      paymentMethod: method.name,
      servicePrice: servicePrice,
      platformFee: platformFee,
      discountAmount: discountAmount,
      customerName: selectedAddress.contactName,
      customerPhone: selectedAddress.phoneNumber,
    );

    _completed = true;
    _isSameDay = isSameDay;
    return isSameDay;
  }
}
