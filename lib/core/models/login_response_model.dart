import 'user_model.dart';
import 'student_model.dart';

class LoginResponseModel {
  final bool success;
  final String message;
  final UserModel user;
  final StudentModel? student;
  final String token;

  const LoginResponseModel({
    required this.success,
    required this.message,
    required this.user,
    this.student,
    required this.token,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return LoginResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      user: data != null && data['user'] != null
          ? UserModel.fromJson(data['user'] as Map<String, dynamic>)
          : UserModel(id: 0, name: '', username: '', role: '', phone: ''),
      student: data?['student'] != null
          ? StudentModel.fromJson(data!['student'] as Map<String, dynamic>)
          : null,
      token: data?['token'] as String? ?? '',
    );
  }
}
