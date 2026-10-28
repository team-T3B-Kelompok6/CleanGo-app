import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../shared/widgets/app_notice.dart';
import '../../../shared/widgets/remote_or_asset_image.dart';
import '../../booking/domain/models/review_photo_model.dart';
import '../controllers/order_controller.dart';
import '../controllers/review_draft_controller.dart';
import 'orders_page.dart';

class ReviewRatingPage extends StatefulWidget {
  const ReviewRatingPage({
    super.key,
    this.orderId = '#CG-82910',
    this.bookingId,
    this.serviceName = 'Deep Cleaning',
    this.serviceImagePath = 'assets/images/service_deep_cleaning.jpeg',
    this.initialRating,
    this.initialComment = '',
    this.initialPhotos = const [],
    this.isEdit = false,
  });

  final String orderId;
  final String? bookingId;
  final String serviceName;
  final String serviceImagePath;
  final int? initialRating;
  final String initialComment;
  final List<ReviewPhotoModel> initialPhotos;
  final bool isEdit;

  @override
  State<ReviewRatingPage> createState() => _ReviewRatingPageState();
}

class _ReviewRatingPageState extends State<ReviewRatingPage> {
  late final ReviewDraftController _draft;
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    _draft = ReviewDraftController(initialPhotos: widget.initialPhotos);
    final rating = widget.initialRating;
    if (rating != null) _draft.selectRating(rating);
    if (widget.initialComment.trim().isNotEmpty) {
      _reviewController.text = widget.initialComment;
    }
  }

  int get _selectedRating => _draft.selectedRating;
  List<String> get _selectedChips => _draft.selectedChips;
  List<ReviewPhotoModel> get _attachedPhotos => _draft.photos;
  List<String> get _availableChips => ReviewDraftController.availableChips;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  String get _ratingLabel => _draft.ratingLabel;

  void _toggleChip(String chip) {
    setState(() => _draft.toggleChip(chip));
  }

  Future<void> _pickPhoto() async {
    if (_attachedPhotos.length >= ReviewDraftController.maxPhotos) {
      AppNotice.show(
        context,
        'Maksimal 3 foto yang dapat dilampirkan.',
        type: AppNoticeType.error,
      );
      return;
    }
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Ambil dari kamera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pilih dari galeri'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 82,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    if (bytes.length > 2 * 1024 * 1024) {
      AppNotice.show(
        context,
        'Ukuran foto maksimal 2 MB.',
        type: AppNoticeType.error,
      );
      return;
    }
    final type = _imageType(picked);
    if (type == null) {
      AppNotice.show(
        context,
        'Format foto harus JPEG, PNG, atau WebP.',
        type: AppNoticeType.error,
      );
      return;
    }
    if (!_draft.addPhoto(ReviewPhotoModel(bytes: bytes, contentType: type))) {
      AppNotice.show(
        context,
        'Maksimal 3 foto yang dapat dilampirkan.',
        type: AppNoticeType.error,
      );
      return;
    }
    setState(() {});
  }

  String? _imageType(XFile file) {
    final type = file.mimeType?.toLowerCase();
    if (type == 'image/jpeg' || type == 'image/png' || type == 'image/webp') {
      return type;
    }
    final name = file.name.toLowerCase();
    if (name.endsWith('.jpg') || name.endsWith('.jpeg')) return 'image/jpeg';
    if (name.endsWith('.png')) return 'image/png';
    if (name.endsWith('.webp')) return 'image/webp';
    return null;
  }

  void _removePhoto(int index) {
    setState(() => _draft.removePhoto(index));
    AppNotice.show(context, 'Foto berhasil dihapus.');
  }

  void _navigateToHistoryOrders(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => const OrdersPage(initialTab: OrdersTab.history),
      ),
      (route) => route.isFirst,
    );
  }

  Future<void> _submitReview() async {
    if (_isSubmitted) return;
    FocusManager.instance.primaryFocus?.unfocus();
    final orderController = context.read<OrderController>();
    final success = await orderController.submitReview(
      orderId: widget.orderId,
      rating: _selectedRating,
      tags: _draft.selectedChips,
      comment: _reviewController.text.trim(),
      photos: _draft.photos,
      removedPhotoIds: _draft.removedPhotoIds,
    );

    if (!mounted) return;
    if (!success) {
      AppNotice.show(
        context,
        'Ulasan belum dapat dikirim. Pesanan mungkin sudah diulas atau belum selesai.',
        type: AppNoticeType.error,
      );
      return;
    }
    _isSubmitted = true;
    final photoWarning = orderController.reviewPhotoUploadFailed;
    AppNotice.show(
      context,
      photoWarning
          ? 'Ulasan tersimpan, tetapi sebagian foto gagal diunggah. Coba lagi lewat Edit Ulasan.'
          : widget.isEdit
          ? 'Ulasan berhasil diperbarui.'
          : 'Ulasan berhasil dikirim. Terima kasih atas penilaian Anda.',
      type: photoWarning ? AppNoticeType.error : AppNoticeType.success,
    );
    _navigateToHistoryOrders(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _navigateToHistoryOrders(context);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildServiceCard(),
                      const SizedBox(height: 16),
                      _buildRatingCard(),
                      const SizedBox(height: 16),
                      _buildSatisfactionChipsCard(),
                      const SizedBox(height: 16),
                      _buildPhotoAttachmentCard(),
                      const SizedBox(height: 16),
                      _buildReviewInputCard(),
                      const SizedBox(height: 24),
                      _buildBottomActions(context),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Color(0xFF1E293B),
                size: 20,
              ),
              onPressed: () => _navigateToHistoryOrders(context),
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ulasan & Rating',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Beri penilaian pengalaman Anda',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard() {
    final isSvg = widget.serviceImagePath.toLowerCase().endsWith('.svg');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 56,
              height: 56,
              child: isSvg
                  ? ColoredBox(
                      color: const Color(0xFFE8FAF7),
                      child: Padding(
                        padding: const EdgeInsets.all(13),
                        child: SvgPicture.asset(
                          widget.serviceImagePath,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF00685F),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    )
                  : Image.asset(
                      widget.serviceImagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFFE8FAF7),
                        child: const Icon(
                          Icons.cleaning_services_outlined,
                          size: 26,
                          color: Color(0xFF00685F),
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.serviceName,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontFamily: 'Inter',
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Layanan yang Anda pesan',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Bagaimana kualitas layanan ini?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starIndex = index + 1;
              final isFilled = starIndex <= _selectedRating;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _draft.selectRating(starIndex));
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      Icons.star_rounded,
                      size: 38,
                      color: isFilled
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFFCBD5E1),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          Text(
            _ratingLabel,
            style: const TextStyle(
              color: Color(0xFF00685F),
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSatisfactionChipsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Apa yang paling memuaskan?',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontFamily: 'Inter',
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _availableChips.map((chip) {
              final isSelected = _selectedChips.contains(chip);
              return GestureDetector(
                onTap: () => _toggleChip(chip),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF00685F) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF00685F)
                          : const Color(0xFFE2E8F0),
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    chip
                        .replaceAll(' ✨', '')
                        .replaceAll(' ⏰', '')
                        .replaceAll(' 😊', '')
                        .replaceAll(' 📦', ''),
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF334155),
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewInputCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ulasan Anda (Opsional)',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontFamily: 'Inter',
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextField(
                  controller: _reviewController,
                  maxLines: 4,
                  minLines: 3,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13.5,
                    color: Color(0xFF0F172A),
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Bagikan pengalaman Anda menggunakan layanan...',
                    hintStyle: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontFamily: 'Inter',
                      fontSize: 13.5,
                    ),
                    contentPadding: EdgeInsets.all(14),
                    border: InputBorder.none,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 14, bottom: 10),
                  child: Text(
                    'Maks. 300 kata',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontFamily: 'Inter',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoThumbnail(ReviewPhotoModel photo) {
    final bytes = photo.bytes;
    if (bytes != null) {
      return Image.memory(bytes, fit: BoxFit.cover);
    }
    final url = photo.url;
    if (url != null && url.isNotEmpty) {
      return RemoteOrAssetImage(source: url, fit: BoxFit.cover);
    }
    return const ColoredBox(
      color: Color(0xFFE8FAF7),
      child: Icon(Icons.image_not_supported_outlined),
    );
  }

  Widget _buildPhotoAttachmentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Foto Hasil Pengerjaan (Opsional)',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontFamily: 'Inter',
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Foto akan terlihat oleh pelanggan lain.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontFamily: 'Inter',
              fontSize: 11.5,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Tombol dashed "Tambah"
              GestureDetector(
                onTap: _pickPhoto,
                child: CustomPaint(
                  painter: _DashedRectPainter(
                    color: const Color(0xFF94A3B8),
                    strokeWidth: 1.5,
                    gap: 4.0,
                    radius: 12.0,
                  ),
                  child: Container(
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          color: Color(0xFF64748B),
                          size: 24,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Tambah',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // List thumbnail foto jika ada
              if (_attachedPhotos.isNotEmpty) ...[
                Expanded(
                  child: SizedBox(
                    height: 74,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _attachedPhotos.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Container(
                              width: 74,
                              height: 74,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(11),
                                child: _photoThumbnail(_attachedPhotos[index]),
                              ),
                            ),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: GestureDetector(
                                onTap: () => _removePhoto(index),
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ] else ...[
                const Expanded(
                  child: Text(
                    'Maks. 3 foto sesudah\npengerjaan',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontFamily: 'Inter',
                      fontSize: 12.5,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _submitReview,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00685F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.send_rounded, size: 18),
                SizedBox(width: 8),
                Text(
                  widget.isEdit ? 'Simpan Perubahan' : 'Kirim Review',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => _navigateToHistoryOrders(context),
          child: const Text(
            'Nanti Saja',
            style: TextStyle(
              color: Color(0xFF475569),
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  const _DashedRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
    required this.radius,
  });

  final Color color;
  final double strokeWidth;
  final double gap;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final Path path = Path()..addRRect(rrect);
    final Path dashedPath = _createDashedPath(path, 6.0, gap);

    canvas.drawPath(dashedPath, paint);
  }

  Path _createDashedPath(Path source, double dashLength, double gapLength) {
    final Path dest = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final double length = draw ? dashLength : gapLength;
        if (draw) {
          dest.addPath(
            metric.extractPath(distance, distance + length),
            Offset.zero,
          );
        }
        distance += length;
        draw = !draw;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(_DashedRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.gap != gap ||
        oldDelegate.radius != radius;
  }
}
