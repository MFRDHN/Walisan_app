import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  int _selectedAnswer = -1;
  int _currentQuestion = 0;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Apa itu tabungan?',
      'options': [
        'Uang yang dipinjam dari bank',
        'Uang yang disimpan untuk masa depan',
        'Uang yang digunakan untuk belanja',
        'Uang yang diberikan sebagai hadiah',
      ],
      'answer': 1,
    },
    {
      'question': 'Apa fungsi utama asuransi?',
      'options': [
        'Menambah penghasilan',
        'Membeli barang mahal',
        'Melindungi dari risiko kerugian',
        'Membayar hutang',
      ],
      'answer': 2,
    },
    {
      'question': 'Apa yang dimaksud dengan investasi?',
      'options': [
        'Pengeluaran rutin bulanan',
        'Penanaman modal untuk mendapatkan keuntungan',
        'Pembayaran cicilan hutang',
        'Dana darurat',
      ],
      'answer': 1,
    },
  ];

  void _onNext() {
    if (_selectedAnswer == -1) return;
    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedAnswer = -1;
      });
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Ujian Selesai!'),
          content: const Text('Anda telah menyelesaikan semua soal.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _currentQuestion = 0;
                  _selectedAnswer = -1;
                });
              },
              child: const Text('Ulangi'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestion];
    final options = question['options'] as List;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.exam, style: AppTextStyles.headingMedium),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Soal ${_currentQuestion + 1} dari ${_questions.length}',
                    style: AppTextStyles.bodySmall),
                const Spacer(),
                Text(
                  '${((_currentQuestion + 1) / _questions.length * 100).toInt()}%',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (_currentQuestion + 1) / _questions.length,
                backgroundColor: AppColors.border,
                color: AppColors.primary,
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                question['question'] as String,
                textAlign: TextAlign.center,
                style: AppTextStyles.headingSmall
                    .copyWith(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: options.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final isSelected = _selectedAnswer == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedAnswer = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
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
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.surfaceVariant,
                            ),
                            child: Center(
                              child: Text(
                                String.fromCharCode(65 + index),
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              options[index] as String,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _selectedAnswer == -1 ? null : _onNext,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.border,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _currentQuestion < _questions.length - 1
                    ? AppStrings.next
                    : AppStrings.done,
                style: AppTextStyles.labelLarge,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
