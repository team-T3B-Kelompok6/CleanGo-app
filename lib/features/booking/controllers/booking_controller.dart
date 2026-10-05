import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show DateUtils;

import '../../service/domain/models/service_model.dart';

class CleaningAddress {
  const CleaningAddress({
    required this.label,
    required this.street,
    required this.city,
    required this.landmark,
    required this.customerName,
    required this.phoneNumber,
  });

  final String label;
  final String street;
  final String city;
  final String landmark;
  final String customerName;
  final String phoneNumber;
}

class BookingController extends ChangeNotifier {
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

  ServiceModel? _service;
  DateTime _selectedDate = initialDate;
  String _selectedTime = '12:00';
  CleaningAddress _address = initialAddress;
  String _note = initialNote;

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
      }
      return;
    }

    _service = service;
    _selectedDate = initialDate;
    _selectedTime = '12:00';
    _address = initialAddress;
    _note = initialNote;
    notifyListeners();
  }

  void selectDate(DateTime date) {
    if (DateUtils.isSameDay(date, _selectedDate)) {
      return;
    }

    _selectedDate = date;
    notifyListeners();
  }

  void selectTime(String time) {
    if (!availableTimes.contains(time) || time == _selectedTime) {
      return;
    }

    _selectedTime = time;
    notifyListeners();
  }

  void updateAddress(CleaningAddress address) {
    if (identical(address, _address)) {
      return;
    }

    _address = address;
    notifyListeners();
  }

  void updateNote(String note) {
    if (note == _note) {
      return;
    }

    _note = note;
    notifyListeners();
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
