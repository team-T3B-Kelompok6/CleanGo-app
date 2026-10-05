import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/chatbot_button.dart';
import '../../chatbot/pages/chatbot_page.dart';
import '../controllers/support_controller.dart';
import '../models/faq_item_model.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openChatbot() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const ChatbotPage()));
  }

  void _showContactSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: AppTheme.fontFamily,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  void _showTermsModal() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollController) {
            return Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Syarat & Ketentuan Layanan',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: const [
                      _TermsSection(
                        title: '1. Jaminan Garansi 100%',
                        description: 'CleanGo menjamin kepuasan pelanggan melalui inspeksi pengerjaan. Jika pelanggan mendapati area yang kurang bersih, pengajuan re-cleaning dapat dilakukan dalam 1x24 jam secara gratis.',
                      ),
                      _TermsSection(
                        title: '2. Kebijakan Reschedule & Pembatalan',
                        description: 'Perubahan jadwal dan pembatalan dapat dilakukan maksimal H-1 atau 24 jam sebelum waktu pengerjaan. Setelah batas tersebut, hubungi WhatsApp CS CleanGo untuk bantuan.',
                      ),
                      _TermsSection(
                        title: '3. Perlindungan & Asuransi Barang',
                        description: 'Seluruh staf cleaner telah melalui uji integritas dan verifikasi identitas resmi. CleanGo menanggung penggantian kerugian hingga Rp 5.000.000 untuk kerusakan yang terbukti akibat kelalaian staf.',
                      ),
                      _TermsSection(
                        title: '4. Privasi & Keamanan Data',
                        description: 'Data identitas, nomor kontak, serta alamat rumah pelanggan dilindungi dengan enkripsi ketat dan hanya digunakan untuk keperluan layanan pembersihan CleanGo.',
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showHelpInfoModal() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.help_outline_rounded, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Pusat Dukungan',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: const Text(
            'Layanan Customer Service CleanGo beroperasi setiap hari pukul 07.00 - 22.00 WIB. Untuk respon tercepat, Anda juga dapat bertanya langsung ke asisten Boo! di pojok kanan bawah.',
            style: TextStyle(
              color: Color(0xFF475569),
              fontFamily: AppTheme.fontFamily,
              fontSize: 13.5,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Mengerti',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final supportController = context.watch<SupportController>();
    final faqs = supportController.filteredFaqs;
    final totalTopics = supportController.totalTopicsCount;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // App Bar
                  _buildHeader(context),
                  // Content Scrollable
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 96),
                      children: [
                        // Search Bar
                        _buildSearchBar(supportController),
                        const SizedBox(height: 20),
                        // Section 1: Kontak Customer Service
                        _buildSectionTitle('KONTAK CUSTOMER SERVICE'),
                        const SizedBox(height: 10),
                        _buildContactCard(),
                        const SizedBox(height: 24),
                        // Section 2: Pertanyaan Populer (FAQ)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSectionTitle('PERTANYAAN POPULER (FAQ)'),
                            _buildTopicBadge(totalTopics),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildFaqSection(supportController, faqs),
                        const SizedBox(height: 24),
                        // Section 3: Bantuan Lainnya
                        _buildSectionTitle('BANTUAN LAINNYA'),
                        const SizedBox(height: 10),
                        _buildOtherHelpCard(),
                      ],
                    ),
                  ),
                ],
              ),
              // Floating Chatbot Button (Tanya Boo!)
              Positioned(
                right: 20,
                bottom: 24,
                child: ChatbotButton(onTap: _openChatbot),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  color: Color(0x08000000),
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
              onPressed: () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
            ),
          ),
          const Text(
            'Pusat Bantuan & FAQ',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontFamily: AppTheme.fontFamily,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          GestureDetector(
            onTap: _showHelpInfoModal,
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFFE6FAF7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.help_outline_rounded,
                color: Color(0xFF00685F),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(SupportController controller) {
    return Container(
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
      child: TextField(
        controller: _searchController,
        onChanged: (value) => controller.search(value),
        style: const TextStyle(
          color: Color(0xFF1E293B),
          fontFamily: AppTheme.fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Cari topik bantuan atau kendala...',
          hintStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontFamily: AppTheme.fontFamily,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF94A3B8),
            size: 22,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFF94A3B8),
                    size: 18,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    controller.resetSearch();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF335C57),
        fontFamily: AppTheme.fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
    );
  }

  Widget _buildTopicBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFE6FAF7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCCFBF1)),
      ),
      child: Text(
        '$count Topik',
        style: const TextStyle(
          color: Color(0xFF00685F),
          fontFamily: AppTheme.fontFamily,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
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
          // WhatsApp CS
          _buildActionTile(
            customIcon: Image.asset(
              'assets/icons/whatsapp.png',
              width: 24,
              height: 24,
            ),
            title: 'WhatsApp CS',
            subtitle: 'Respon cepat < 5 menit via chat',
            onTap: () => _showContactSnackBar(
              'Membuka WhatsApp CS CleanGo (+62 812-3456-7890)...',
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
          // Kirim Email CS
          _buildActionTile(
            icon: Icons.mail_outline_rounded,
            title: 'Kirim Email CS',
            subtitle: 'cs@cleango.id, Balasan 1–2 jam',
            onTap: () =>
                _showContactSnackBar('Menyiapkan email ke cs@cleango.id...'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    IconData? icon,
    Widget? customIcon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFE6FAF7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child:
                    customIcon ??
                    Icon(icon, color: const Color(0xFF00685F), size: 20),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqSection(
    SupportController controller,
    List<FaqItemModel> faqs,
  ) {
    if (faqs.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 40,
              color: Color(0xFF94A3B8),
            ),
            const SizedBox(height: 10),
            const Text(
              'Topik bantuan tidak ditemukan',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontFamily: AppTheme.fontFamily,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Coba kata kunci lain atau hubungi Customer Service kami.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF64748B),
                fontFamily: AppTheme.fontFamily,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                _searchController.clear();
                controller.resetSearch();
              },
              child: const Text(
                'Reset Pencarian',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
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
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: faqs.length,
        separatorBuilder: (_, _) =>
            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
        itemBuilder: (context, index) {
          final faq = faqs[index];
          return _buildFaqItem(controller, faq);
        },
      ),
    );
  }

  Widget _buildFaqItem(SupportController controller, FaqItemModel faq) {
    return InkWell(
      onTap: () => controller.toggleExpand(faq.id),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6FAF7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    faq.icon,
                    color: const Color(0xFF00685F),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    faq.question,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  faq.isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: const Color(0xFF94A3B8),
                  size: 22,
                ),
              ],
            ),
            if (faq.isExpanded) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 54, right: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      faq.answer,
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 13,
                        height: 1.45,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (faq.highlight != null) ...[
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle_outline_rounded,
                            color: Color(0xFF00685F),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              faq.highlight!,
                              style: const TextStyle(
                                color: Color(0xFF00685F),
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOtherHelpCard() {
    return Container(
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
      child: _buildActionTile(
        icon: Icons.description_outlined,
        title: 'Syarat & Ketentuan Layanan',
        subtitle: 'Kebijakan garansi, privasi, dan ganti rugi',
        onTap: _showTermsModal,
      ),
    );
  }
}

class _TermsSection extends StatelessWidget {
  const _TermsSection({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontFamily: AppTheme.fontFamily,
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontFamily: AppTheme.fontFamily,
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
