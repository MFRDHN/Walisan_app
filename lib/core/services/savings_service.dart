import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../network/api_client.dart';
import '../network/api_config.dart';
import '../models/savings_model.dart';

class SavingsService {
  final ApiClient _client;

  SavingsService({ApiClient? client}) : _client = client ?? ApiClient();

  /// Local‑only deduction keys (SharedPreferences)
  static const _kCache = 'savings_cached_data';
  static const _kLocalLimit = 'savings_local_limit';
  static const _kLastDeduction = 'savings_last_deduction';
  static const _kDeductions = 'savings_deductions';

  Future<SavingsData?> fetch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return null;

      final response = await _client.get(
        ApiConfig.savings,
        token: token,
      );

      final result = SavingsResponse.fromJson(response);
      SavingsData? data = result.data;

      if (data != null) {
        await _cacheLatestData(prefs, data);
        data = await _applyDailyDeductions(prefs, data);
      }
      return data;
    } catch (_) {
      return _getCachedData();
    }
  }

  // ── Local cache helpers ────────────────────────────────────────────

  Future<SavingsData?> _getCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_kCache);
    if (cached == null) return null;
    try {
      final json = jsonDecode(cached) as Map<String, dynamic>;
      final data = SavingsData.fromJson(json);
      return await _applyDailyDeductions(prefs, data);
    } catch (_) {
      return null;
    }
  }

  Future<void> _cacheLatestData(
      SharedPreferences prefs, SavingsData data) async {
    await prefs.setString(_kCache, jsonEncode({
      'balance': data.balance,
      'balance_formatted': data.balanceFormatted,
      'student_name': data.studentName,
      'daily_limit': data.dailyLimit,
      'pocket_money': data.pocketMoney,
      'total_income': data.totalIncome,
      'total_expense': data.totalExpense,
      'history': data.history
          .map((h) => {
                'id': h.id,
                'type': h.type,
                'description': h.description,
                'amount': h.amount,
                'date': h.date,
                'balance_after': h.balanceAfter,
                'is_debit': h.isDebit,
              })
          .toList(),
    }));
  }

  // ── Daily deduction logic ─────────────────────────────────────────

  Future<SavingsData> _applyDailyDeductions(
      SharedPreferences prefs, SavingsData data) async {
    final localLimit = prefs.getInt(_kLocalLimit);
    final int limit = localLimit ?? data.dailyLimit;
    if (limit <= 0) return data;

    final now = DateTime.now();
    final todayKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final lastKey = prefs.getString(_kLastDeduction) ?? '';
    final deductionsJson = prefs.getString(_kDeductions);

    final List<Map<String, dynamic>> deductions;
    if (deductionsJson != null) {
      deductions = (jsonDecode(deductionsJson) as List<dynamic>)
          .cast<Map<String, dynamic>>();
    } else {
      deductions = [];
    }

    if (lastKey == todayKey) {
      return _mergeDeductions(data, deductions, effectiveLimit: limit);
    }

    int totalDeducted = 0;
    for (final d in deductions) {
      totalDeducted += (d['amount'] as int);
    }

    DateTime cursor;
    if (lastKey.isEmpty) {
      cursor = now;
    } else {
      final last = DateTime.tryParse(lastKey);
      cursor = last != null
          ? DateTime(last.year, last.month, last.day)
              .add(const Duration(days: 1))
          : now;
    }

    final todayStart = DateTime(now.year, now.month, now.day);
    int newTotal = 0;

    while (!cursor.isAfter(todayStart)) {
      final used = totalDeducted + newTotal;
      final remaining = data.balance - used;
      final int toDeduct = limit < remaining
          ? limit
          : (remaining > 0 ? remaining : 0);
      if (toDeduct <= 0) break;

      final dateLabel =
          '${cursor.year}-${cursor.month.toString().padLeft(2, '0')}-${cursor.day.toString().padLeft(2, '0')}';
      deductions.add({
        'amount': toDeduct,
        'date': cursor.toIso8601String(),
        'description': 'Limit jajan $dateLabel',
      });
      newTotal += toDeduct;
      cursor = cursor.add(const Duration(days: 1));
    }

    if (newTotal > 0) {
      await prefs.setString(_kLastDeduction, todayKey);
      await prefs.setString(_kDeductions, jsonEncode(deductions));
    }

    return _mergeDeductions(data, deductions, effectiveLimit: limit);
  }

  SavingsData _mergeDeductions(
    SavingsData data,
    List<Map<String, dynamic>> deductions, {
    int? effectiveLimit,
  }) {
    if (deductions.isEmpty) return data;

    int runningBalance = data.balance;
    final List<SavingsTransaction> trxList = [];
    for (int i = 0; i < deductions.length; i++) {
      final d = deductions[i];
      final amount = d['amount'] as int;
      runningBalance -= amount;
      trxList.add(SavingsTransaction(
        id: -(i + 1),
        type: 'daily_limit',
        description: d['description'] as String,
        amount: amount,
        date: d['date'] as String,
        balanceAfter: runningBalance,
        isDebit: true,
      ));
    }

    final now = DateTime.now();
    int thisMonthTotal = 0;
    for (final d in deductions) {
      final dt = DateTime.tryParse(d['date'] as String? ?? '');
      if (dt != null && dt.month == now.month && dt.year == now.year) {
        thisMonthTotal += (d['amount'] as int);
      }
    }

    final fmt =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return SavingsData(
      balance: runningBalance,
      balanceFormatted: fmt.format(runningBalance),
      studentName: data.studentName,
      dailyLimit: effectiveLimit ?? data.dailyLimit,
      pocketMoney: data.pocketMoney,
      totalIncome: data.totalIncome,
      totalExpense: data.totalExpense + thisMonthTotal,
      history: [...trxList, ...data.history],
    );
  }

  /// Top up saldo — mengembalikan { snap_token, redirect_url, order_id, transaction }
  Future<Map<String, dynamic>?> topUp({
    required int amount,
    String? paymentMethod,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return null;

      final body = <String, dynamic>{'amount': amount};
      if (paymentMethod != null) {
        body['payment_method'] = paymentMethod;
      }

      final response = await _client.post(
        ApiConfig.savingsTopup,
        body: body,
        token: token,
      );

      if (response['success'] == true) {
        return response['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<List<SavingsTransaction>> fetchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return [];

      final response = await _client.get(
        ApiConfig.savingsHistory,
        token: token,
      );

      final list = response['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => SavingsTransaction.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> updateLimit(int dailyLimit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return false;

      final response = await _client.post(
        ApiConfig.savingsLimitUpdate,
        body: {'daily_limit': dailyLimit},
        token: token,
      );

      if (response['success'] == true) {
        await prefs.remove(_kLocalLimit);
        return true;
      }

      await prefs.setInt(_kLocalLimit, dailyLimit);
      return true;
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kLocalLimit, dailyLimit);
      return true;
    }
  }

  /// Cek status pembayaran setelah user selesai di Midtrans
  Future<Map<String, dynamic>?> checkStatus(String orderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return null;

      final response = await _client.post(
        ApiConfig.savingsCheckStatus,
        body: {'order_id': orderId},
        token: token,
      );

      if (response['success'] == true) {
        return response['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    _client.dispose();
  }
}
