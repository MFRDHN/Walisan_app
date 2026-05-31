import 'student_model.dart';

class DashboardStats {
  final int pendingBills;
  final int totalPaid;
  final String totalPaidFormatted;
  final int savingBalance;
  final String savingBalanceFormatted;
  final int upcomingExams;

  const DashboardStats({
    required this.pendingBills,
    required this.totalPaid,
    required this.totalPaidFormatted,
    required this.savingBalance,
    required this.savingBalanceFormatted,
    required this.upcomingExams,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      pendingBills: json['pending_bills'] as int? ?? 0,
      totalPaid: json['total_paid'] as int? ?? 0,
      totalPaidFormatted: json['total_paid_formatted'] as String? ?? '',
      savingBalance: json['saving_balance'] as int? ?? 0,
      savingBalanceFormatted:
          json['saving_balance_formatted'] as String? ?? '',
      upcomingExams: json['upcoming_exams'] as int? ?? 0,
    );
  }
}

class RecentBill {
  final int id;
  final String title;
  final int amount;
  final int paidAmount;
  final int remaining;
  final String dueDate;
  final String status;

  const RecentBill({
    required this.id,
    required this.title,
    required this.amount,
    required this.paidAmount,
    required this.remaining,
    required this.dueDate,
    required this.status,
  });

  factory RecentBill.fromJson(Map<String, dynamic> json) {
    return RecentBill(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      amount: json['amount'] as int? ?? 0,
      paidAmount: json['paid_amount'] as int? ?? 0,
      remaining: json['remaining'] as int? ?? 0,
      dueDate: json['due_date'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }
}

class RecentPayment {
  final int id;
  final String billTitle;
  final int amount;
  final String paymentMethod;
  final String paidAt;

  const RecentPayment({
    required this.id,
    required this.billTitle,
    required this.amount,
    required this.paymentMethod,
    required this.paidAt,
  });

  factory RecentPayment.fromJson(Map<String, dynamic> json) {
    return RecentPayment(
      id: json['id'] as int? ?? 0,
      billTitle: json['bill_title'] as String? ?? '',
      amount: json['amount'] as int? ?? 0,
      paymentMethod: json['payment_method'] as String? ?? '',
      paidAt: json['paid_at'] as String? ?? '',
    );
  }
}

class UpcomingExam {
  final int id;
  final String title;
  final String subject;
  final String teacherName;
  final String examDate;
  final int durationMinutes;
  final int questionsCount;
  final String pivotStatus;
  final String examUrl;

  const UpcomingExam({
    required this.id,
    required this.title,
    required this.subject,
    required this.teacherName,
    required this.examDate,
    required this.durationMinutes,
    required this.questionsCount,
    required this.pivotStatus,
    required this.examUrl,
  });

  factory UpcomingExam.fromJson(Map<String, dynamic> json) {
    return UpcomingExam(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      teacherName: json['teacher_name'] as String? ?? '',
      examDate: json['exam_date'] as String? ?? '',
      durationMinutes: json['duration_minutes'] as int? ?? 0,
      questionsCount: json['questions_count'] as int? ?? 0,
      pivotStatus: json['pivot_status'] as String? ?? '',
      examUrl: json['exam_url'] as String? ?? '',
    );
  }
}

class DashboardData {
  final StudentModel student;
  final DashboardStats stats;
  final List<RecentBill> recentBills;
  final List<RecentPayment> recentPayments;
  final List<UpcomingExam> upcomingExams;

  const DashboardData({
    required this.student,
    required this.stats,
    required this.recentBills,
    required this.recentPayments,
    required this.upcomingExams,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      student: StudentModel.fromJson(json['student'] as Map<String, dynamic>),
      stats: DashboardStats.fromJson(json['stats'] as Map<String, dynamic>),
      recentBills: (json['recent_bills'] as List<dynamic>?)
              ?.map((e) => RecentBill.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      recentPayments: (json['recent_payments'] as List<dynamic>?)
              ?.map((e) => RecentPayment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      upcomingExams: (json['upcoming_exams'] as List<dynamic>?)
              ?.map((e) => UpcomingExam.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class DashboardResponse {
  final bool success;
  final DashboardData data;

  const DashboardResponse({required this.success, required this.data});

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      success: json['success'] as bool? ?? false,
      data: DashboardData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}
