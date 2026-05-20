class RegisterResponseModel {
  final bool success;
  final String message;
  final int userId;
  final String phone;

  const RegisterResponseModel({
    required this.success,
    required this.message,
    required this.userId,
    required this.phone,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return RegisterResponseModel(
      success: json['success'] as bool,
      message: json['message'] as String,
      userId: data['user_id'] as int,
      phone: data['phone'] as String,
    );
  }
}
