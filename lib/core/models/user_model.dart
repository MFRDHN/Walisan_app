class UserModel {
  final int id;
  final String name;
  final String username;
  final String role;
  final String phone;

  const UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.role,
    required this.phone,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      username: json['username'] as String,
      role: json['role'] as String,
      phone: json['phone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'role': role,
      'phone': phone,
    };
  }
}
