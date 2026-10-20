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

  /// Maps a backend notification into the app's inbox model.
  factory MessageNotificationModel.fromApiJson(
    Map<String, dynamic> json, {
    DateTime? now,
  }) {
    final type = json['type'] as String? ?? 'system';
    final (category, icon, warning) = switch (type) {
      'promo' => (MessageCategory.promo, MessageIconType.promo, false),
      'payment' => (MessageCategory.order, MessageIconType.payment, false),
      'risk_alert' => (MessageCategory.order, MessageIconType.delayed, true),
      'order' => (MessageCategory.order, MessageIconType.confirmed, false),
      _ => (MessageCategory.order, MessageIconType.confirmed, false),
    };
    return MessageNotificationModel(
      id: '${json['id'] ?? ''}',
      title: json['title'] as String? ?? 'Notifikasi',
      description: json['message'] as String? ?? '',
      timeLabel: relativeLabel(json['createdAt'] as String?, now: now),
      category: category,
      iconType: icon,
      isUnread: json['isRead'] != true,
      isWarning: warning,
    );
  }

  /// Short Indonesian relative label ("5 menit lalu").
  static String relativeLabel(String? iso, {DateTime? now}) {
    final parsed = iso == null ? null : DateTime.tryParse(iso);
    if (parsed == null) return '';
    final current = (now ?? DateTime.now()).toUtc();
    final difference = current.difference(parsed.toUtc());
    if (difference.inMinutes < 1) return 'Baru saja';
    if (difference.inMinutes < 60) return '${difference.inMinutes} menit lalu';
    if (difference.inHours < 24) return '${difference.inHours} jam lalu';
    if (difference.inDays < 7) return '${difference.inDays} hari lalu';
    final weeks = difference.inDays ~/ 7;
    return '$weeks minggu lalu';
  }

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
