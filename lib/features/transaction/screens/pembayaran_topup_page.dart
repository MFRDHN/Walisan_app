import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/savings_service.dart';
import '../../../core/widgets/midtrans_webview.dart';

class PembayaranTopUpPage extends StatefulWidget {
  final int nominal;
  final String metode;
  final String metodeLabel;
  final int currentBalance;
  final String studentName;

  const PembayaranTopUpPage({
    super.key,
    required this.nominal,
    required this.metode,
    required this.metodeLabel,
    required this.currentBalance,
    required this.studentName,
  });

  @override
  State<PembayaranTopUpPage> createState() => _PembayaranTopUpPageState();
}

class _PembayaranTopUpPageState extends State<PembayaranTopUpPage> {
  static const Color hijauUtama = Color(0xFF0EB89A);

  final _service = SavingsService();
  bool _isLoadingTopUp = false;
  bool _isCheckingStatus = false;
  bool _paymentDone = false;
  String _statusPembayaran = '';
  String _orderId = '';
  String _namaRekening = '';

  final formatRupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadNamaRekening();
  }

  Future<void> _loadNamaRekening() async {
    if (widget.studentName.isNotEmpty) {
      _namaRekening = widget.studentName;
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    _namaRekening = prefs.getString('student_name') ?? 'Santri';
    if (mounted) setState(() {});
  }

  int get _biayaAdmin => 2500;
  int get _totalBayar => widget.nominal + _biayaAdmin;
  int get _saldoSetelahTopUp => widget.currentBalance + widget.nominal;
  String get _namaMetode => widget.metodeLabel;

  IconData get _metodeIcon {
    switch (widget.metode) {
      case 'virtual_account':
        return Icons.account_balance_outlined;
      case 'ewallet':
        return Icons.account_balance_wallet_outlined;
      case 'mitra':
        return Icons.store_outlined;
      case 'kartu_debit':
        return Icons.credit_card_outlined;
      default:
        return Icons.qr_code_outlined;
    }
  }

  Future<void> _bukaPembayaran() async {
    if (_isLoadingTopUp) return;
    setState(() => _isLoadingTopUp = true);

    try {
      final result = await _service.topUp(
        amount: widget.nominal,
        paymentMethod: widget.metode,
      );

      if (!mounted) return;

      if (result == null) {
        _showSnack('Gagal membuat token pembayaran. Coba lagi.', isError: true);
        setState(() => _isLoadingTopUp = false);
        return;
      }

      final redirectUrl = result['redirect_url'] as String?;
      final orderId = result['order_id'] as String? ?? '';

      if (redirectUrl == null || redirectUrl.isEmpty) {
        _showSnack('URL pembayaran tidak tersedia', isError: true);
        setState(() => _isLoadingTopUp = false);
        return;
      }

      _orderId = orderId;
      setState(() => _isLoadingTopUp = false);

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MidtransWebView(
            redirectUrl: redirectUrl,
            orderId: orderId,
            onFinished: () async {
              await _cekStatusPembayaran();
            },
          ),
        ),
      );

      if (!_paymentDone) {
        await _cekStatusPembayaran();
      }

      if (_statusPembayaran == 'success' && mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingTopUp = false);
        _showSnack('Tidak dapat terhubung ke server.', isError: true);
      }
    }
  }

  Future<void> _cekStatusPembayaran() async {
    if (_orderId.isEmpty) return;

    setState(() => _isCheckingStatus = true);

    try {
      final result = await _service.checkStatus(_orderId);
      if (!mounted) return;

      final status = result?['status'] as String? ?? 'pending';
      setState(() {
        _statusPembayaran = status;
        _paymentDone =
            status == 'success' || status == 'failed' || status == 'expire';
        _isCheckingStatus = false;
      });

      if (status == 'failed' || status == 'expire') {
        _showSnack(
          status == 'expire'
              ? 'Waktu pembayaran habis. Silakan coba lagi.'
              : 'Pembayaran gagal. Silakan coba lagi.',
          isError: true,
        );
      }
    } catch (e) {
      setState(() => _isCheckingStatus = false);
      _showSnack('Gagal mengecek status. Coba lagi.', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : hijauUtama,
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pembayaran',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: const Color(0xFFEEEEEE), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: hijauUtama.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: widget.metode == 'qris'
                              ? const Center(
                                  child: Text(
                                    'QR',
                                    style: TextStyle(
                                      color: hijauUtama,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                )
                              : Icon(_metodeIcon,
                                  color: hijauUtama, size: 26),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _namaMetode,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Divider(color: Color(0xFFF0F0F0)),
                        const SizedBox(height: 14),
                        _detailRow(
                          'Jumlah top up',
                          formatRupiah.format(widget.nominal),
                        ),
                        const SizedBox(height: 10),
                        _detailRow(
                          'Biaya admin',
                          formatRupiah.format(_biayaAdmin),
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: Color(0xFFF0F0F0)),
                        const SizedBox(height: 12),
                        _detailRow(
                          'Total bayar',
                          formatRupiah.format(_totalBayar),
                          valueColor: hijauUtama,
                          isBold: true,
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Color(0xFFF0F0F0)),
                        const SizedBox(height: 14),
                        _detailRow('Ke rekening', _namaRekening),
                        const SizedBox(height: 10),
                        _detailRow(
                          'Saldo setelah top up',
                          formatRupiah.format(_saldoSetelahTopUp),
                          valueColor: hijauUtama,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3F3),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: const Color(0xFFFFD0D0)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE4E4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.red,
                              size: 16),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Pastikan nominal sudah benar sebelum melanjutkan. Transaksi tidak dapat dibatalkan.',
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed:
                    _isLoadingTopUp || _isCheckingStatus ? null : _bukaPembayaran,
                style: ElevatedButton.styleFrom(
                  backgroundColor: hijauUtama,
                  disabledBackgroundColor: hijauUtama.withValues(alpha: 0.4),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _isLoadingTopUp || _isCheckingStatus
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text(
                        'Lanjutkan Pembayaran',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isBold ? Colors.black87 : Colors.black54,
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.black87,
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

