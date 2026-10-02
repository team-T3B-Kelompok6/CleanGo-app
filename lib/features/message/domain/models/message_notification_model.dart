enum MessageCategory { order, promo }

enum MessageIconType { delivery, confirmed, delayed, payment, promo, rating }

class MessageNotificationModel {
  const MessageNotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.timeLabel,
    required this.category,
    required this.iconType,
    this.isUnread = false,
    this.isWarning = false,
    this.badge,
  });

  final String id;
  final String title;
  final String description;
  final String timeLabel;
  final MessageCategory category;
  final MessageIconType iconType;
  final bool isUnread;
  final bool isWarning;
  final String? badge;

  MessageNotificationModel copyWith({
    String? id,
    String? title,
    String? description,
    String? timeLabel,
    MessageCategory? category,
    MessageIconType? iconType,
    bool? isUnread,
    bool? isWarning,
    String? badge,
  }) {
    return MessageNotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timeLabel: timeLabel ?? this.timeLabel,
      category: category ?? this.category,
      iconType: iconType ?? this.iconType,
      isUnread: isUnread ?? this.isUnread,
      isWarning: isWarning ?? this.isWarning,
      badge: badge ?? this.badge,
    );
  }
}
