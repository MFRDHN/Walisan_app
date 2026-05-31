class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'https://dbs-santriapp.kypau.my.id';

  static const String login = '/api/login';
  static const String register = '/api/register';
  static const String verifyOtp = '/api/verify-otp';
  static const String resendOtp = '/api/resend-otp';
  static const String logout = '/api/logout';
  static const String dashboard = '/api/dashboard';
  static const String profile = '/api/profile';
  static const String profilePhoto = '/api/profile/photo';
  static const String changePassword = '/api/change-password';
  static const String forgotPassword = '/api/forgot-password';
  static const String resetPassword = '/api/reset-password';
  static const String bills = '/api/bills';
  static const String billsPay = '/api/bills/pay';
  static const String billsCheckStatus = '/api/bills/check-status';
  static const String billsHistoryPaid = '/api/bills/history/paid';
  static const String payments = '/api/payments';
  static const String savings = '/api/savings';
  static const String savingsTopup = '/api/savings/topup';
  static const String savingsHistory = '/api/savings/history';
  static const String savingsLimitUpdate = '/api/savings/limit';
  static const String savingsCheckStatus = '/api/savings/check-status';
  static const String exams = '/api/exams';
  static const String examsStart = '/api/exams/start';
  static const String examsSaveAnswer = '/api/exams/save-answer';
  static const String examsSubmit = '/api/exams/submit';
  static const String examsResult = '/api/exams/result';
  static const String reports = '/api/reports';
  static const String user = '/api/user';
}
