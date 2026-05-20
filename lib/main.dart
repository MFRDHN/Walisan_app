import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/sign_in_screen.dart';
import 'features/auth/screens/sign_up_screen.dart';
import 'features/auth/screens/verify_otp_screen.dart';
import 'features/home/screens/home_screen.dart';

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
      },
    );
  }
}