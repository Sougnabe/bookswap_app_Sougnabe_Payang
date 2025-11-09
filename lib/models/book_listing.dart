enum BookCondition { newCondition, likeNew, good, used }

class BookListing {
  final String id;
  final String title;
  final String author;
  final BookCondition condition;
  final String imageUrl;
  final String ownerId;
  final String ownerName;
  final DateTime createdAt;
  final bool isAvailable;

  BookListing({
    required this.id,
    required this.title,
    required this.author,
    required this.condition,
    required this.imageUrl,
    required this.ownerId,
    required this.ownerName,
    required this.createdAt,
    this.isAvailable = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'condition': condition.index,
      'imageUrl': imageUrl,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isAvailable': isAvailable,
    };
  }

  static BookListing fromMap(Map<String, dynamic> map) {
    return BookListing(
      id: map['id'],
      title: map['title'],
      author: map['author'],
      condition: BookCondition.values[map['condition']],
      imageUrl: map['imageUrl'],
      ownerId: map['ownerId'],
      ownerName: map['ownerName'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      isAvailable: map['isAvailable'],
    );
  }

  String get conditionString {
    switch (condition) {
      case BookCondition.newCondition:
        return 'New';
      case BookCondition.likeNew:
        return 'Like New';
      case BookCondition.good:
        return 'Good';
      case BookCondition.used:
        return 'Used';
    }
  }
}