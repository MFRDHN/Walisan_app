import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> _headers({String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      if (response.statusCode == 200 || response.statusCode == 201) {
        throw ApiException(
          message: 'Gagal memproses respons server. Coba lagi nanti.',
          statusCode: response.statusCode,
        );
      }
      throw ApiException(
        message: 'Server error (${response.statusCode}). Silakan coba lagi.',
        statusCode: response.statusCode,
      );
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');

    try {
      final response = await _client.post(
        url,
        headers: _headers(token: token),
        body: body != null ? jsonEncode(body) : null,
      );

      final decoded = _decodeResponse(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return decoded;
      } else {
        throw ApiException(
          message: decoded['message'] as String? ?? 'Terjadi kesalahan',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException {
      throw ApiException(message: 'Periksa koneksi internet Anda.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    String? token,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');

    try {
      final response = await _client.get(
        url,
        headers: _headers(token: token),
      );

      final decoded = _decodeResponse(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return decoded;
      } else {
        throw ApiException(
          message: decoded['message'] as String? ?? 'Terjadi kesalahan',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException {
      throw ApiException(message: 'Periksa koneksi internet Anda.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');

    try {
      final response = await _client.put(
        url,
        headers: _headers(token: token),
        body: body != null ? jsonEncode(body) : null,
      );

      final decoded = _decodeResponse(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return decoded;
      } else {
        throw ApiException(
          message: decoded['message'] as String? ?? 'Terjadi kesalahan',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException {
      throw ApiException(message: 'Periksa koneksi internet Anda.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> postMultipart(
    String endpoint, {
    required List<int> bytes,
    required String fieldName,
    required String fileName,
    String? token,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');

    try {
      final request = http.MultipartRequest('POST', url);
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';
      request.files.add(http.MultipartFile.fromBytes(
        fieldName,
        bytes,
        filename: fileName,
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final decoded = _decodeResponse(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return decoded;
      } else {
        throw ApiException(
          message: decoded['message'] as String? ?? 'Terjadi kesalahan',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException {
      throw ApiException(message: 'Periksa koneksi internet Anda.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  Future<Uint8List> getBytes(
    String endpoint, {
    String? token,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');

    try {
      final response = await _client.get(
        url,
        headers: _headers(token: token),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.bodyBytes;
      } else {
        throw ApiException(
          message: 'Gagal mengambil data',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException {
      throw ApiException(message: 'Periksa koneksi internet Anda.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    String? token,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');

    try {
      final response = await _client.delete(
        url,
        headers: _headers(token: token),
      );

      final decoded = _decodeResponse(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return decoded;
      } else {
        throw ApiException(
          message: decoded['message'] as String? ?? 'Terjadi kesalahan',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException {
      throw ApiException(message: 'Periksa koneksi internet Anda.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  void dispose() {
    _client.close();
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  @override
  String toString() => message;
}
