import 'package:flutter/material.dart';

import '../models/faq_item_model.dart';

class FaqData {
  static const List<FaqItemModel> initialFaqs = [
    FaqItemModel(
      id: 'faq-1',
      question: 'Bagaimana cara menjadwalkan ulang pesanan?',
      answer: 'Anda dapat mengubah jadwal melalui menu Pesanan paling lambat H-1 atau 24 jam sebelum jadwal pengerjaan.',
      highlight:
          'Setelah batas H-1, hubungi WhatsApp CS CleanGo untuk bantuan.',
      icon: Icons.edit_calendar_outlined,
      isExpanded: true,
    ),
    FaqItemModel(
      id: 'faq-2',
      question: 'Metode pembayaran apa saja yang didukung?',
      answer: 'CleanGo mendukung berbagai metode pembayaran resmi: QRIS (GoPay, OVO, DANA, ShopeePay), Virtual Account Bank (BCA, Mandiri, BNI, BRI), dan Transfer Bank.',
      icon: Icons.payments_outlined,
      isExpanded: false,
    ),
    FaqItemModel(
      id: 'faq-3',
      question: 'Apakah staf cleaner CleanGo membawa peralatan sendiri?',
      answer: 'Ya, seluruh staf cleaner CleanGo telah dibekali perlengkapan lengkap, mesin vakum khusus, dan cairan pembersih berstandar ramah lingkungan.',
      icon: Icons.cleaning_services_outlined,
      isExpanded: false,
    ),
    FaqItemModel(
      id: 'faq-4',
      question: 'Bagaimana jika saya tidak puas dengan hasil pembersihan?',
      answer: 'CleanGo memberikan Jaminan Garansi 100%. Anda dapat mengajukan komplain maksimal 1x24 jam setelah pengerjaan untuk mendapatkan layanan pembersihan ulang (re-cleaning) tanpa biaya tambahan.',
      icon: Icons.verified_outlined,
      isExpanded: false,
    ),
    FaqItemModel(
      id: 'faq-5',
      question: 'Bagaimana cara membatalkan pesanan?',
      answer: 'Pembatalan dapat dilakukan melalui menu Pesanan paling lambat H-1 atau 24 jam sebelum jadwal pengerjaan. Setelah melewati batas tersebut, hubungi WhatsApp CS CleanGo.',
      icon: Icons.cancel_outlined,
      isExpanded: false,
    ),
  ];
}
