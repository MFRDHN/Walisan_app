import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/verify_otp_bloc.dart';
import '../bloc/verify_otp_event.dart';
import '../bloc/verify_otp_state.dart';

class VerifyOtpScreen extends StatelessWidget {
  final int userId;
  final String phone;

  const VerifyOtpScreen({
    super.key,
    required this.userId,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VerifyOtpBloc(),
      child: VerifyOtpView(userId: userId, phone: phone),
    );
  }
}

class VerifyOtpView extends StatefulWidget {
  final int userId;
  final String phone;

  const VerifyOtpView({
    super.key,
    required this.userId,
    required this.phone,
  });

  @override
  State<VerifyOtpView> createState() => _VerifyOtpViewState();
}

class _VerifyOtpViewState extends State<VerifyOtpView> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  int _resendCountdown = 10;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _resendCountdown = 10;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCountdown == 0) {
        t.cancel();
      } else {
        setState(() => _resendCountdown--);
      }
    });
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  String get _otp => _controllers.map((c) => c.text).join();

  void _onKonfirmasi() {
    final otp = _otp;
    if (otp.length != 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Masukkan kode 6 digit')));
      return;
    }
    context.read<VerifyOtpBloc>().add(
      VerifyOtpSubmitted(
        userId: widget.userId,
        otpCode: otp,
      ),
    );
  }

  void _onResend() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
    _startCountdown();
    context.read<VerifyOtpBloc>().add(
      ResendOtpRequested(userId: widget.userId),
    );
  }

  Future<void> _onVerifyOtpSuccess(
    BuildContext context,
    VerifyOtpSuccess state,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', state.loginResponse.token);
    final studentName = state.loginResponse.student?.name ?? state.loginResponse.user.name;
    if (studentName.isNotEmpty) {
      await prefs.setString('student_name', studentName);
    }
    final loginData = jsonEncode({
      'user': state.loginResponse.user.toJson(),
      'student': state.loginResponse.student?.toJson(),
      'token': state.loginResponse.token,
    });
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false,
      arguments: loginData,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D9488), Color(0xFF042F2E)],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Opacity(
              opacity: 0.5,
              child: Image.asset(
                'assets/images/kaligrafi.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
            SafeArea(
              child: BlocConsumer<VerifyOtpBloc, VerifyOtpState>(
                listener: (context, state) {
                  if (state is VerifyOtpFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.error),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else if (state is ResendOtpSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  } else if (state is VerifyOtpSuccess) {
                    _onVerifyOtpSuccess(context, state);
                  }
                },
                builder: (context, state) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 100),
                        Stack(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: const Padding(
                                  padding: EdgeInsets.only(top: 4.0),
                                  child: Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: const [
                                  Text(
                                    'Verifikasi Akun',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'masukkan kode verifikasi',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 48),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    Colors.black.withValues(alpha: 0.08),
                                blurRadius: 25,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Kami sudah mengirimkan kode ke nomor ${widget.phone}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(height: 32),
                              Row(
                                children: List.generate(6, (index) {
                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      child: SizedBox(
                                        height: 60,
                                        child: TextFormField(
                                          controller:
                                              _controllers[index],
                                          focusNode: _focusNodes[index],
                                          onChanged: (v) =>
                                              _onChanged(index, v),
                                          textAlign: TextAlign.center,
                                          keyboardType:
                                              TextInputType.number,
                                          maxLength: 1,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF111827),
                                          ),
                                          decoration: InputDecoration(
                                            counterText: '',
                                            filled: true,
                                            fillColor:
                                                const Color(0xFFF3F4F6),
                                            contentPadding:
                                                EdgeInsets.zero,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      12),
                                              borderSide: BorderSide.none,
                                            ),
                                            enabledBorder:
                                                OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      12),
                                              borderSide: BorderSide.none,
                                            ),
                                            focusedBorder:
                                                OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      12),
                                              borderSide:
                                                  const BorderSide(
                                                color: Color(0xFF0D9488),
                                                width: 1.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 32),
                              Container(
                                width: double.infinity,
                                height: 52,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF0D9488),
                                      Color(0xFF14B8A6),
                                    ],
                                  ),
                                ),
                                child: ElevatedButton(
                                  onPressed:
                                      state is VerifyOtpLoading
                                          ? null
                                          : _onKonfirmasi,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: state is VerifyOtpLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child:
                                              CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : const Text(
                                          'Konfirmasi Kode',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              _resendCountdown > 0
                                  ? Text(
                                      'Kirim ulang kode? $_resendCountdown',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF6B7280),
                                      ),
                                    )
                                  : GestureDetector(
                                      onTap: _onResend,
                                      child: const Text(
                                        'Kirim ulang kode?',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF0D9488),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          '\u00a9 2026 UG Smart System - V2.0',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
