import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';

class HomeScreen extends StatelessWidget {
  final String? loginData;

  const HomeScreen({super.key, this.loginData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildBalanceCard(),
              _buildQuickActions(context),
              _buildRecentTransactions(),
            ],
          ),
        ),
      ),
    );
  }

  String get _userName {
    if (loginData == null) return 'Pengguna';
    try {
      final data = jsonDecode(loginData!);
      return data['user']['name'] as String? ?? 'Pengguna';
    } catch (_) {
      return 'Pengguna';
    }
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${AppStrings.greeting}, $_userName 👋',
                textAlign: TextAlign.center,
                style: AppTextStyles.headingSmall,
              ),
              const SizedBox(height: 2),
              Text(
                'Selamat datang kembali!',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: const Icon(Icons.person_outline,
                color: AppColors.primary, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.totalBalance,
            style: AppTextStyles.bodyMedium
                .copyWith(color: Colors.white.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 8),
          Text(
            'Rp 12.500.000',
            style: AppTextStyles.displayLarge.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildBalanceStat(
                  Icons.arrow_upward_rounded, 'Pemasukan', 'Rp 5.000.000'),
              const SizedBox(width: 24),
              _buildBalanceStat(
                  Icons.arrow_downward_rounded, 'Pengeluaran', 'Rp 2.500.000'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceStat(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.caption
                  .copyWith(color: Colors.white.withValues(alpha: 0.7)),
            ),
            Text(
              value,
              style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {'icon': Icons.receipt_long_outlined, 'label': AppStrings.bill},
      {'icon': Icons.savings_outlined, 'label': AppStrings.savings},
      {'icon': Icons.payment_outlined, 'label': AppStrings.payment},
      {'icon': Icons.bar_chart_outlined, 'label': AppStrings.report},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.quickActions, style: AppTextStyles.headingSmall),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: actions.map((a) {
              return _QuickActionItem(
                icon: a['icon'] as IconData,
                label: a['label'] as String,
                onTap: () {},
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    final transactions = [
      {
        'title': 'Pembayaran Tagihan',
        'date': '2 Mei 2026',
        'amount': '- Rp 350.000',
        'icon': Icons.receipt_outlined,
        'isDebit': true,
      },
      {
        'title': 'Tabungan Masuk',
        'date': '1 Mei 2026',
        'amount': '+ Rp 500.000',
        'icon': Icons.savings_outlined,
        'isDebit': false,
      },
      {
        'title': 'Transfer Keluar',
        'date': '30 Apr 2026',
        'amount': '- Rp 200.000',
        'icon': Icons.send_outlined,
        'isDebit': true,
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppStrings.recentTransactions,
                  style: AppTextStyles.headingSmall),
              TextButton(
                onPressed: () {},
                child: Text(AppStrings.seeAll, style: AppTextStyles.link),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...transactions.map((t) => _TransactionItem(
                title: t['title'] as String,
                date: t['date'] as String,
                amount: t['amount'] as String,
                icon: t['icon'] as IconData,
                isDebit: t['isDebit'] as bool,
              )),
        ],
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primary, size: 26),
          ),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final String title;
  final String date;
  final String amount;
  final IconData icon;
  final bool isDebit;

  const _TransactionItem({
    required this.title,
    required this.date,
    required this.amount,
    required this.icon,
    required this.isDebit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color:
                  (isDebit ? AppColors.error : AppColors.success).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon,
                color: isDebit ? AppColors.error : AppColors.success, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelMedium),
                const SizedBox(height: 2),
                Text(date, style: AppTextStyles.caption),
              ],
            ),
          ),
          Text(
            amount,
            style: AppTextStyles.labelMedium.copyWith(
              color: isDebit ? AppColors.error : AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}
