import 'dart:typed_data';

class ReviewPhotoModel {
  const ReviewPhotoModel({
    this.id = '',
    this.url,
    this.bytes,
    this.contentType,
  });

  final String id;
  final String? url;
  final Uint8List? bytes;
  final String? contentType;

  bool get isNew => bytes != null;
}
