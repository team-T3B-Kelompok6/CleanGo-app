import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show DateUtils;

import '../../service/domain/models/service_model.dart';
import '../data/booking_draft_repository.dart';
import '../domain/models/cleaning_address.dart';
import '../domain/models/booking_draft.dart';

class BookingController extends ChangeNotifier {
  BookingController({
    this.repository,
    BookingDraft? initialDraft,
    ServiceModel? initialService,
    CleaningAddress? initialAddress,
  }) : _service = initialService,
       _selectedDate = initialDraft?.selectedDate ?? initialDate,
       _selectedTime = initialDraft?.selectedTime ?? '12:00',
       _address = initialAddress ?? BookingController.initialAddress,
       _addressId = initialDraft?.addressId,
       _note = initialDraft?.note ?? initialNote;

  static DateTime get initialDate => DateUtils.dateOnly(DateTime.now());

  static const int platformFee = 5000;

  static const List<String> availableTimes = ['08:00', '12:00', '16:00'];

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
  String get note => _note;
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

  void startBooking(ServiceModel service) {
    if (_service?.id == service.id) {
      final today = initialDate;
      if (_selectedDate.isBefore(today)) {
        _selectedDate = today;
        notifyListeners();
        _persistDraft();
      }
      return;
    }

    _service = service;
    _selectedDate = initialDate;
    _selectedTime = '12:00';
    _address = initialAddress;
    _addressId = null;
    _note = initialNote;
    notifyListeners();
    _persistDraft();
  }

  void selectDate(DateTime date) {
    if (DateUtils.isSameDay(date, _selectedDate)) {
      return;
    }

    _selectedDate = date;
    notifyListeners();
    _persistDraft();
  }

  void selectTime(String time) {
    if (!availableTimes.contains(time) || time == _selectedTime) {
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
