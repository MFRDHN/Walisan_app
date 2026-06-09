import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_config.dart';

// ─────────────────────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────────────────────
class SubjectGrade {
  final int id;
  final String subjectName;
  final int kkm;
  final double grade;
  final String letterGrade;

  const SubjectGrade({
    required this.id,
    required this.subjectName,
    required this.kkm,
    required this.grade,
    required this.letterGrade,
  });

  static num? _parseNum(dynamic v) {
    if (v is num) return v;
    if (v is String) return num.tryParse(v);
    return null;
  }

  static int? _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  factory SubjectGrade.fromJson(Map<String, dynamic> json) {
    final score = (_parseNum(json['grade']) ??
            _parseNum(json['score']) ??
            _parseNum(json['nilai']) ??
            0)
        .toDouble();
    return SubjectGrade(
      id: json['id'] as int? ?? 0,
      subjectName: json['subject_name'] as String? ??
          json['subject'] as String? ??
          json['name'] as String? ??
          json['mata_pelajaran'] as String? ??
          '',
      kkm: _parseInt(json['kkm']) ?? 75,
      grade: score,
      letterGrade: json['letter_grade'] as String? ??
          json['huruf'] as String? ??
          _calcLetterGrade(score),
    );
  }

  static String _calcLetterGrade(double grade) {
    if (grade >= 90) return 'A';
    if (grade >= 80) return 'B';
    if (grade >= 70) return 'C';
    return 'D';
  }

  Color get gradeColor {
    switch (letterGrade) {
      case 'A':
        return const Color(0xFF16A34A);
      case 'B':
        return const Color(0xFF2563EB);
      case 'C':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFFDC2626);
    }
  }

  Color get gradeBgColor {
    switch (letterGrade) {
      case 'A':
        return const Color(0xFFDCFCE7);
      case 'B':
        return const Color(0xFFDBEAFE);
      case 'C':
        return const Color(0xFFFEF9C3);
      default:
        return const Color(0xFFFFE4E6);
    }
  }

  double get progress => (grade / 100).clamp(0.0, 1.0);
}

class ReportCard {
  final String semester;
  final String academicYear;
  final String className;
  final double average;
  final int rank;
  final int totalSubjects;
  final List<SubjectGrade> subjects;
  final String? achievement;

  const ReportCard({
    required this.semester,
    required this.academicYear,
    required this.className,
    required this.average,
    required this.rank,
    required this.totalSubjects,
    required this.subjects,
    this.achievement,
  });

