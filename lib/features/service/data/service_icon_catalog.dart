abstract final class ServiceIconCatalog {
  static const String fallback = 'assets/icons/services.svg';
  static const String rumah = 'assets/icons/service_rumah.png';
  static const String kamar = 'assets/icons/service_kamar.png';
  static const String office = 'assets/icons/service_office.png';
  static const String sofa = 'assets/icons/service_sofa.png';
  static const String ac = 'assets/icons/service_ac.png';

  static String forCategory(String value) {
    final key = value.trim().toLowerCase();
    return switch (key) {
      'rumah' => rumah,
      'kamar dan kos' || 'kamar' || 'kos' => kamar,
      'kantor' => office,
      'sofa dan kasur' || 'sofa' || 'kasur' => sofa,
      'ac' => ac,
      _ => fallback,
    };
  }
}
