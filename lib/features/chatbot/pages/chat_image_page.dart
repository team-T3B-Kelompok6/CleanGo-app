import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../data/chat_image_cache.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../data/chatbot_repository.dart';
import '../models/image_analysis.dart';

const _invalidPhoto = 'Foto harus JPEG, PNG, atau WebP dan maksimal 5 MB.';

/// Photo state stays on this route, never in chat history or text context.
class ChatImagePage extends StatefulWidget {
  const ChatImagePage({super.key, this.repository, this.pickImage});

  final ImageAnalysisGateway? repository;
  final Future<Uint8List?> Function(ImageSource source)? pickImage;

  @override
  State<ChatImagePage> createState() => _ChatImagePageState();
}

class _ChatImagePageState extends State<ChatImagePage> {
  late final ImageAnalysisGateway _repository =
      widget.repository ?? ChatbotRepository();
  Uint8List? _bytes;
  bool _busy = false;
  String? _error;
  ImageAnalysis? _result;

  void _clearPhoto() {
    final bytes = _bytes;
    _bytes = null;
    if (bytes != null) {
      unawaited(MemoryImage(bytes).evict());
      bytes.fillRange(0, bytes.length, 0);
    }
  }

  @override
  void dispose() {
    _clearPhoto();
    if (widget.repository == null) _repository.close();
    super.dispose();
  }