  factory ReportCard.fromJson(Map<String, dynamic> json) {
    final gradesRaw = json['grades'];
    final subjectsList =
        json['subjects'] as List<dynamic>?;
    final semester = json['semester'] as String? ??
        json['semester'] as String? ??
        'Ganjil';
    final academicYear =
        json['academic_year'] as String? ??
            json['tahun_ajaran'] as String? ??
            '';
    final className = json['class_name'] as String? ??
        json['kelas'] as String? ??
        '';
    final avg =
        (SubjectGrade._parseNum(json['average_score']) ??
            SubjectGrade._parseNum(json['rata_rata']) ??
            SubjectGrade._parseNum(json['average']) ??
            0)
        .toDouble();
    final rnk = SubjectGrade._parseInt(json['rank']) ??
        SubjectGrade._parseInt(json['peringkat']) ??
        0;

    List<SubjectGrade> subjects;

    if (subjectsList != null) {
      subjects = subjectsList
          .map((e) =>
              SubjectGrade.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (gradesRaw is List) {
      subjects = gradesRaw
          .map((e) =>
              SubjectGrade.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (gradesRaw is Map<String, dynamic>) {
      subjects = gradesRaw.entries.map((e) {
        final nilai = (SubjectGrade._parseNum(e.value) ?? 0).toDouble();
        return SubjectGrade(
          id: 0,
          subjectName: e.key,
          kkm: 75,
          grade: nilai,
          letterGrade: SubjectGrade._calcLetterGrade(nilai),
        );
      }).toList();
    } else {
      subjects = [];
    }

    return ReportCard(
      semester: semester,
      academicYear: academicYear,
      className: className,
      average: avg,
      rank: rnk,
      totalSubjects: subjects.length,
      subjects: subjects,
      achievement:
          rnk > 0 ? 'Peringkat $rnk di kelas $className' : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Halaman Rapot Online
// ─────────────────────────────────────────────────────────────
class RapotOnlineScreen extends StatefulWidget {
  final ReportCard? reportCard;

  const RapotOnlineScreen({super.key, this.reportCard});

  @override
  State<RapotOnlineScreen> createState() => _RapotOnlineScreenState();
}

class _RapotOnlineScreenState extends State<RapotOnlineScreen> {
  late ReportCard _report;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isFromCache = false;

  static const _cardGradient = LinearGradient(
    colors: [Color(0xFFE8215A), Color(0xFFFF6B9D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const _greenGradient = LinearGradient(
    colors: [Color(0xFF067A88), Color(0xFF0EA473)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  @override
  void initState() {
    super.initState();
    if (widget.reportCard != null) {
      _report = widget.reportCard!;
      _isLoading = false;
    } else {
      _isLoading = true;
      _fetchReport();
    }
  }

  Future<void> _fetchReport() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      setState(() {
        _errorMessage = 'Token tidak ditemukan. Silakan login ulang.';
        _isLoading = false;
      });
      return;
    }

    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'User-Agent':
          'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36',
    };

    try {
      await _fetchFromApi(prefs, token, headers);
    } catch (e) {
      if (_loadCachedReport(prefs)) return;
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat raport. ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchFromApi(
    SharedPreferences prefs,
    String token,
    Map<String, String> headers,
  ) async {
    if (!mounted) return;
    http.Response response;
    try {
      response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.reports}'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 20));
    } on http.ClientException catch (e) {
      if (_loadCachedReport(prefs)) return;
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal terhubung ke server. ${e.message}';
        _isLoading = false;
      });
      return;
    } on TimeoutException {
      if (_loadCachedReport(prefs)) return;
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Server tidak merespon. Coba lagi nanti.';
        _isLoading = false;
      });
      return;
    }

    if (!mounted) return;
    final body = response.body;
    final isHtml = body.trimLeft().startsWith('<');

    if (response.statusCode == 200) {
      if (isHtml) {
        if (_loadCachedReport(prefs)) return;
        if (!mounted) return;
        setState(() {
          _errorMessage =
              'Server mengembalikan halaman HTML. Endpoint raport mungkin belum tersedia.';
          _isLoading = false;
        });
        return;
      }

      dynamic decoded;
      try {
        decoded = jsonDecode(body);
      } catch (_) {
        if (_loadCachedReport(prefs)) return;
        if (!mounted) return;
        setState(() {
          _errorMessage = 'Response tidak valid dari server.';
          _isLoading = false;
        });
        return;
      }

      if (decoded is! Map<String, dynamic>) {
        if (_loadCachedReport(prefs)) return;
        if (!mounted) return;
        setState(() {
          _errorMessage = 'Format data raport tidak valid.';
          _isLoading = false;
        });
        return;
      }

      final data = decoded['data'];

      if (data is List<dynamic> && data.isNotEmpty) {
        final firstReport = data[0] as Map<String, dynamic>;
        final reportId = firstReport['id'];
        if (reportId != null) {
          final detail = await _fetchReportDetail(
            reportId.toString(),
            headers,
          );
          if (detail != null) {
            _report = ReportCard.fromJson(detail);
            _cacheReport(prefs, detail);
            if (!mounted) return;
            setState(() {
              _isLoading = false;
              _errorMessage = null;
              _isFromCache = false;
            });
            return;
          }
        }
        _report = ReportCard.fromJson(firstReport);
        _cacheReport(prefs, firstReport);
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = null;
          _isFromCache = false;
        });
        return;
      } else if (data is Map<String, dynamic>) {
        _report = ReportCard.fromJson(data);
        _cacheReport(prefs, data);
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = null;
          _isFromCache = false;
        });
        return;
      }

      if (_loadCachedReport(prefs)) return;
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Data raport tidak tersedia.';
        _isLoading = false;
      });
    } else {
      if (_loadCachedReport(prefs)) return;
      if (!mounted) return;
      String message;
      if (isHtml) {
        message =
            'Server error (${response.statusCode}). Endpoint raport mungkin belum tersedia.';
      } else {
        try {
          final d = jsonDecode(body);
          message = d is Map
              ? (d['message'] as String? ?? 'Gagal memuat raport.')
              : 'Gagal memuat raport (${response.statusCode}).';
        } catch (_) {
          message = 'Gagal memuat raport (${response.statusCode}).';
        }
      }
      setState(() {
        _errorMessage = message;
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>?> _fetchReportDetail(
    String reportId,
    Map<String, String> headers,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse(
                '${ApiConfig.baseUrl}${ApiConfig.reports}/$reportId'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) return null;

      final body = response.body;
      if (body.trimLeft().startsWith('<')) return null;

      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) return null;

      final data = decoded['data'];
      if (data is! Map<String, dynamic>) return null;

      return data;
    } catch (_) {
      return null;
    }
  }

  void _cacheReport(SharedPreferences prefs, Map<String, dynamic> data) {
    prefs.setString('cached_report', jsonEncode(data));
  }

  /// Muat dari cache. Kembali true jika berhasil.
  bool _loadCachedReport(SharedPreferences prefs) {
    final cached = prefs.getString('cached_report');
    if (cached == null) return false;
    try {
      _report = ReportCard.fromJson(
          jsonDecode(cached) as Map<String, dynamic>);
      setState(() {
        _isLoading = false;
        _errorMessage = null;
        _isFromCache = true;
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            if (_isFromCache) _buildCacheBanner(),
            Expanded(
              child: _isLoading
                  ? _buildLoading()
                  : _errorMessage != null
                      ? _buildError()
                      : RefreshIndicator(
                          color: const Color(0xFF0EA473),
                          onRefresh: _fetchReport,
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                            children: [
                              if (_report.subjects.isEmpty)
                                _buildEmptyReport()
                              else ...[
                                _buildReportCard(),
                                const SizedBox(height: 12),
                                if (_report.achievement != null) _buildAchievementBanner(),
                                const SizedBox(height: 16),
                                ..._report.subjects.map(_buildSubjectCard),
                              ],
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF0EA473)),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_outlined, size: 48, color: Color(0xFF9CA3AF)),
          const SizedBox(height: 12),
          Text(_errorMessage!, style: const TextStyle(color: Color(0xFF6B7280))),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _fetchReport,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                gradient: _greenGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  // ── app bar ───────────────────────────────────────────────
  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back,
              color: Color(0xFF1F2937),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Rapot Online',
            style: TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCacheBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFFFFF3CD),
      child: const Row(
        children: [
          Icon(Icons.cloud_off, size: 16, color: Color(0xFF856404)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Data offline — terakhir dimuat saat online',
              style: TextStyle(color: Color(0xFF856404), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyReport() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: const [
            Icon(Icons.school_outlined, size: 56, color: Color(0xFFD1D5DB)),
            SizedBox(height: 12),
            Text(
              'Belum ada raport yang dipublikasikan.',
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // ── kartu rapot merah ─────────────────────────────────────
  Widget _buildReportCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: BoxDecoration(
        gradient: _cardGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE8215A).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // baris atas: label + ikon
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rapot Semester',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_report.semester} • TA ${_report.academicYear}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kelas ${_report.className}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.school_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 3 stat box
          Row(
            children: [
              _statBox(
                value: _report.average.toStringAsFixed(1),
                label: 'Rata-rata',
              ),
              const SizedBox(width: 10),
              _statBox(
                value: '${_report.rank}',
                label: 'Peringkat',
              ),
              const SizedBox(width: 10),
              _statBox(
                value: '${_report.totalSubjects}',
                label: 'Mata Pelajaran',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBox({required String value, required String label}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── banner prestasi kuning ────────────────────────────────
  Widget _buildAchievementBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFFEF3C7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events_outlined,
              color: Color(0xFFF59E0B),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Prestasi Luar Biasa!',
                  style: TextStyle(
                    color: Color(0xFF92400E),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _report.achievement!,
                  style: const TextStyle(
                    color: Color(0xFFB45309),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.star,
            color: Color(0xFFF59E0B),
            size: 22,
          ),
        ],
      ),
    );
  }

  // ── kartu mata pelajaran ──────────────────────────────────
  Widget _buildSubjectCard(SubjectGrade subject) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
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
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4E8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.menu_book_outlined,
                  color: Color(0xFFE8215A),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  subject.subjectName,
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                'KKM ${subject.kkm}',
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: subject.gradeBgColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    subject.letterGrade,
                    style: TextStyle(
                      color: subject.gradeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: subject.progress,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      subject.grade >= subject.kkm
                          ? const Color(0xFF0EA473)
                          : const Color(0xFFEF4444),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                subject.grade % 1 == 0
                    ? subject.grade.toInt().toString()
                    : subject.grade.toStringAsFixed(1),
                style: const TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
