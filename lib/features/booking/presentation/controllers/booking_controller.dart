import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show DateUtils;

import '../../../service/domain/models/service_model.dart';

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
  static final DateTime initialDate = DateTime(2026, 10, 15);

  static const List<String> availableTimes = [
    '09.00',
    '11:00',
    '13:00',
    '15:00',
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

  ServiceModel? _service;
  DateTime _selectedDate = initialDate;
  String _selectedTime = '11:00';
  CleaningAddress _address = initialAddress;
  String _note = initialNote;

  ServiceModel? get service => _service;
  DateTime get selectedDate => _selectedDate;
  String get selectedTime => _selectedTime;
  CleaningAddress get address => _address;
  String get note => _note;

  void startBooking(ServiceModel service) {
    if (_service?.id == service.id) {
      return;
    }

    _service = service;
    _selectedDate = initialDate;
    _selectedTime = '11:00';
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
}
