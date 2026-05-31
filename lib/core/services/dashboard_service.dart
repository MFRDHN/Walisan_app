import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';
import '../network/api_config.dart';
import '../models/dashboard_model.dart';

class DashboardService {
  final ApiClient _client;

  DashboardService({ApiClient? client}) : _client = client ?? ApiClient();

  static const _kCache = 'dashboard_cached_data';

  Future<DashboardData?> fetch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return null;

      final response = await _client.get(
        ApiConfig.dashboard,
        token: token,
      );

      final dashboard = DashboardResponse.fromJson(response);

      await _cacheLatestData(prefs, dashboard.data);

      return dashboard.data;
    } catch (_) {
      return _getCachedData();
    }
  }

  Future<DashboardData?> _getCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_kCache);
    if (cached == null) return null;
    try {
      final json = jsonDecode(cached) as Map<String, dynamic>;
      return DashboardData.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> _cacheLatestData(
      SharedPreferences prefs, DashboardData data) async {
    await prefs.setString(_kCache, jsonEncode({
      'student': {
        'name': data.student.name,
        'class': data.student.studentClass,
        'room': data.student.room,
        'barcode_id': data.student.barcodeId,
        'nis': data.student.nis,
        'nisn': data.student.nisn,
        'gender': data.student.gender,
        'father_name': data.student.fatherName,
        'mother_name': data.student.motherName,
        'father_phone': data.student.fatherPhone,
        'mother_phone': data.student.motherPhone,
        'address': data.student.address,
        'status': data.student.status,
        'enrollment_year': data.student.enrollmentYear,
        'photo_url': data.student.photoUrl,
      },
      'stats': {
        'pending_bills': data.stats.pendingBills,
        'total_paid': data.stats.totalPaid,
        'total_paid_formatted': data.stats.totalPaidFormatted,
        'saving_balance': data.stats.savingBalance,
        'saving_balance_formatted': data.stats.savingBalanceFormatted,
        'upcoming_exams': data.stats.upcomingExams,
      },
      'recent_bills':
          data.recentBills.map((b) => {
                'id': b.id,
                'title': b.title,
                'amount': b.amount,
                'paid_amount': b.paidAmount,
                'remaining': b.remaining,
                'due_date': b.dueDate,
                'status': b.status,
              }).toList(),
      'recent_payments':
          data.recentPayments.map((p) => {
                'id': p.id,
                'bill_title': p.billTitle,
                'amount': p.amount,
                'payment_method': p.paymentMethod,
                'paid_at': p.paidAt,
              }).toList(),
      'upcoming_exams':
          data.upcomingExams.map((e) => {
                'id': e.id,
                'title': e.title,
                'subject': e.subject,
                'teacher_name': e.teacherName,
                'exam_date': e.examDate,
                'duration_minutes': e.durationMinutes,
                'questions_count': e.questionsCount,
                'pivot_status': e.pivotStatus,
                'exam_url': e.examUrl,
              }).toList(),
    }));
  }

  void dispose() {
    _client.dispose();
  }
}
