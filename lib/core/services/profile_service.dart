import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';
import '../network/api_config.dart';

class ProfileService {
  final ApiClient _client;

  ProfileService({ApiClient? client}) : _client = client ?? ApiClient();

  static const _cacheKey = 'cached_photo_bytes';

  static Future<void> cachePhotoBytes(Uint8List bytes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, base64Encode(bytes));
  }

  static Future<Uint8List?> getCachedPhotoBytes() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_cacheKey);
    if (encoded == null || encoded.isEmpty) return null;
    try {
      return base64Decode(encoded);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearCachedPhoto() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }

  Future<bool> updateContact({
    required String fatherPhone,
    required String motherPhone,
    required String address,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return false;

      await _client.put(
        ApiConfig.profile,
        token: token,
        body: {
          'father_phone': fatherPhone,
          'mother_phone': motherPhone,
          'address': address,
        },
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Uint8List?> fetchPhotoBytes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return null;

      final bytes = await _client.getBytes(
        ApiConfig.profilePhoto,
        token: token,
      );
      return bytes;
    } catch (_) {
      return null;
    }
  }

  Future<String?> uploadPhoto({
    required List<int> bytes,
    required String fileName,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return null;

      final response = await _client.postMultipart(
        ApiConfig.profilePhoto,
        bytes: bytes,
        fieldName: 'photo',
        fileName: fileName,
        token: token,
      );

      final data = response['data'] as Map<String, dynamic>?;
      return data?['photo_url'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<bool> deletePhoto() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return false;

      await _client.delete(ApiConfig.profilePhoto, token: token);
      return true;
    } catch (_) {
      return false;
    }
  }

  void dispose() {
    _client.dispose();
  }
}
