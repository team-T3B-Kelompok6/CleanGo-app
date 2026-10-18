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
    final selectedAddress =
        addresses.findById(booking.addressId) ?? addresses.selectedAddress;
    final bookingAddress = booking.address;
    final formattedAddress =
        selectedAddress?.fullAddress ??
        '${bookingAddress.street}, ${bookingAddress.city}';
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

    orders.createOrderFromBooking(
      serviceName: booking.service?.title ?? 'Deep Cleaning',
      serviceImagePath:
          booking.service?.imagePath ??
          'assets/images/service_deep_cleaning.jpeg',
      price: totalPayment,
      address: formattedAddress.trim().isNotEmpty
          ? formattedAddress
          : 'Jl. Sigura - Gura No. 12, Malang',
      destinationSubAddress: selectedAddress?.note ?? bookingAddress.landmark,
      destinationLatitude: selectedAddress?.latitude,
      destinationLongitude: selectedAddress?.longitude,
      scheduledAt: scheduledAt,
      note: booking.note.trim(),
      paymentMethod: method.name,
      servicePrice: servicePrice,
      platformFee: platformFee,
      discountAmount: discountAmount,
      customerName: selectedAddress?.contactName ?? bookingAddress.customerName,
      customerPhone: selectedAddress?.phoneNumber ?? bookingAddress.phoneNumber,
    );
    await booking.clearDraft();

    return isSameDay;
  }
}
