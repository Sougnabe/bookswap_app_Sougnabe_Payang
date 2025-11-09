class ChatMessage {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isRead': isRead,
    };
  }

  static ChatMessage fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'],
      chatId: map['chatId'],
      senderId: map['senderId'],
      senderName: map['senderName'],
      message: map['message'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      isRead: map['isRead'],
    );
  }
}