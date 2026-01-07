class User {
  final String username;
  final String password; // Stored as plain text for mock/demo purposes
  final DateTime createdAt;

  User({
    required this.username,
    required this.password,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      password: json['password'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
