class ReviewDraftController {
  static const int maxPhotos = 3;
  static const String mockPhotoPath = 'assets/images/ac_service.jpeg';
  static const List<String> availableChips = [
    'Bersih Maksimal ✨',
    'Tepat Waktu ⏰',
    'Ramah & Sopan 😊',
    'Peralatan Lengkap 📦',
  ];

  int selectedRating = 5;
  final List<String> _selectedChips = [
    'Bersih Maksimal ✨',
    'Tepat Waktu ⏰',
    'Peralatan Lengkap 📦',
  ];
  final List<String> _attachedPhotos = [];

  List<String> get selectedChips => List.unmodifiable(_selectedChips);
  List<String> get attachedPhotos => List.unmodifiable(_attachedPhotos);

  String get ratingLabel => switch (selectedRating) {
    5 => 'Sempurna (5/5)',
    4 => 'Sangat Baik (4/5)',
    3 => 'Cukup Baik (3/5)',
    2 => 'Kurang Memuaskan (2/5)',
    1 => 'Kecewa (1/5)',
    _ => 'Sempurna (5/5)',
  };

  void selectRating(int rating) {
    if (rating >= 1 && rating <= 5) selectedRating = rating;
  }

  void toggleChip(String chip) {
    if (_selectedChips.contains(chip)) {
      _selectedChips.remove(chip);
    } else {
      _selectedChips.add(chip);
    }
  }

  bool addMockPhoto() {
    if (_attachedPhotos.length >= maxPhotos) return false;
    _attachedPhotos.add(mockPhotoPath);
    return true;
  }

  void removePhoto(int index) => _attachedPhotos.removeAt(index);
}
