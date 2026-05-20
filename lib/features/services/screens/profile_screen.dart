import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/custom_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.profile, style: AppTextStyles.headingMedium),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
            onPressed: () {
              // TODO: Navigate to edit profile
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildAvatarSection(),
            const SizedBox(height: 24),
            _buildInfoCard(),
            const SizedBox(height: 16),
            _buildMenuSection(context),
            const SizedBox(height: 24),
            CustomButton(
              label: AppStrings.logout,
              variant: ButtonVariant.outline,
              onPressed: () {
                // TODO: Implement logout
              },
              prefixIcon: const Icon(Icons.logout_rounded,
                  color: AppColors.primary, size: 18),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 52,
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              child: const Icon(Icons.person, color: AppColors.primary, size: 52),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt_outlined,
                    color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text('Nama Pengguna',
            textAlign: TextAlign.center,
            style: AppTextStyles.headingLarge),
        const SizedBox(height: 4),
        Text('pengguna@email.com',
            style:
                AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.person_outline, 'Nama Lengkap', 'Nama Pengguna'),
          const Divider(height: 20),
          _buildInfoRow(Icons.email_outlined, 'Email', 'pengguna@email.com'),
          const Divider(height: 20),
          _buildInfoRow(Icons.phone_outlined, 'No. Telepon', '+62 812 3456 7890'),
          const Divider(height: 20),
          _buildInfoRow(Icons.cake_outlined, 'Tanggal Lahir', '01 Januari 1990'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption),
              const SizedBox(height: 2),
              Text(value, style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    final menus = [
      {'icon': Icons.security_outlined, 'label': 'Keamanan Akun'},
      {'icon': Icons.notifications_outlined, 'label': 'Notifikasi'},
      {'icon': Icons.language_outlined, 'label': 'Bahasa'},
      {'icon': Icons.help_outline_rounded, 'label': 'Bantuan & FAQ'},
      {'icon': Icons.info_outline_rounded, 'label': 'Tentang Aplikasi'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: menus.asMap().entries.map((entry) {
          final idx = entry.key;
          final menu = entry.value;
          return Column(
            children: [
              ListTile(
                leading: Icon(menu['icon'] as IconData,
                    color: AppColors.primary, size: 22),
                title: Text(menu['label'] as String,
                    style: AppTextStyles.bodyMedium),
                trailing: const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: AppColors.textSecondary),
                onTap: () {},
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              ),
              if (idx < menus.length - 1)
                const Divider(height: 1, indent: 54, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}
