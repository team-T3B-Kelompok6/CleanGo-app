import 'package:flutter/material.dart';

import '../../../service/domain/models/service_model.dart';

class BookingPage extends StatelessWidget {
  const BookingPage({super.key, required this.service});

  final ServiceModel service;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking')),
      body: const SizedBox.expand(),
    );
  }
}
