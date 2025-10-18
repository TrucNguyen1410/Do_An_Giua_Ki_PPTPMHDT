import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class ApiClient {
  Future<String?> _getToken() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString('token');
  }

  Future<Map<String,String>> _headers() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String path) async {
    final res = await http.get(Uri.parse('$kApiBase$path'), headers: await _headers());
    return _handle(res);
  }

  Future<dynamic> post(String path, Map body) async {
    final res = await http.post(Uri.parse('$kApiBase$path'), headers: await _headers(), body: jsonEncode(body));
    return _handle(res);
  }

  Future<dynamic> put(String path, Map body) async {
    final res = await http.put(Uri.parse('$kApiBase$path'), headers: await _headers(), body: jsonEncode(body));
    return _handle(res);
  }

  dynamic _handle(http.Response res){
    if (kDebugMode) print('${res.request?.method} ${res.request?.url} -> ${res.statusCode}');
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return null;
      return jsonDecode(utf8.decode(res.bodyBytes));
    }
    throw Exception(jsonDecode(utf8.decode(res.bodyBytes))['message'] ?? 'API error');
  }

  Future<void> delete(String s) async {}
}
