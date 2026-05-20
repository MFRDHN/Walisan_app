import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  int _selectedMethod = 0;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {'label': 'Saldo Walisan', 'icon': Icons.account_balance_wallet_outlined},
    {'label': 'Transfer Bank', 'icon': Icons.account_balance_outlined},
    {'label': 'QRIS', 'icon': Icons.qr_code_scanner_outlined},
  ];

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onPay() async {
    setState(() => _isLoading = true);
    // TODO: Implement payment logic
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_outline,
                    color: AppColors.success, size: 36),
              ),
              const SizedBox(height: 16),
              Text('Pembayaran Berhasil!',
                  style: AppTextStyles.headingMedium),
              const SizedBox(height: 8),
              Text('Transaksi Anda telah berhasil diproses.',
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary),
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              CustomButton(
                  label: AppStrings.done,
                  onPressed: () => Navigator.pop(context)),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.payment, style: AppTextStyles.headingMedium),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet_outlined,
                      color: AppColors.primary, size: 22),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.myBalance,
                          style: AppTextStyles.caption),
                      Text('Rp 12.500.000',
                          style: AppTextStyles.headingSmall
                              .copyWith(color: AppColors.primary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Payment method
            Text('Metode Pembayaran',
                textAlign: TextAlign.center,
                style: AppTextStyles.headingSmall),
            const SizedBox(height: 12),
            Row(
              children: _paymentMethods.asMap().entries.map((e) {
                final isSelected = _selectedMethod == e.key;
                final method = e.value;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedMethod = e.key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: EdgeInsets.only(
                          right: e.key < _paymentMethods.length - 1 ? 8 : 0),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            method['icon'] as IconData,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            size: 22,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            method['label'] as String,
                            style: AppTextStyles.caption.copyWith(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            CustomTextField(
              label: 'Tujuan / Penerima',
              hint: 'Nomor rekening atau nama',
              controller: _recipientController,
              keyboardType: TextInputType.text,
              prefixIcon: const Icon(Icons.person_outline,
                  color: AppColors.textSecondary, size: 20),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Jumlah Pembayaran',
              hint: '0',
              controller: _amountController,
              keyboardType: TextInputType.number,
              prefixIcon: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Text('Rp',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                        fontSize: 15)),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Catatan (Opsional)',
              hint: 'Tambahkan catatan...',
              controller: _noteController,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 28),
            // Summary
            Container(
              padding: const EdgeInsets.all(16),
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
              child: Column(
                children: [
                  _buildSummaryRow('Jumlah', 'Rp 0'),
                  const Divider(height: 16),
                  _buildSummaryRow('Biaya Admin', 'Rp 0'),
                  const Divider(height: 16),
                  _buildSummaryRow('Total', 'Rp 0', isTotal: true),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              label: AppStrings.payNow,
              onPressed: _onPay,
              isLoading: _isLoading,
              prefixIcon: const Icon(Icons.payment_outlined,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? AppTextStyles.labelMedium
              : AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: isTotal
              ? AppTextStyles.headingSmall.copyWith(color: AppColors.primary)
              : AppTextStyles.bodyMedium,
        ),
      ],
    );
  }
}