  Future<Uint8List?> _pickTemporary(ImageSource source) async {
    final picker = ImagePicker();
    XFile? file;
    await markBooPicker(true);
    try {
      file = await picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 80,
        requestFullMetadata: false,
      );
      if (file == null) return null;
      if (await file.length() > 5 * 1024 * 1024) {
        throw const ApiException.simple(_invalidPhoto);
      }
      return await file.readAsBytes();
    } finally {
      try {
        if (file != null) await deleteChatPickerCopy(file.path);
        await markBooPicker(false);
      } catch (_) {
        // Keep marker for startup retry if native cleanup fails.
      }
    }
  }

  String? _contentType(Uint8List bytes) {
    if (bytes.length >= 3 &&
        bytes[0] == 0xff &&
        bytes[1] == 0xd8 &&
        bytes[2] == 0xff) {
      return 'image/jpeg';
    }
    if (bytes.length >= 8 &&
        const [
          137,
          80,
          78,
          71,
          13,
          10,
          26,
          10,
        ].asMap().entries.every((entry) => bytes[entry.key] == entry.value)) {
      return 'image/png';
    }
    if (bytes.length >= 12 &&
        String.fromCharCodes(bytes.take(4)) == 'RIFF' &&
        String.fromCharCodes(bytes.skip(8).take(4)) == 'WEBP') {
      return 'image/webp';
    }
    return null;
  }

  Future<void> _pick(ImageSource source) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
      _result = null;
      _clearPhoto();
    });
    Uint8List? picked;
    try {
      picked = await (widget.pickImage ?? _pickTemporary)(source);
      if (!mounted) return;
      if (picked == null) return;
      if (picked.isEmpty ||
          picked.length > 5 * 1024 * 1024 ||
          _contentType(picked) == null) {
        throw const ApiException.simple(_invalidPhoto);
      }
      _bytes = picked;
      picked = null;
    } on PlatformException {
      if (mounted) _error = 'Tidak dapat membuka kamera atau galeri. Periksa izin di pengaturan perangkat.';
    } on ApiException catch (error) {
      if (mounted) _error = error.message;
    } catch (_) {
      if (mounted) _error = 'Foto tidak dapat dibuka. Silakan pilih foto lain.';
    } finally {
      picked?.fillRange(0, picked.length, 0);
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _analyze() async {
    if (_busy || _bytes == null) return;
    setState(() {
      _busy = true;
      _error = null;
      _result = null;
    });
    try {
      final result = await _repository.analyzeImage(
        _bytes!,
        _contentType(_bytes!)!,
      );
      if (mounted) _result = result;
    } on ApiException catch (error) {
      if (mounted) _error = error.message;
    } catch (_) {
      if (mounted) {
        _error = 'Analisis foto gagal. Pilih foto lagi untuk mencoba ulang.';
      }
    } finally {
      _clearPhoto();
      if (mounted) setState(() => _busy = false);
    }
  }

  String _grade(ImageAnalysis result) => result.needsClarification
      ? 'Belum dapat dinilai'
      : switch (result.analysis['cleanliness']) {
          'light' => 'Kotor ringan',
          'moderate' => 'Kotor sedang',
          'heavy' => 'Kotor berat',
          _ => 'Belum dapat dinilai',
        };

  Widget _assessmentCard({
    required String title,
    required String grade,
    required String reason,
    required List<String> levels,
    required int selected,
  }) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.primaryBorder),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Text(
          grade,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 12),
        // Categorical grades, not a calibrated score or probability.
        ExcludeSemantics(
          child: Row(
            children: List.generate(
              levels.length,
              (index) => Expanded(
                child: Container(
                  height: 8,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: index == selected
                        ? AppColors.primary
                        : AppColors.primaryBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(levels.join(' · '), style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 12),
        Text(reason),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: AppBar(title: const Text('Analisis foto')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Seberapa kotor yang terlihat?',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Boo membantu menilai tingkat kekotoran dari satu foto. Ambil foto yang terang dan fokus.',
                ),
                const SizedBox(height: 20),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _busy ? null : () => _pick(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Kamera'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _busy
                          ? null
                          : () => _pick(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Galeri'),
                    ),
                  ],
                ),
                if (_bytes != null && !_busy) ...[
                  const SizedBox(height: 16),
                  Image.memory(
                    _bytes!,
                    height: 220,
                    fit: BoxFit.contain,
                    semanticLabel: 'Pratinjau foto untuk Boo',
                    errorBuilder: (_, _, _) =>
                        const Text('Pratinjau foto tidak dapat ditampilkan.'),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Dengan mengetuk Kirim dan analisis, Anda setuju foto dikirim ke layanan analisis eksternal. Hindari wajah, dokumen, dan informasi pribadi. CleanGo tidak menyimpan foto di akun atau riwayat chat. Penyimpanan oleh penyedia mengikuti kebijakannya.',
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _analyze,
                    child: const Text('Kirim dan analisis'),
                  ),
                  TextButton(
                    onPressed: () => setState(_clearPhoto),
                    child: const Text('Batal'),
                  ),
                ],
                if (_busy)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Boo sedang menganalisis foto…'),
                      ],
                    ),
                  ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Semantics(
                      liveRegion: true,
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ),
                if (result != null) ...[
                  const SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          liveRegion: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (result.isTentative) ...[
                                const Text('Perkiraan'),
                                const SizedBox(height: 8),
                              ],
                              _assessmentCard(
                                title: 'Kekotoran yang terlihat',
                                grade: _grade(result),
                                reason: result.cleanlinessReasonText,
                                levels: const ['Ringan', 'Sedang', 'Berat'],
                                selected: result.needsClarification
                                    ? -1
                                    : switch (result.analysis['cleanliness']) {
                                        'light' => 0,
                                        'moderate' => 1,
                                        'heavy' => 2,
                                        _ => -1,
                                      },
                              ),
                              const SizedBox(height: 12),
                              _assessmentCard(
                                title: 'Kerapian',
                                grade: result.isTidinessUnknown
                                    ? 'Belum dapat dinilai'
                                    : switch (result.analysis['tidiness']) {
                                        'tidy' => 'Rapi',
                                        'moderate' => 'Cukup tertata',
                                        'cluttered' => 'Berantakan',
                                        _ => 'Belum dapat dinilai',
                                      },
                                reason: result.tidinessReasonText,
                                levels: const [
                                  'Rapi',
                                  'Cukup tertata',
                                  'Berantakan',
                                ],
                                selected: result.isTidinessUnknown
                                    ? -1
                                    : switch (result.analysis['tidiness']) {
                                        'tidy' => 0,
                                        'moderate' => 1,
                                        'cluttered' => 2,
                                        _ => -1,
                                      },
                              ),
                              const SizedBox(height: 16),
                              Text(result.reply),
                            ],
                          ),
                        ),
                        if (result.needsClarification) ...[
                          const SizedBox(height: 12),
                          const Text(
                            'Ketidakpastian bukan berarti foto buruk. Coba sudut lebih dekat pada permukaan yang ingin dinilai.',
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Penilaian hanya berdasarkan bagian yang tampak di foto. Hasil dapat keliru; ini bukan pemeriksaan langsung dan tidak menentukan harga.',
                  ),
                ],
                const SizedBox(height: 16),
                const Text(
                  'Foto dan hasil hanya tersedia selama halaman ini terbuka. Salinan sementara dibersihkan semampunya; jika aplikasi berhenti mendadak, sebagian salinan bisa tertinggal di perangkat. Foto asli di galeri tidak dihapus.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
