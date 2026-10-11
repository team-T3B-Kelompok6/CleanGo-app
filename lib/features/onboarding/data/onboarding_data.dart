import '../domain/models/onboarding_item.dart';

abstract final class OnboardingData {
  static const List<OnboardingItem> items = [
    OnboardingItem(
      imagePath: 'assets/images/app_icon.png',
      title: 'Selamat Datang di CleanGo',
      description: 'Layanan kebersihan profesional untuk rumah dan ruangan impian Anda, rapi dan higienis hanya dengan beberapa sentuhan.',
    ),
    OnboardingItem(
      imagePath: 'assets/images/onboarding_cleaners.png',
      title: 'Pesan Layanan Lebih Mudah',
      description: 'Cukup pilih paket layanan pembersihan, tentukan jadwal staf, dan pantau pengerjaan secara transparan.',
    ),
    OnboardingItem(
      imagePath: 'assets/images/onboarding_relax.png',
      title: 'Santai & Nikmati Rumah Bersih',
      description: 'Ruangan Anda bersih berkilau dan higienis tanpa repot. Nikmati waktu luang berharga bersama keluarga.',
    ),
  ];
}
