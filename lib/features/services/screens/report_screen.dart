import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int _selectedPeriod = 0;
  final List<String> _periods = ['Minggu ini', 'Bulan ini', 'Tahun ini'];

  final List<Map<String, dynamic>> _reportData = [
    {
      'label': 'Total Pemasukan',
      'value': 'Rp 8.500.000',
      'icon': Icons.arrow_upward_rounded,
      'color': AppColors.success,
      'trend': '+12%',
      'trendUp': true,
    },
    {
      'label': 'Total Pengeluaran',
      'value': 'Rp 3.200.000',
      'icon': Icons.arrow_downward_rounded,
      'color': AppColors.error,
      'trend': '-5%',
      'trendUp': false,
    },
    {
      'label': 'Total Tabungan',
      'value': 'Rp 5.300.000',
      'icon': Icons.savings_outlined,
      'color': AppColors.primary,
      'trend': '+8%',
      'trendUp': true,
    },
  ];

  final List<Map<String, dynamic>> _categories = [
    {'label': 'Tabungan', 'amount': 'Rp 2.000.000', 'percent': 0.38},
    {'label': 'Tagihan', 'amount': 'Rp 1.200.000', 'percent': 0.23},
    {'label': 'Pembayaran', 'amount': 'Rp 1.000.000', 'percent': 0.19},
    {'label': 'Lainnya', 'amount': 'Rp 1.100.000', 'percent': 0.20},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.report, style: AppTextStyles.headingMedium),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period selector
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: _periods.asMap().entries.map((e) {
                  final selected = _selectedPeriod == e.key;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedPeriod = e.key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.surface
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: AppColors.shadow,
                                    blurRadius: 4,
                                  )
                                ]
                              : [],
                        ),
                        child: Center(
                          child: Text(
                            e.value,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            // Summary cards
            ...(_reportData.map((data) => _buildSummaryCard(data))),
            const SizedBox(height: 20),
            Text('Kategori Pengeluaran',
                textAlign: TextAlign.center,
                style: AppTextStyles.headingSmall),
            const SizedBox(height: 12),
            Container(
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
                children: _categories.asMap().entries.map((e) {
                  return _buildCategoryRow(e.value, e.key);
                }).toList(),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (data['color'] as Color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(data['icon'] as IconData,
                color: data['color'] as Color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['label'] as String,
                    style: AppTextStyles.bodySmall),
                const SizedBox(height: 4),
                Text(data['value'] as String,
                    style: AppTextStyles.headingSmall),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (data['trendUp'] as bool
                      ? AppColors.success
                      : AppColors.error)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              data['trend'] as String,
              style: AppTextStyles.labelSmall.copyWith(
                color: data['trendUp'] as bool
                    ? AppColors.success
                    : AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(Map<String, dynamic> data, int index) {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent,
      AppColors.info,
    ];
    final color = colors[index % colors.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                      color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(data['label'] as String,
                      style: AppTextStyles.bodyMedium)),
              Text(data['amount'] as String,
                  style: AppTextStyles.labelMedium),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: data['percent'] as double,
              backgroundColor: AppColors.border,
              color: color,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
