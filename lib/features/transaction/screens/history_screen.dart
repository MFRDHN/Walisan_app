import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/history_bloc.dart';
import '../bloc/history_event.dart';
import '../bloc/history_state.dart';

class PaymentHistory {
  final int id;
  final int amount;
  final String paidAt;
  final String status;
  final String billTitle;
  final String paymentMethod;
  final String transactionId;

  const PaymentHistory({
    required this.id,
    required this.amount,
    required this.paidAt,
    required this.status,
    required this.billTitle,
    required this.paymentMethod,
    required this.transactionId,
  });

  factory PaymentHistory.fromJson(Map<String, dynamic> json) {
    return PaymentHistory(
      id: json['id'] as int? ?? 0,
      amount: json['amount'] as int? ?? 0,
      paidAt: json['paid_at'] as String? ?? '',
      status: json['status'] as String? ?? '',
      billTitle: json['bill_title'] as String? ?? '',
      paymentMethod: json['payment_method'] as String? ?? '',
      transactionId: json['transaction_id'] as String? ?? '',
    );
  }

  String get formattedAmount {
    final str = amount.toString();
    final buf = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buf.write('.');
      buf.write(str[i]);
      count++;
    }
    return 'Rp ${buf.toString().split('').reversed.join('')}';
  }

  String get formattedDate {
    try {
      final parts = paidAt.split(' ');
      final d = parts[0].split('-');
      if (d.length == 3) {
        return '${d[2]}-${d[1]}-${d[0]}${parts.length > 1 ? " ${parts[1]}" : ""}';
      }
      return paidAt;
    } catch (_) {
      return paidAt;
    }
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HistoryBloc()..add(HistoryFetch()),
      child: const _HistoryView(),
    );
  }
}

class _HistoryView extends StatefulWidget {
  const _HistoryView();

  @override
  State<_HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<_HistoryView> {
  List<PaymentHistory> _payments = [];
  int _totalAmount = 0;

  static const _gradient = LinearGradient(
    colors: [Color(0xFF067A88), Color(0xFF0EA473)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HistoryBloc, HistoryState>(
      listener: (context, state) {
        if (state is HistoryLoaded) {
          setState(() {
            _payments = state.payments
                .map((e) =>
                    PaymentHistory.fromJson(e as Map<String, dynamic>))
                .toList();
            _totalAmount = state.totalAmount;
          });
        } else if (state is HistoryFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is HistoryLoading && _payments.isEmpty;
        final error =
            state is HistoryFailure && _payments.isEmpty ? state.error : null;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: isLoading
                      ? _buildLoading()
                      : error != null
                          ? _buildError(error)
                          : _payments.isEmpty
                              ? _buildEmpty()
                              : RefreshIndicator(
                                  color: const Color(0xFF0EA473),
                                  onRefresh: () async {
                                    context
                                        .read<HistoryBloc>()
                                        .add(HistoryFetch());
                                  },
                                  child: ListView(
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 16, 16, 24),
                                    children: [
                                      _buildTotalCard(),
                                      const SizedBox(height: 20),
                                      _buildSectionLabel(),
                                      const SizedBox(height: 12),
                                      ..._payments.map(_buildPaymentCard),
                                    ],
                                  ),
                                ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF0EA473)),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_outlined,
              size: 48, color: Color(0xFF9CA3AF)),
          const SizedBox(height: 12),
          Text(error, style: const TextStyle(color: Color(0xFF6B7280))),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => context.read<HistoryBloc>().add(HistoryFetch()),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                gradient: _gradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('Coba Lagi',
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back,
                color: Color(0xFF1F2937), size: 22),
          ),
          const SizedBox(width: 12),
          const Text('Histori',
              style: TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  String get _totalFormatted {
    final str = _totalAmount.toString();
    final buf = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buf.write('.');
      buf.write(str[i]);
      count++;
    }
    return 'Rp ${buf.toString().split('').reversed.join('')}';
  }

  Widget _buildTotalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        gradient: _gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF067A88).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('TOTAL PEMBAYARAN',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(_totalFormatted,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check,
                      color: Colors.white, size: 12),
                ),
                const SizedBox(width: 8),
                const Text('Semua transaksi lunas',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel() {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Text('Riwayat Transaksi',
          style: TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 15,
              fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildPaymentCard(PaymentHistory payment) {
    final isSuccess = payment.status == 'success';
    final isPending = payment.status == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          childrenPadding: EdgeInsets.zero,
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isSuccess
                  ? const Color(0xFFDCFCE7)
                  : isPending
                      ? const Color(0xFFFEF9C3)
                      : const Color(0xFFFFE4E6),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSuccess
                  ? Icons.check_circle_outline
                  : isPending
                      ? Icons.hourglass_empty_outlined
                      : Icons.cancel_outlined,
              color: isSuccess
                  ? const Color(0xFF16A34A)
                  : isPending
                      ? const Color(0xFFD97706)
                      : const Color(0xFFDC2626),
              size: 20,
            ),
          ),
          title: Text(payment.formattedAmount,
              style: const TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(payment.formattedDate,
                style: const TextStyle(
                    color: Color(0xFF9CA3AF), fontSize: 11)),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isSuccess
                      ? const Color(0xFFDCFCE7)
                      : isPending
                          ? const Color(0xFFFEF9C3)
                          : const Color(0xFFFFE4E6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isSuccess
                      ? 'Lunas'
                      : isPending
                          ? 'Pending'
                          : 'Gagal',
                  style: TextStyle(
                    color: isSuccess
                        ? const Color(0xFF16A34A)
                        : isPending
                            ? const Color(0xFFD97706)
                            : const Color(0xFFDC2626),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 2),
            ],
          ),
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  _detailRow('Nama Tagihan', payment.billTitle),
                  const SizedBox(height: 8),
                  _detailRow('Metode Bayar', payment.paymentMethod),
                  const SizedBox(height: 8),
                  _detailRow('ID Transaksi', payment.transactionId,
                      small: true),
                  const SizedBox(height: 8),
                  _detailRow('Waktu Bayar', payment.formattedDate),
                  const SizedBox(height: 8),
                  _detailRow(
                    'Status',
                    isSuccess
                        ? 'Lunas'
                        : isPending
                            ? 'Pending'
                            : 'Gagal',
                    valueColor: isSuccess
                        ? const Color(0xFF16A34A)
                        : isPending
                            ? const Color(0xFFD97706)
                            : const Color(0xFFDC2626),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value,
      {bool small = false, Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(label,
              style: const TextStyle(
                  color: Color(0xFF6B7280), fontSize: 12)),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: valueColor ?? const Color(0xFF1F2937),
              fontSize: small ? 11 : 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.receipt_long_outlined,
              size: 56, color: Color(0xFFD1D5DB)),
          SizedBox(height: 12),
          Text('Belum ada riwayat pembayaran',
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14)),
        ],
      ),
    );
  }
}
