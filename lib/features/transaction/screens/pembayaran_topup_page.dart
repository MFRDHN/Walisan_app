import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/services/savings_service.dart';
import '../../../core/widgets/midtrans_webview.dart';

class PembayaranTopUpPage extends StatefulWidget {
  final Map<String, dynamic> snapData;
  final int nominal;
  final String metode;
  final String metodeLabel;
  final int currentBalance;

  const PembayaranTopUpPage({
    super.key,
    required this.snapData,
    required this.nominal,
    required this.metode,
    required this.metodeLabel,
    required this.currentBalance,
  });

  @override
  State<PembayaranTopUpPage> createState() => _PembayaranTopUpPageState();
}

class _PembayaranTopUpPageState extends State<PembayaranTopUpPage> {
  static const Color hijauUtama = Color(0xFF0EB89A);

  final _service = SavingsService();
  bool _isCheckingStatus = false;
  bool _paymentDone = false;

  final formatRupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

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
    final redirectUrl = widget.snapData['redirect_url'] as String?;
    if (redirectUrl == null || redirectUrl.isEmpty) {
      _showSnack('URL pembayaran tidak tersedia', isError: true);
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MidtransWebView(
          redirectUrl: redirectUrl,
          orderId: widget.snapData['order_id'] as String? ?? '',
          onFinished: () async {
            await _cekStatusPembayaran();
          },
        ),
      ),
    );

    if (!_paymentDone) {
      await _cekStatusPembayaran();
    }
  }

  Future<void> _cekStatusPembayaran() async {
    final orderId = widget.snapData['order_id'] as String?;
    if (orderId == null) return;

    setState(() => _isCheckingStatus = true);

    try {
      final result = await _service.checkStatus(orderId);
      if (!mounted) return;

      final status = result?['status'] as String? ?? 'pending';
      setState(() {
        _paymentDone =
            status == 'success' || status == 'failed' || status == 'expire';
        _isCheckingStatus = false;
      });

      if (status == 'success') {
        _showSuccessDialog();
      } else if (status == 'failed' || status == 'expire') {
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: hijauUtama,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 38),
              ),
              const SizedBox(height: 18),
              const Text(
                'Top Up Berhasil!',
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Saldo tabungan berhasil ditambahkan sebesar ${formatRupiah.format(widget.nominal)}.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.black54, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: hijauUtama.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Saldo Sekarang',
                      style: TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatRupiah.format(_saldoSetelahTopUp),
                      style: const TextStyle(
                        color: hijauUtama,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hijauUtama,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Selesai',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
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
                        _detailRow('Ke rekening', 'Ayna Mardea'),
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
                onPressed: _isCheckingStatus ? null : _bukaPembayaran,
                style: ElevatedButton.styleFrom(
                  backgroundColor: hijauUtama,
                  disabledBackgroundColor: hijauUtama.withValues(alpha: 0.4),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _isCheckingStatus
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

