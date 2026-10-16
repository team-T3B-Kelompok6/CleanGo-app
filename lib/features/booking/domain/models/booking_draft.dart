class BookingDraft {
  const BookingDraft({
    required this.serviceId,
    required this.selectedDate,
    required this.selectedTime,
    required this.note,
    required this.updatedAt,
    this.addressId,
    this.synced = false,
  });

  final String serviceId;
  final DateTime selectedDate;
  final String selectedTime;
  final String? addressId;
  final String note;
  final bool synced;
  final DateTime updatedAt;
}
