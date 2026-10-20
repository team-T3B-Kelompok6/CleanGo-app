import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show DateUtils;

import '../../service/domain/models/service_model.dart';
import '../data/booking_draft_repository.dart';
import '../data/customer_booking_api.dart';
import '../domain/models/cleaning_address.dart';
import '../domain/models/booking_draft.dart';

class BookingController extends ChangeNotifier {
  BookingController({
    this.repository,
    BookingDraft? initialDraft,
    ServiceModel? initialService,
    CleaningAddress? initialAddress,
    CustomerBookingApi? bookingApi,
  }) : _bookingApi = bookingApi,
       _service = initialService,
       _selectedDate = initialDraft?.selectedDate ?? initialDate,
       _selectedTime = initialDraft?.selectedTime ?? '12:00',
       _address = initialAddress ?? BookingController.initialAddress,
       _addressId = initialDraft?.addressId,
       _note = initialDraft?.note ?? initialNote {
    _ensureTimeSelection();
  }

  static DateTime get initialDate => DateUtils.dateOnly(DateTime.now());

  static const int platformFee = 5000;

  static const List<String> availableTimes = [
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
  ];

  static const CleaningAddress initialAddress = CleaningAddress(
    label: 'Rumah (Utama)',
    street: 'Blk. N No.521, Mojolangu, Kec. Lowokwaru',
    city: 'Kota Malang, Jawa Timur 65141',
    landmark: 'Patokan pagar hitam sebelah minimarket',
    customerName: 'Krisna',
    phoneNumber: '(+62) 081223728077',
  );

  static const String initialNote = '';

  final BookingDraftRepository? repository;
  final CustomerBookingApi? _bookingApi;
  List<BookingSlotInfo> _slotInfo = const [];
  List<String> _apiSlots = const [];
  String? _availabilityError;
  bool _availabilityLoading = false;
  ServiceModel? _service;
  DateTime _selectedDate;
  String _selectedTime;
  CleaningAddress _address;
  String? _addressId;
  String _note;

  ServiceModel? get service => _service;
  DateTime get selectedDate => _selectedDate;
  String get selectedTime => _selectedTime;
  CleaningAddress get address => _address;
  String? get addressId => _addressId;
  String get note => _note;

  /// Slots offered for the selected date: server slots when loaded, otherwise
  /// the local default schedule.
  List<String> get slots => _apiSlots.isEmpty ? availableTimes : _apiSlots;
  List<BookingSlotInfo> get slotInfo => List.unmodifiable(_slotInfo);
  String? get availabilityError => _availabilityError;
  bool get availabilityLoading => _availabilityLoading;
  bool get hasServerAvailability => _apiSlots.isNotEmpty;

  String? slotReason(String time) {
    for (final slot in _slotInfo) {
      if (slot.time == time) return slot.reason;
    }
    return null;
  }

  static String isoDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// Loads the availability board for the selected date and service.
  Future<void> loadAvailability() async {
    final api = _bookingApi;
    if (api == null) return;
    _availabilityLoading = true;
    _availabilityError = null;
    notifyListeners();
    try {
      final info = await api.availability(
        date: isoDate(_selectedDate),
        serviceId: _service?.id,
      );
      _slotInfo = info;
      _apiSlots = info
          .where((slot) => slot.available)
          .map((slot) => slot.time)
          .toList(growable: false);
      if (_apiSlots.isNotEmpty && !_apiSlots.contains(_selectedTime)) {
        _selectedTime = _apiSlots.first;
      }
    } catch (error) {
      _availabilityError = error.toString();
      _slotInfo = const [];
      _apiSlots = const [];
    } finally {
      _availabilityLoading = false;
      notifyListeners();
    }
  }

  /// Creates the booking on the backend. Returns null when the app runs without
  /// a configured booking API (offline/local mode).
  Future<CreatedBooking?> createBookingOnServer() async {
    final api = _bookingApi;
    if (api == null) return null;
    final service = _service;
    if (service == null) {
      throw StateError('Pilih layanan terlebih dahulu.');
    }
    return api.create(
      serviceId: service.id,
      date: isoDate(_selectedDate),
      time: _selectedTime,
      addressId: _addressId,
      notes: _note,
    );
  }
  int get servicePriceValue => _parsePrice(_service?.price ?? '');
  int get totalPayment => servicePriceValue + platformFee;
  String get formattedServicePrice => formatRupiah(servicePriceValue);
  String get formattedPlatformFee => formatRupiah(platformFee);
  String get formattedTotalPayment => formatRupiah(totalPayment);
  String get formattedSelectedDate {
    const weekdays = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${weekdays[_selectedDate.weekday - 1]}, '
        '${_selectedDate.day} ${months[_selectedDate.month - 1]} '
        '${_selectedDate.year}';
  }

