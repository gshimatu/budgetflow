class UserModel {
  const UserModel({
    required this.uid,
    required this.email,
    required this.role,
    required this.createdAt,
    this.displayName,
    this.photoUrl,
  });

  final String uid;
  final String email;
  final String role;
  final DateTime createdAt;
  final String? displayName;
  final String? photoUrl;

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] as String,
      email: data['email'] as String,
      role: data['role'] as String? ?? 'user',
      createdAt: DateTime.parse(data['createdAt'] as String),
      displayName: data['displayName'] as String?,
      photoUrl: data['photoURL'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'displayName': displayName,
      'photoURL': photoUrl,
    };
  }
}
