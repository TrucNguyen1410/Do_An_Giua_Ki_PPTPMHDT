// lib/services/api_client.dart

// === CÁC DÒNG IMPORT BỊ THIẾU NẰM Ở ĐÂY ===
import 'dart:convert'; // Cho 'jsonDecode'
import 'dart:io'; // Cho 'SocketException'
import 'package:http/http.dart' as http; // Gói http
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';
// ======================================

class ApiClient {
  final String _baseUrl = Config.baseUrl;

  // Lấy token từ SharedPreferences
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    if (token != null) {
      headers['x-auth-token'] = token; // Gửi token trong header
    }
    return headers;
  }

  // Phương thức GET
  Future<dynamic> get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: headers,
      );
      return _processResponse(response);
    } on SocketException {
      // Lỗi không có mạng
      throw Exception('Không có kết nối mạng. Vui lòng thử lại.');
    } catch (e) {
      // Ném lỗi đã được xử lý từ _processResponse
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Phương thức POST
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      );
      return _processResponse(response);
    } on SocketException {
      throw Exception('Không có kết nối mạng. Vui lòng thử lại.');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Phương thức PUT
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      );
      return _processResponse(response);
    } on SocketException {
      throw Exception('Không có kết nối mạng. Vui lòng thử lại.');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Phương thức DELETE
  Future<dynamic> delete(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: headers,
      );
      return _processResponse(response);
    } on SocketException {
      throw Exception('Không có kết nối mạng. Vui lòng thử lại.');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Hàm xử lý lỗi quan trọng (đã sửa)
  dynamic _processResponse(http.Response response) {
    dynamic body;
    try {
      // Thử giải mã JSON
      body = jsonDecode(response.body);
    } catch (e) {
      // Nếu server trả về HTML (lỗi <!DOCTYPE html>)
      throw Exception('Server trả về lỗi không mong muốn (HTML).');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Thành công (200, 201, ...)
      return body;
    } else {
      // Thất bại (400, 401, 500, ...)
      String errorMessage;

      // Đọc lỗi từ JSON mà backend trả về
      if (body != null && body['msg'] != null) {
        // { "msg": "..." }
        errorMessage = body['msg'];
      } else if (body != null && body['errors'] != null && body['errors'] is List && body['errors'].isNotEmpty) {
        // { "errors": [{ "msg": "..." }] }
        errorMessage = body['errors'][0]['msg'];
      } else {
        // Nếu server trả về lỗi mà không có 'msg' hay 'errors'
        // Chúng ta sẽ hiển thị toàn bộ nội dung body
        errorMessage = response.body; 
      }
      
      // Ném lỗi thật sự
      throw Exception(errorMessage);
    }
  }
}