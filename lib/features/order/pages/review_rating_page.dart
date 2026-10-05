import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../controllers/order_controller.dart';
import 'orders_page.dart';

class ReviewRatingPage extends StatefulWidget {
  const ReviewRatingPage({
    super.key,
    this.orderId = '#CG-82910',
    this.serviceName = 'Deep Cleaning',
    this.serviceImagePath = 'assets/images/service_deep_cleaning.jpeg',
  });

  final String orderId;
  final String serviceName;
  final String serviceImagePath;

  @override
  State<ReviewRatingPage> createState() => _ReviewRatingPageState();
}

class _ReviewRatingPageState extends State<ReviewRatingPage> {
  int _selectedRating = 5;
  final List<String> _selectedChips = [
    'Bersih Maksimal ✨',
    'Tepat Waktu ⏰',
    'Peralatan Lengkap 📦',
  ];
  final TextEditingController _reviewController = TextEditingController();
  final List<String> _attachedPhotos = [];

  final List<String> _availableChips = [
    'Bersih Maksimal ✨',
    'Tepat Waktu ⏰',
    'Ramah & Sopan 😊',
    'Peralatan Lengkap 📦',
  ];

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  String get _ratingLabel {
    switch (_selectedRating) {
      case 5:
        return 'Sempurna (5/5)';
      case 4:
        return 'Sangat Baik (4/5)';
      case 3:
        return 'Cukup Baik (3/5)';
      case 2:
        return 'Kurang Memuaskan (2/5)';
      case 1:
        return 'Kecewa (1/5)';
      default:
        return 'Sempurna (5/5)';
    }
  }

  void _toggleChip(String chip) {
    setState(() {
      if (_selectedChips.contains(chip)) {
        _selectedChips.remove(chip);
      } else {
        _selectedChips.add(chip);
      }
    });
  }

  void _addMockPhoto() {
    if (_attachedPhotos.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Maksimal 3 foto yang dapat dilampirkan.',
            style: TextStyle(fontFamily: 'Inter'),
          ),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _attachedPhotos.add('assets/images/ac_clean.png');
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Foto hasil pengerjaan #${_attachedPhotos.length} berhasil ditambahkan!',
          style: const TextStyle(fontFamily: 'Inter'),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _removePhoto(int index) {
    setState(() {
      _attachedPhotos.removeAt(index);
    });
  }

  void _navigateToHistoryOrders(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => const OrdersPage(initialTab: OrdersTab.history),
      ),
      (route) => route.isFirst,
    );
  }

  void _submitReview() {
    final orderController = context.read<OrderController>();
    orderController.submitReview(
      orderId: widget.orderId,
      rating: _selectedRating,
      tags: _selectedChips,
      comment: _reviewController.text.trim(),
      photos: _attachedPhotos,
    );

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFE6FAF7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF00685F),
                  size: 38,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Terima Kasih!',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ulasan dan rating Anda sangat berarti untuk membantu kami menjaga kualitas layanan CleanGo.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogCtx).pop();
                    _navigateToHistoryOrders(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00685F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Selesai',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRating = starIndex;
                  });
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
              );
            }),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDFA),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF2DD4BF), width: 1.2),
            ),
            child: Text(
              _ratingLabel,
              style: const TextStyle(
                color: Color(0xFF0F766E),
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
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
                    chip,
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
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Tombol dashed "Tambah"
              GestureDetector(
                onTap: _addMockPhoto,
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
                                child: Image.asset(
                                  _attachedPhotos[index],
                                  fit: BoxFit.cover,
                                ),
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
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.send_rounded, size: 18),
                SizedBox(width: 8),
                Text(
                  'Kirim Review',
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
