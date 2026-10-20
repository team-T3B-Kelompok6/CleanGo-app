import '../../address/controllers/address_controller.dart';
import '../../booking/controllers/booking_controller.dart';
import '../../order/controllers/order_controller.dart';
import '../domain/models/payment_method_model.dart';

class PaymentFlowController {
  const PaymentFlowController();

  Future<bool> createOrder({
    required BookingController booking,
    required AddressController addresses,
    required OrderController orders,
    required PaymentMethodModel method,
    required String totalPayment,
    required int servicePrice,
    required int platformFee,
    required int discountAmount,
    DateTime? now,
  }) async {
    final scheduleError = booking.validateSchedule(now: now);
    if (scheduleError != null) throw StateError(scheduleError);
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

    await booking.clearDraft();
    orders.createOrderFromBooking(
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

    return isSameDay;
  }
}
