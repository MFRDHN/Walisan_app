import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../core/widgets/midtrans_webview.dart';
import '../bloc/bill_bloc.dart';
import '../bloc/bill_event.dart';
import '../bloc/bill_state.dart';

class BillItem {
  final int id;
  final String studentName;
  final int amount;
  final String dueDate;
  final String createdDate;
  final String status;
  final String virtualAccount;
  final String bankName;
  final String description;

  const BillItem({
    required this.id,
    required this.studentName,
    required this.amount,
    required this.dueDate,
    required this.createdDate,
    required this.status,
    required this.virtualAccount,
    required this.bankName,
    required this.description,
  });

  factory BillItem.fromJson(Map<String, dynamic> json,
      {String defaultVa = '', String defaultBank = 'BCA'}) {
    final apiStatus = json['status'] as String? ?? '';
    final status = switch (apiStatus) {
      'paid' => 'paid',
      'pending' => 'unpaid',
      _ => apiStatus,
    };
    return BillItem(
      id: json['id'] as int? ?? 0,
      studentName: json['title'] as String? ?? '',
      amount: json['amount'] as int? ?? 0,
      dueDate: json['due_date'] as String? ?? '',
      createdDate:
          json['created_at'] as String? ?? json['due_date'] as String? ?? '',
      status: status,
      virtualAccount: json['virtual_account'] as String? ?? defaultVa,
      bankName: json['bank_name'] as String? ?? defaultBank,
      description: json['description'] as String? ?? '',
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
}

class BillScreen extends StatelessWidget {
  final String? loginData;

  const BillScreen({super.key, this.loginData});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BillBloc()..add(const BillFetch()),
      child: _BillView(loginData: loginData),
    );
  }
}

class _BillView extends StatefulWidget {
  final String? loginData;

  const _BillView({this.loginData});

  @override
  State<_BillView> createState() => _BillViewState();
}

class _BillViewState extends State<_BillView> {
  List<BillItem> _bills = [];
  String _studentName = 'Ayna Mardea';
  String _studentVa = '8801 0293 8812 004';
  String _studentBank = 'BCA';

