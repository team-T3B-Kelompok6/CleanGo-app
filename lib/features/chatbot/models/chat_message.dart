class ChatMessage {
  const ChatMessage({
    required this.content,
    required this.isUser,
    this.failed = false,
  });

  final String content;
  final bool isUser;
  final bool failed;

  Map<String, String> toJson() => {
    'role': isUser ? 'user' : 'assistant',
    'content': content.length > 2000 ? content.substring(0, 2000) : content,
  };
}
