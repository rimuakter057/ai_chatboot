/// Delivery status of a chat message.
enum MessageStatus {
  /// Delivered successfully (default for user messages and normal replies).
  sent,

  /// The simulated AI backend failed to produce a reply; [ChatMessage.retryText]
  /// holds the original user text so the failed exchange can be retried.
  error,
}

/// Represents a single message in the chat conversation.
class ChatMessage {
  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.status = MessageStatus.sent,
    this.retryText,
  }) : timestamp = timestamp ?? DateTime.now();

  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final MessageStatus status;

  /// For a failed bot reply, the original user text that should be resent
  /// when the user taps "Retry".
  final String? retryText;

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
        'status': status.name,
        'retryText': retryText,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        text: json['text'] as String,
        isUser: json['isUser'] as bool,
        timestamp: DateTime.parse(json['timestamp'] as String),
        status: MessageStatus.values.byName(
          json['status'] as String? ?? 'sent',
        ),
        retryText: json['retryText'] as String?,
      );
}