  static const _orangeGradient = LinearGradient(
    colors: [Color(0xFFF87019), Color(0xFFF0493E)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const _greenGradient = LinearGradient(
    colors: [Color(0xFF067A88), Color(0xFF0EA473)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  @override
  void initState() {
    super.initState();
    if (widget.loginData != null) {
      try {
        final data = jsonDecode(widget.loginData!) as Map<String, dynamic>;
        final student = data['student'] as Map<String, dynamic>?;
        if (student != null) {
          _studentName = student['name'] as String? ?? _studentName;
          _studentVa = student['nis'] as String? ?? _studentVa;
        }
      } catch (_) {}
    }
  }

  int get _totalTagihan =>
      _bills.where((b) => b.status == 'unpaid' || b.status == 'overdue')
          .fold(0, (sum, b) => sum + b.amount);

  String get _totalFormatted {
    final str = _totalTagihan.toString();
    final buf = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buf.write('.');
      buf.write(str[i]);
      count++;
    }
    return 'Rp ${buf.toString().split('').reversed.join('')}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BillBloc, BillState>(
      listener: (context, state) {
        if (state is BillLoaded) {
          setState(() {
            _bills = state.bills
                .map((e) => BillItem.fromJson(
                      e as Map<String, dynamic>,
                      defaultVa: _studentVa,
                      defaultBank: _studentBank,
                    ))
                .toList();
          });
        } else if (state is BillPayReady) {
          _openMidtrans(state.redirectUrl, state.orderId);
        } else if (state is BillPaySuccess) {
          context.read<BillBloc>().add(const BillFetch());
        } else if (state is BillFailure) {
          _showErrorSnackBar(state.error);
        }
      },
      builder: (context, state) {
        final isLoading = state is BillLoading;
        final error = state is BillFailure ? state.error : null;

        return Scaffold(
          backgroundColor: const Color(0xFFF3F4F6),
          body: SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: isLoading
                      ? _buildLoading()
                      : error != null
                          ? _buildError(error)
                          : RefreshIndicator(
                              color: const Color(0xFF0EA473),
                              onRefresh: () async {
                                context
                                    .read<BillBloc>()
                                    .add(const BillFetch());
                              },
                              child: ListView(
                                padding: const EdgeInsets.fromLTRB(
                                    16, 16, 16, 24),
                                children: [
                                  _buildSummaryCard(),
                                  const SizedBox(height: 20),
                                  const Text('Tagihan Aktif',
                                      style: TextStyle(
                                          color: Color(0xFF1F2937),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 12),
                                  ..._bills.map(_buildBillCard),
                                  const SizedBox(height: 16),
                                  _buildHistoryLink(),
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
            onTap: () => context.read<BillBloc>().add(const BillFetch()),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                gradient: _greenGradient,
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
          const Text('Tagihan',
              style: TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/history'),
            child: const Text('Riwayat',
                style: TextStyle(
                    color: Color(0xFF0EA473),
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final bill = _bills.isNotEmpty ? _bills.first : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        gradient: _orangeGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF87019).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('TOTAL TAGIHAN',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text(_totalFormatted,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('JATUH TEMPO',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 9,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      Text(bill?.dueDate ?? '-',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('PEMBAYARAN VIA',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 9,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: bill?.bankName ?? _studentBank,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                            const TextSpan(
                              text: ' [VA]',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 0.5, color: Colors.white24),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('NOMOR VIRTUAL ACCOUNT',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 9,
                            letterSpacing: 1)),
                    const SizedBox(height: 5),
                    Text(bill?.virtualAccount ?? _studentVa,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(
                      ClipboardData(text: bill?.virtualAccount ?? _studentVa));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nomor VA disalin'),
                      backgroundColor: Color(0xFF0EA473),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35)),
                  ),
                  child: const Icon(Icons.copy_outlined,
                      color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillCard(BillItem bill) {
    final isPaid = bill.status == 'paid';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isPaid
            ? Border.all(color: const Color(0xFF0EA473).withValues(alpha: 0.4))
            : Border.all(
                color: const Color(0xFFF0493E).withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isPaid
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFE4E8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isPaid
                        ? Icons.check_circle_outline
                        : Icons.person_outline,
                    color: isPaid
                        ? const Color(0xFF0EA473)
                        : const Color(0xFFF0493E),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(bill.studentName,
                          style: const TextStyle(
                              color: Color(0xFF1F2937),
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(bill.createdDate,
                          style: const TextStyle(
                              color: Color(0xFF9CA3AF), fontSize: 11)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isPaid
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFE4E8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isPaid ? 'Sudah Dibayar' : 'Belum Dibayar',
                    style: TextStyle(
                      color: isPaid
                          ? const Color(0xFF0EA473)
                          : const Color(0xFFF0493E),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (!isPaid) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3F3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFD0D0)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline,
                        size: 14, color: Color(0xFFF0493E)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Belum Dibayar',
                              style: TextStyle(
                                  color: Color(0xFFDC2626),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(
                            bill.description.isNotEmpty
                                ? bill.description
                                : 'Harap lakukan pembayaran ke Virtual Account yang tertera.',
                            style: const TextStyle(
                                color: Color(0xFFDC2626),
                                fontSize: 11,
                                height: 1.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (isPaid) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFF0EA473).withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle,
                        size: 14, color: Color(0xFF0EA473)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Pembayaran Lunas',
                              style: TextStyle(
                                  color: Color(0xFF067A88),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                          SizedBox(height: 4),
                          Text('Tagihan ini sudah dibayar lunas.',
                              style: TextStyle(
                                  color: Color(0xFF0EA473),
                                  fontSize: 11,
                                  height: 1.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: GestureDetector(
              onTap: isPaid
                  ? () => _cetakPdf(bill)
                  : () => _bayarViaMidtrans(bill),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  gradient: isPaid ? _greenGradient : _orangeGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: (isPaid
                              ? const Color(0xFF0EA473)
                              : const Color(0xFFF87019))
                          .withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isPaid
                          ? Icons.picture_as_pdf_outlined
                          : Icons.payment_outlined,
                      color: Colors.white,
                      size: 17,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isPaid ? 'Cetak Bukti PDF' : 'Bayar Tagihan',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryLink() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/history'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 18, color: Color(0xFF6B7280)),
            SizedBox(width: 8),
            Text('Lihat Riwayat Pembayaran',
                style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Future<void> _cetakPdf(BillItem bill) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text('BUKTI PEMBAYARAN',
                  style: pw.TextStyle(
                      fontSize: 22, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 8),
            pw.Center(
              child: pw.Text('Walisan App',
                  style: pw.TextStyle(fontSize: 13, color: PdfColors.grey)),
            ),
            pw.SizedBox(height: 24),
            pw.Divider(),
            pw.SizedBox(height: 16),
            _pdfRow('Nama Santri', bill.studentName),
            _pdfRow('Tagihan', bill.description),
            _pdfRow('Jumlah', bill.formattedAmount),
            _pdfRow('Status', 'LUNAS'),
            _pdfRow('Virtual Account', bill.virtualAccount),
            _pdfRow('Bank', bill.bankName),
            _pdfRow('Jatuh Tempo', bill.dueDate),
            pw.SizedBox(height: 24),
            pw.Divider(),
            pw.SizedBox(height: 16),
            pw.Center(
              child: pw.Text('Terima kasih',
                  style: pw.TextStyle(fontSize: 11, color: PdfColors.grey)),
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) => pdf.save(),
      name: 'bukti_pembayaran_${bill.id}.pdf',
    );
  }

  pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(value),
        ],
      ),
    );
  }

  Future<void> _bayarViaMidtrans(BillItem bill) async {
    context.read<BillBloc>().add(BillPay(billId: bill.id, amount: bill.amount));
  }

  Future<void> _openMidtrans(String redirectUrl, String orderId) async {
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MidtransWebView(
          redirectUrl: redirectUrl,
          orderId: orderId,
          onFinished: () {},
        ),
      ),
    );
    if (!mounted) return;
    context.read<BillBloc>().add(BillCheckStatus(orderId: orderId));
    context.read<BillBloc>().add(const BillFetch());
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFDC2626),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
