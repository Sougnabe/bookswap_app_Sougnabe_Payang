enum SwapStatus { pending, accepted, rejected, completed }

class SwapOffer {
  final String id;
  final String bookId;
  final String bookTitle;
  final String bookImageUrl;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String receiverName;
  final SwapStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  SwapOffer({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.bookImageUrl,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'bookImageUrl': bookImageUrl,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'status': status.index,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  static SwapOffer fromMap(Map<String, dynamic> map) {
    return SwapOffer(
      id: map['id'],
      bookId: map['bookId'],
      bookTitle: map['bookTitle'],
      bookImageUrl: map['bookImageUrl'],
      senderId: map['senderId'],
      senderName: map['senderName'],
      receiverId: map['receiverId'],
      receiverName: map['receiverName'],
      status: SwapStatus.values[map['status']],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
    );
  }

  String get statusString {
    switch (status) {
      case SwapStatus.pending:
        return 'Pending';
      case SwapStatus.accepted:
        return 'Accepted';
      case SwapStatus.rejected:
        return 'Rejected';
      case SwapStatus.completed:
        return 'Completed';
    }
  }
}