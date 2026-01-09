enum MessageRole { user, ai }

class AiMessage {
  final String text;
  final MessageRole role;
  final DateTime createdAt;

  AiMessage({
    required this.text,
    required this.role,
    required this.createdAt,
  });
}
