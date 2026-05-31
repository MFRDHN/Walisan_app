import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';
import '../network/api_config.dart';
import '../../features/auth/screens/login_screen.dart';

class LogoutService {
  static Future<void> execute(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token != null) {
        try {
          final client = ApiClient();
          await client.post(ApiConfig.logout, token: token);
          client.dispose();
        } catch (_) {
          // Tetap lanjutkan meski panggilan API gagal
        }
      }

      await prefs.remove('token');
      await prefs.remove('cached_photo_bytes');

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (_) {
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }
}
