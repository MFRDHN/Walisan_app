class RegisterResponseModel {
  final bool success;
  final String message;
  final int userId;
  final String phone;
  final String token;

  const RegisterResponseModel({
    required this.success,
    required this.message,
    required this.userId,
    required this.phone,
    required this.token,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    final user = data?['user'] as Map<String, dynamic>?;
    return RegisterResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      userId: user?['id'] as int? ?? 0,
      phone: data?['phone'] as String? ?? '',
      token: data?['token'] as String? ?? '',
    );
  }
}
