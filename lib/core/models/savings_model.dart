class SavingsTransaction {
  final int id;
  final String type;
  final String description;
  final int amount;
  final String date;
  final int balanceAfter;
  final bool isDebit;

  const SavingsTransaction({
    required this.id,
    required this.type,
    required this.description,
    required this.amount,
    required this.date,
    required this.balanceAfter,
    required this.isDebit,
  });

  factory SavingsTransaction.fromJson(Map<String, dynamic> json) {
    return SavingsTransaction(
      id: json['id'] as int? ?? 0,
      type: json['type'] as String? ?? '',
      description: json['description'] as String? ?? '',
      amount: json['amount'] as int? ?? 0,
      date: json['date'] as String? ?? json['created_at'] as String? ?? '',
      balanceAfter: json['balance_after'] as int? ?? 0,
      isDebit: json['is_debit'] as bool? ?? false,
    );
  }
}

class SavingsData {
  final int balance;
  final String balanceFormatted;
  final String studentName;
  final int dailyLimit;
  final int pocketMoney;
  final int totalIncome;
  final int totalExpense;
  final List<SavingsTransaction> history;

  const SavingsData({
    required this.balance,
    required this.balanceFormatted,
    required this.studentName,
    required this.dailyLimit,
    required this.pocketMoney,
    required this.totalIncome,
    required this.totalExpense,
    required this.history,
  });

  factory SavingsData.fromJson(Map<String, dynamic> json) {
    return SavingsData(
      balance: json['balance'] as int? ?? 0,
      balanceFormatted: json['balance_formatted'] as String? ?? '',
      studentName: json['student_name'] as String? ?? '',
      dailyLimit: json['daily_limit'] as int? ?? 0,
      pocketMoney: json['pocket_money'] as int? ?? 0,
      totalIncome: json['total_income'] as int? ?? 0,
      totalExpense: json['total_expense'] as int? ?? 0,
      history: (json['history'] as List<dynamic>?)
              ?.map((e) =>
                  SavingsTransaction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class SavingsResponse {
  final bool success;
  final SavingsData? data;
  final String? message;

  const SavingsResponse({
    required this.success,
    this.data,
    this.message,
  });

  factory SavingsResponse.fromJson(Map<String, dynamic> json) {
    return SavingsResponse(
      success: json['success'] as bool? ?? false,
      data: json['data'] != null
          ? SavingsData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      message: json['message'] as String?,
    );
  }
}
