class ChatMessage {
  ChatMessage({
    required this.content,
    required this.isUser,
    this.failed = false,
    DateTime? createdAt,
  }) : createdAt = (createdAt ?? DateTime.now()).toUtc();

  static const retention = Duration(days: 3);

  final String content;
  final bool isUser;
  final bool failed;
  final DateTime createdAt;

  bool isExpired(DateTime now) => !createdAt.add(retention).isAfter(now);

  Map<String, String> toJson() => {
    'role': isUser ? 'user' : 'assistant',
    'content': content.length > 2000 ? content.substring(0, 2000) : content,
  };
}
