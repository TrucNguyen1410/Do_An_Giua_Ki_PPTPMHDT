import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class ApiClient {
  Future<Map<String, String>> _headers() async {
    final sp = await SharedPreferences.getInstance();
    final t = sp.getString('token');
    return {
      'Content-Type': 'application/json',
      if (t != null) 'Authorization': 'Bearer $t',
    };
  }

  Uri _u(String path) => Uri.parse('$kApiBase$path');

  Future<dynamic> get(String path) async {
    final res = await http.get(_u(path), headers: await _headers());
    return _handle(res);
    }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final res = await http.post(_u(path), headers: await _headers(), body: jsonEncode(body));
    return _handle(res);
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final res = await http.put(_u(path), headers: await _headers(), body: jsonEncode(body));
    return _handle(res);
  }

  Future<dynamic> delete(String path) async {
    final res = await http.delete(_u(path), headers: await _headers());
    return _handle(res);
  }

  dynamic _handle(http.Response r) {
    final data = r.body.isEmpty ? null : jsonDecode(r.body);
    if (r.statusCode >= 200 && r.statusCode < 300) return data;
    throw Exception(data?['message'] ?? 'Lỗi máy chủ (${r.statusCode})');
  }
}
