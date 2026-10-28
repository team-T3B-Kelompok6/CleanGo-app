import '../../booking/domain/models/review_photo_model.dart';

class ReviewDraftController {
  ReviewDraftController({List<ReviewPhotoModel> initialPhotos = const []}) {
    _photos.addAll(initialPhotos.take(maxPhotos));
  }

  static const int maxPhotos = 3;
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
  final List<ReviewPhotoModel> _photos = [];
  final List<String> _removedPhotoIds = [];

  List<String> get selectedChips => List.unmodifiable(_selectedChips);
  List<ReviewPhotoModel> get photos => List.unmodifiable(_photos);
  List<String> get removedPhotoIds => List.unmodifiable(_removedPhotoIds);

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

  bool addPhoto(ReviewPhotoModel photo) {
    if (_photos.length >= maxPhotos) return false;
    _photos.add(photo);
    return true;
  }

  ReviewPhotoModel? removePhoto(int index) {
    if (index < 0 || index >= _photos.length) return null;
    final removed = _photos.removeAt(index);
    if (!removed.isNew && removed.id.isNotEmpty) {
      _removedPhotoIds.add(removed.id);
    }
    return removed;
  }
}
