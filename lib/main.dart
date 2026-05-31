import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/change_password_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/reset_password_screen.dart';
import 'features/auth/screens/sign_in_screen.dart';
import 'features/auth/screens/sign_up_screen.dart';
import 'features/auth/screens/verify_otp_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/services/screens/profile_screen.dart';
import 'features/services/screens/exam_screen.dart';
import 'features/services/screens/rapot_online_screen.dart';
import 'features/services/screens/customer_service_screen.dart';
import 'features/transaction/screens/bill_screen.dart';
import 'features/transaction/screens/savings_screen.dart';
import 'features/transaction/screens/payment_screen.dart';
import 'features/transaction/screens/history_screen.dart';

void main() {
  runApp(const WalisanApp());
}

class WalisanApp extends StatelessWidget {
  const WalisanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UG Smart System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/sign-in': (context) => const SignInScreen(),
        '/sign-up': (context) => const SignUpScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/reset-password': (context) {
          final phone = ModalRoute.of(context)?.settings.arguments as String?;
          return ResetPasswordScreen(phone: phone ?? '');
        },
        '/verify-otp': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>;
          return VerifyOtpScreen(
            userId: args['user_id'] as int,
            phone: args['phone'] as String,
          );
        },
        '/home': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          return HomeScreen(loginData: args as String?);
        },
        '/profile': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          return ProfileScreen(loginData: args as String?);
        },
        '/exam': (context) => const ExamScreen(),
        '/bill': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          return BillScreen(loginData: args as String?);
        },
        '/payment': (context) => const PaymentScreen(),
        '/history': (context) => const HistoryScreen(),
        '/savings': (context) => const SavingsScreen(),
        '/change-password': (context) => const ChangePasswordScreen(),
        '/report': (context) => const RapotOnlineScreen(),
        '/customer-service': (context) => const CustomerServiceScreen(),
      },
    );
  }
}