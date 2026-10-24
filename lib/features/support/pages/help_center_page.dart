import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_dialog.dart';
import '../../../shared/widgets/app_notice.dart';
import '../../../shared/widgets/chatbot_button.dart';
import '../../../shared/widgets/chatbot_icon.dart';
import '../../chatbot/pages/chatbot_page.dart';
import '../controllers/support_controller.dart';
import '../models/faq_item_model.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  final TextEditingController _questionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<SupportController>().loadFromApi();
    });
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  void _openChatbot({String? question}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatbotPage(initialMessage: question),
      ),
    );
  }

  void _askBoo() {
    final question = _questionController.text.trim();
    if (question.isEmpty) return;
    if (question.length > 2000) {
      AppNotice.show(
        context,
        'Pertanyaan maksimal 2000 karakter.',
        type: AppNoticeType.error,
      );
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    setState(_questionController.clear);
    _openChatbot(question: question);
  }

  void _showContactSnackBar(String message) {
    AppNotice.show(context, message, type: AppNoticeType.info);
  }

  void _showHelpInfoModal() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AppDialog(
          title: 'Pusat Dukungan',
          message:
              'Customer Service tersedia setiap hari pukul 07.00–22.00 WIB. '
              'Untuk pertanyaan seputar layanan, Anda juga dapat bertanya kepada Boo.',
          confirmLabel: 'Mengerti',
          onConfirm: () => Navigator.pop(context),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final supportController = context.watch<SupportController>();
    final faqs = supportController.allFaqs;
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
                        _buildQuestionBar(),
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
                            Expanded(
                              child: _buildSectionTitle(
                                'PERTANYAAN POPULER (FAQ)',
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildTopicBadge(totalTopics),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildFaqCard(
                          supportController,
                          supportController.popularFaqs,
                        ),
                        const SizedBox(height: 24),
                        _buildSectionTitle('SEMUA PERTANYAAN'),
                        const SizedBox(height: 10),
                        _buildFaqSection(supportController, faqs),
                        const SizedBox(height: 24),
                        // Section 3: Bantuan Lainnya
                        _buildSectionTitle('BANTUAN LAINNYA'),
                        const SizedBox(height: 10),
                        _buildOtherHelpCard(supportController),
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
          const Expanded(
            child: Text(
              'Pusat Bantuan & FAQ',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontFamily: AppTheme.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
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

  Widget _buildQuestionBar() {
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
        key: const ValueKey('help-question-input'),
        controller: _questionController,
        onChanged: (_) => setState(() {}),
        textInputAction: TextInputAction.send,
        onSubmitted: (_) => _askBoo(),
        style: const TextStyle(
          color: Color(0xFF1E293B),
          fontFamily: AppTheme.fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Tanyakan ke Boo tentang CleanGo...',
          hintStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontFamily: AppTheme.fontFamily,
            fontSize: 14,
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.all(12),
            child: ChatbotIcon(size: 28),
          ),
          suffixIcon: IconButton(
            tooltip: 'Tanya Boo',
            onPressed: _questionController.text.trim().isEmpty ? null : _askBoo,
            icon: const Icon(Icons.send_rounded),
            color: AppColors.primary,
          ),
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
    bool? expanded,
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
            Icon(
              expanded == null
                  ? Icons.chevron_right_rounded
                  : expanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: const Color(0xFF94A3B8),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// White card holding a list of questions.
  Widget _buildFaqCard(
    SupportController controller,
    List<FaqItemModel> faqs,
  ) {
    if (faqs.isEmpty) {
      return const SizedBox.shrink();
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
        itemBuilder: (context, index) => _buildFaqItem(controller, faqs[index]),
      ),
    );
  }

  /// Every question, grouped per category.
  Widget _buildFaqSection(
    SupportController controller,
    List<FaqItemModel> faqs,
  ) {
    final groups = controller.groupByCategory(faqs);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final entry in groups.entries) ...[
          _buildCategoryLabel(entry.key, entry.value.length),
          const SizedBox(height: 8),
          _buildFaqCard(controller, entry.value),
          const SizedBox(height: 14),
        ],
      ],
    );
  }

  Widget _buildCategoryLabel(String category, int count) {
    return Row(
      children: [
        const Icon(
          Icons.folder_outlined,
          size: 15,
          color: AppColors.primaryAction,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            category,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.primaryAction,
              fontFamily: AppTheme.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ),
        Text(
          '$count',
          style: const TextStyle(
            color: AppColors.slate500,
            fontFamily: AppTheme.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildFaqItem(SupportController controller, FaqItemModel faq) {
    return InkWell(
      key: ValueKey(faq.id),
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
                      textAlign: TextAlign.justify,
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

  Widget _buildOtherHelpCard(SupportController controller) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildActionTile(
            icon: Icons.description_outlined,
            title: 'Syarat & Ketentuan Layanan',
            subtitle: 'Kebijakan garansi, privasi, dan ganti rugi',
            expanded: controller.termsExpanded,
            onTap: controller.toggleTerms,
          ),
          if (controller.termsExpanded)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
            textAlign: TextAlign.justify,
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