  String get formattedSelectedTime => '$_selectedTime WIB';

  bool isTimeAvailable(String time, {DateTime? now}) {
    if (!slots.contains(time)) return false;
    final hour = int.parse(time.substring(0, 2));
    final scheduled = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      hour,
    );
    return !scheduled.isBefore(now ?? DateTime.now());
  }

  String? validateSchedule({DateTime? now}) {
    final current = now ?? DateTime.now();
    if (_selectedDate.isBefore(DateUtils.dateOnly(current))) {
      return 'Tanggal booking sudah lewat. Pilih tanggal lain.';
    }
    if (!slots.contains(_selectedTime)) {
      return 'Pilih tanggal dan jam mulai yang masih tersedia.';
    }
    if (!isTimeAvailable(_selectedTime, now: current)) {
      return 'Jam mulai sudah lewat. Pilih jam atau tanggal lain.';
    }
    return null;
  }

  void _ensureTimeSelection() {
    if (isTimeAvailable(_selectedTime)) return;
    _selectedTime = slots.firstWhere(
      (time) => isTimeAvailable(time),
      orElse: () => '',
    );
  }

  void startBooking(ServiceModel service) {
    if (_service?.id == service.id) {
      final today = initialDate;
      final previousDate = _selectedDate;
      final previousTime = _selectedTime;
      if (_selectedDate.isBefore(today)) {
        _selectedDate = today;
      }
      _ensureTimeSelection();
      if (_selectedDate != previousDate || _selectedTime != previousTime) {
        notifyListeners();
        _persistDraft();
      }
      return;
    }

    _service = service;
    _selectedDate = initialDate;
    _selectedTime = '12:00';
    _ensureTimeSelection();
    _address = initialAddress;
    _addressId = null;
    _note = initialNote;
    notifyListeners();
    _persistDraft();
    if (_bookingApi != null) unawaited(loadAvailability());
  }

  void selectDate(DateTime date) {
    if (date.isBefore(initialDate) ||
        DateUtils.isSameDay(date, _selectedDate)) {
      return;
    }

    _selectedDate = DateUtils.dateOnly(date);
    _ensureTimeSelection();
    if (_bookingApi != null) unawaited(loadAvailability());
    notifyListeners();
    _persistDraft();
  }

  void selectTime(String time) {
    if (!isTimeAvailable(time) || time == _selectedTime) {
      return;
    }

    _selectedTime = time;
    notifyListeners();
    _persistDraft();
  }

  void updateAddress(CleaningAddress address, {String? addressId}) {
    if (identical(address, _address) && addressId == _addressId) {
      return;
    }

    _address = address;
    _addressId = addressId;
    notifyListeners();
    _persistDraft();
  }

  void updateNote(String note) {
    if (note == _note) {
      return;
    }

    _note = note;
    notifyListeners();
    _persistDraft();
  }

  Future<void> clearDraft() async {
    await repository?.clearDraft();
  }

  void _persistDraft() {
    final storage = repository;
    final service = _service;
    if (storage == null || service == null) return;
    unawaited(
      storage
          .saveDraft(
            BookingDraft(
              serviceId: service.id,
              selectedDate: _selectedDate,
              selectedTime: _selectedTime,
              addressId: _addressId,
              note: _note,
              updatedAt: DateTime.now().toUtc(),
            ),
          )
          .catchError((Object error, StackTrace stackTrace) {
            debugPrint('Gagal menyimpan draft booking: $error\n$stackTrace');
          }),
    );
  }

  static int _parsePrice(String price) {
    final digits = price.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }

  static String formatRupiah(int amount) {
    final digits = amount.toString();
    final groups = <String>[];

    for (var end = digits.length; end > 0; end -= 3) {
      final start = end - 3 < 0 ? 0 : end - 3;
      groups.insert(0, digits.substring(start, end));
    }

    return 'Rp${groups.join('.')}';
  }
}
