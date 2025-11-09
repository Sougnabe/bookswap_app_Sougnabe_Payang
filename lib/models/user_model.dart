class AppUser {
  final String id;
  final String email;
  final String displayName;
  final bool isEmailVerified;
  final DateTime? createdAt;

  AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.isEmailVerified,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt?.millisecondsSinceEpoch,
    };
  }

  static AppUser fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'],
      email: map['email'],
      displayName: map['displayName'],
      isEmailVerified: map['isEmailVerified'],
      createdAt: map['createdAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : null,
    );
  }
}