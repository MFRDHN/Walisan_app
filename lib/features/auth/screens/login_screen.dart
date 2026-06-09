import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF066A76), Color(0xFF0D7A77), Color(0xFF0A5E5B)],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── BACKGROUND KALIGRAFI ──────────────────────
            Opacity(
              opacity: 0.40,
              child: Image.asset(
                'assets/images/kaligrafi.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),

            // ── KONTEN UTAMA ──────────────────────────────
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  _buildLogo(),
                  const SizedBox(height: 20),
                  const Text(
                    'Walisan Smart App',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const Spacer(flex: 2),
                  _buildCard(context),
                  const Spacer(flex: 3),
                  const Text(
                    '© 2026 UQI SMART SYSTEM - V2.0',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      width: 342,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      decoration: BoxDecoration(
        color: const Color(0xFFBADADC),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Selamat Datang!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF424242),
            ),
          ),
          const SizedBox(height: 24),
          _buildActionButton(
            label: 'Daftar Santri Baru',
            gradient: const LinearGradient(
              colors: [Color(0xFFF87019), Color(0xFFF0493E)],
            ),
            onPressed: () => Navigator.pushNamed(context, '/sign-up'),
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            label: 'Masuk',
            gradient: const LinearGradient(
              colors: [Color(0xFF0A9B72), Color(0xFF076D50)],
            ),
            onPressed: () => Navigator.pushNamed(context, '/sign-in'),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {},
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Panduan Aplikasi',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF0D7A76),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.info_outline, size: 14, color: Color(0xFF0D7A76)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildWhatsappButton(onPressed: () => Navigator.pushNamed(context, '/customer-service')),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Gradient gradient,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(30),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildWhatsappButton({required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF66E021),
          borderRadius: BorderRadius.circular(25),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Whatsapp',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/LOGOOO.png',
      width: 73,
      height: 108,
      fit: BoxFit.contain,
    );
  }
}
