import '../../../core/network/api_exception.dart';

abstract interface class ImageAnalysisGateway {
  Future<ImageAnalysis> analyzeImage(List<int> bytes, String contentType);
  void close();
}

class ImageAnalysis {
  const ImageAnalysis({
    required this.reply,
    required this.analysis,
    required this.status,
  });

  final String reply;
  final Map<String, dynamic> analysis;
  final String status;

  bool get _hasDirtEvidence =>
      ((analysis['observations'] == 'Kotoran tampak pada foto.' &&
          (analysis['cleanlinessReason'] == null ||
              const [
                'small_dirt_patches',
                'widespread_dirt',
                'dirt_buildup',
              ].contains(analysis['cleanlinessReason']))) ||
      (analysis['cleanliness'] == 'light' &&
          analysis['cleanlinessReason'] == 'no_visible_dirt' &&
          analysis['observations'] ==
              'Tidak tampak kotoran jelas pada foto; bukan jaminan kebersihan.'));

  bool get needsClarification =>
      status == 'needs_clarification' ||
      analysis['cleanliness'] == 'unknown' ||
      analysis['cleanlinessReason'] == 'unclear' ||
      analysis['observations'] == 'Kondisi belum dapat dinilai dari foto.' ||
      analysis['confidence'] == 'low' ||
      (analysis['confidence'] == 'medium' && !_hasDirtEvidence);

  bool get isTentative =>
      !needsClarification && analysis['confidence'] == 'medium';

  bool get _tidinessReasonMatches {
    final reason = analysis['tidinessReason'];
    final matches =
        reason == null ||
        switch (analysis['tidiness']) {
          'tidy' => reason == 'items_organized',
          'moderate' => reason == 'some_items_unarranged',
          'cluttered' => reason == 'many_items_unarranged',
          'unknown' => reason == 'not_applicable' || reason == 'unclear',
          _ => false,
        };
    return matches;
  }

  bool get isTidinessUnknown =>
      needsClarification ||
      analysis['tidiness'] == 'unknown' ||
      !_tidinessReasonMatches;

  String get cleanlinessReasonText => switch (analysis['cleanlinessReason']) {
    'no_visible_dirt' =>
      'Tidak tampak kotoran jelas; bukan jaminan kebersihan.',
    'small_dirt_patches' => 'Terlihat bercak kotoran kecil.',
    'widespread_dirt' => 'Terlihat di beberapa area.',
    'dirt_buildup' => 'Terlihat penumpukan kotoran.',
    'unclear' => 'Bukti visual belum cukup untuk menilai kekotoran.',
    _ => analysis['observations'] as String,
  };

  String get tidinessReasonText => !_tidinessReasonMatches
      ? (analysis['tidinessReason'] == 'not_applicable'
            ? 'Kerapian tidak relevan untuk bagian yang dinilai.'
            : 'Bukti kerapian terpisah belum tersedia.')
      : switch (analysis['tidinessReason']) {
          'items_organized' => 'Barang yang terlihat tertata.',
          'some_items_unarranged' => 'Sebagian barang terlihat tidak tertata.',
          'many_items_unarranged' => 'Banyak barang terlihat tidak tertata.',
          'not_applicable' =>
            'Kerapian tidak relevan untuk bagian yang dinilai.',
          _ => 'Bukti kerapian terpisah belum tersedia.',
        };

  factory ImageAnalysis.fromJson(Map<String, dynamic> json) {
    final reply = json['reply'];
    final analysis = json['analysis'];
    final status = json['status'];
    if (reply is! String ||
        reply.trim().isEmpty ||
        reply.length > 5000 ||
        analysis is! Map<String, dynamic> ||
        !const [
          'light',
          'moderate',
          'heavy',
          'unknown',
        ].contains(analysis['cleanliness']) ||
        !const [
          'tidy',
          'moderate',
          'cluttered',
          'unknown',
        ].contains(analysis['tidiness']) ||
        analysis['observations'] is! String ||
        (analysis.containsKey('cleanlinessReason') &&
            !const [
              'no_visible_dirt',
              'small_dirt_patches',
              'widespread_dirt',
              'dirt_buildup',
              'unclear',
            ].contains(analysis['cleanlinessReason'])) ||
        (analysis.containsKey('tidinessReason') &&
            !const [
              'items_organized',
              'some_items_unarranged',
              'many_items_unarranged',
              'not_applicable',
              'unclear',
            ].contains(analysis['tidinessReason'])) ||
        !const ['low', 'medium', 'high'].contains(analysis['confidence']) ||
        !const ['analyzed', 'needs_clarification'].contains(status)) {
      throw const ApiException.simple(
        'Hasil analisis foto tidak valid. Silakan coba lagi.',
      );
    }
    return ImageAnalysis(
      reply: reply.trim(),
      analysis: analysis,
      status: status as String,
    );
  }
}
