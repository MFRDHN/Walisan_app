import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';

class BillScreen extends StatefulWidget {
  const BillScreen({super.key});

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  final List<Map<String, dynamic>> _bills = [
    {
      'title': 'Listrik PLN',
      'due': '10 Mei 2026',
      'amount': 'Rp 350.000',
      'status': 'Belum Bayar',
      'icon': Icons.bolt_outlined,
      'isPaid': false,
    },
    {
      'title': 'Air PDAM',
      'due': '15 Mei 2026',
      'amount': 'Rp 120.000',
      'status': 'Belum Bayar',
      'icon': Icons.water_drop_outlined,
      'isPaid': false,
    },
    {
      'title': 'Internet',
      'due': '20 Mei 2026',
      'amount': 'Rp 299.000',
      'status': 'Sudah Bayar',
      'icon': Icons.wifi_outlined,
      'isPaid': true,
    },
    {
      'title': 'Gas',
      'due': '5 Mei 2026',
      'amount': 'Rp 80.000',
      'status': 'Sudah Bayar',
      'icon': Icons.local_fire_department_outlined,
      'isPaid': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final unpaid = _bills.where((b) => !(b['isPaid'] as bool)).toList();
    final paid = _bills.where((b) => b['isPaid'] as bool).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.bill, style: AppTextStyles.headingMedium),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
            onPressed: () {
              // TODO: Add new bill
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total unpaid summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.error, Color(0xFFB71C1C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Tagihan Belum Dibayar',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp 470.000',
                    style: AppTextStyles.displayMedium
                        .copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.error,
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(AppStrings.payBill,
                        style: AppTextStyles.labelLarge
                            .copyWith(color: AppColors.error)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Belum Dibayar',
                textAlign: TextAlign.center,
                style: AppTextStyles.headingSmall),
            const SizedBox(height: 12),
            ...unpaid.map((b) => _BillCard(bill: b)),
            const SizedBox(height: 20),
            Text('Sudah Dibayar',
                textAlign: TextAlign.center,
                style: AppTextStyles.headingSmall),
            const SizedBox(height: 12),
            ...paid.map((b) => _BillCard(bill: b)),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _BillCard extends StatelessWidget {
  final Map<String, dynamic> bill;
  const _BillCard({required this.bill});

  @override
  Widget build(BuildContext context) {
    final isPaid = bill['isPaid'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: (isPaid ? AppColors.success : AppColors.warning)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              bill['icon'] as IconData,
              color: isPaid ? AppColors.success : AppColors.warning,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bill['title'] as String,
                    style: AppTextStyles.labelMedium),
                const SizedBox(height: 2),
                Text('Jatuh tempo: ${bill['due']}',
                    style: AppTextStyles.caption),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(bill['amount'] as String,
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: (isPaid ? AppColors.success : AppColors.warning)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  bill['status'] as String,
                  style: AppTextStyles.caption.copyWith(
                    color: isPaid ? AppColors.success : AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
