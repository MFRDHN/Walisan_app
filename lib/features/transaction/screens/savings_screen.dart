import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _savingsHistory = [
    {'date': '1 Mei 2026', 'amount': '+ Rp 500.000', 'type': 'Setor'},
    {'date': '25 Apr 2026', 'amount': '+ Rp 300.000', 'type': 'Setor'},
    {'date': '15 Apr 2026', 'amount': '- Rp 150.000', 'type': 'Tarik'},
    {'date': '5 Apr 2026', 'amount': '+ Rp 750.000', 'type': 'Setor'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.savings, style: AppTextStyles.headingMedium),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.secondary, AppColors.secondaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.myBalance,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp 5.300.000',
                    style: AppTextStyles.displayLarge
                        .copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showDepositSheet(context),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Setor'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.secondary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showWithdrawSheet(context),
                          icon: const Icon(Icons.remove, size: 18),
                          label: const Text('Tarik'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Savings goal
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Target Tabungan',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.headingSmall),
                      Text('53%',
                          style: AppTextStyles.headingSmall.copyWith(
                              color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Rp 5.300.000 / Rp 10.000.000',
                      style: AppTextStyles.bodySmall),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: 0.53,
                      backgroundColor: AppColors.border,
                      color: AppColors.primary,
                      minHeight: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Riwayat Tabungan',
                textAlign: TextAlign.center,
                style: AppTextStyles.headingSmall),
            const SizedBox(height: 12),
            ..._savingsHistory.map((h) {
              final isDeposit = (h['type'] as String) == 'Setor';
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 4,
                        offset: const Offset(0, 2)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: (isDeposit
                                ? AppColors.success
                                : AppColors.error)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isDeposit
                            ? Icons.arrow_downward_rounded
                            : Icons.arrow_upward_rounded,
                        color: isDeposit
                            ? AppColors.success
                            : AppColors.error,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(h['type'] as String,
                              style: AppTextStyles.labelMedium),
                          Text(h['date'] as String,
                              style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                    Text(
                      h['amount'] as String,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: isDeposit
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showDepositSheet(BuildContext context) {
    _showAmountSheet(context, 'Setor Tabungan', AppColors.secondary);
  }

  void _showWithdrawSheet(BuildContext context) {
    _showAmountSheet(context, 'Tarik Tabungan', AppColors.error);
  }

  void _showAmountSheet(BuildContext context, String title, Color color) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 20),
              Text(title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headingMedium),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Jumlah',
                hint: 'Masukkan jumlah',
                controller: _amountController,
                keyboardType: TextInputType.number,
                prefixIcon: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('Rp',
                      style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500)),
                ),
              ),
              const SizedBox(height: 20),
              CustomButton(
                label: title,
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
