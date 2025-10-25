// lib/services/api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

class ApiClient {
  final String _baseUrl = Config.baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    if (token != null) {
      return {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      };
    }
    return {
      'Content-Type': 'application/json; charset=UTF-8',
    };
  }

  // Hàm GET
  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    final headers = await _getHeaders();
    try {
      final response = await http.get(url, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // Hàm POST
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    final headers = await _getHeaders();
    final body = json.encode(data);
    try {
      final response = await http.post(url, headers: headers, body: body);
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // **HÀM MỚI CHO ADMIN**
  // Hàm PUT (để update)
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    final headers = await _getHeaders();
    final body = json.encode(data);
    try {
      final response = await http.put(url, headers: headers, body: body);
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // **HÀM MỚI CHO ADMIN**
  // Hàm DELETE
  Future<dynamic> delete(String endpoint) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    final headers = await _getHeaders();
    try {
      final response = await http.delete(url, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // Xử lý response chung
  dynamic _handleResponse(http.Response response) {
    // Sửa lỗi: Kiểm tra body rỗng trước khi decode
    if (response.body.isEmpty) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return null; // Thành công nhưng không có body (ví dụ: DELETE)
      } else {
        throw Exception('Lỗi máy chủ (code: ${response.statusCode})');
      }
    }
    
    final responseData = json.decode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseData;
    } else {
      throw Exception(responseData['message'] ?? 'Lỗi không xác định');
    }
  }
}