// lib/services/auth_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jwt_decode/jwt_decode.dart'; // Import gói giải mã JWT
import 'package:shared_preferences/shared_preferences.dart'; // Import gói lưu trữ local
import 'api_client.dart'; // Import ApiClient đã tạo

/// AuthService là một ChangeNotifier, nghĩa là nó có thể thông báo
/// cho các widget khác (như main.dart) khi dữ liệu của nó (như _token) thay đổi.
class AuthService extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  
  String? _token;
  String? _userRole;
  String? _userId;
  bool _isAuthLoading = true; // Biến cờ để hiển thị màn hình Splash

  // "Getters" để các widget bên ngoài có thể đọc dữ liệu an toàn
  bool get isAuthenticated => _token != null;
  String? get userRole => _userRole;
  String? get userId => _userId;
  bool get isAuthLoading => _isAuthLoading;

  // Hàm khởi tạo, được gọi khi AuthService được tạo trong main.dart
  AuthService() {
    // Ngay khi app mở, cố gắng tự động đăng nhập
    tryAutoLogin();
  }

  // Cố gắng tự động đăng nhập khi mở app
  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Nếu không tìm thấy token, nghĩa là chưa đăng nhập
    if (!prefs.containsKey('token')) {
      _isAuthLoading = false; // Tắt màn hình Splash
      notifyListeners(); // Thông báo cho main.dart để chuyển đến LoginScreen
      return;
    }

    final token = prefs.getString('token');
    
    // (Bạn có thể thêm logic kiểm tra token hết hạn ở đây nếu muốn)
    
    _token = token;
    _decodeToken(token!); // Giải mã token để lấy role và id

    _isAuthLoading = false; // Tắt màn hình Splash
    notifyListeners(); // Thông báo cho main.dart để chuyển đến HomeScreen
  }

  // Hàm private để giải mã token
  void _decodeToken(String token) {
    try {
      // Gói jwt_decode sẽ parse token
      Map<String, dynamic> payload = Jwt.parseJwt(token);
      
      // Quan trọng: Phải khớp với cấu trúc payload bạn tạo ở backend Node.js
      // { "user": { "id": "...", "role": "..." } }
      _userId = payload['user']['id'];
      _userRole = payload['user']['role'];

    } catch (e) {
      print('Lỗi giải mã token: $e');
      // Nếu token lỗi, coi như chưa đăng nhập
      _token = null;
      _userId = null;
      _userRole = null;
    }
  }

  // Hàm Đăng nhập
  Future<void> login(String email, String password) async {
    try {
      // Gọi API qua ApiClient
      final response = await _apiClient.post('auth/login', {
        'email': email,
        'password': password,
      });

      _token = response['token'];
      if (_token == null) {
        throw Exception('Không nhận được token từ server');
      }

      _decodeToken(_token!); // Lấy role và id

      // Lưu token vào bộ nhớ máy
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);

      notifyListeners(); // Thông báo cho main.dart biết đã đăng nhập thành công
    } catch (e) {
      // Ném lỗi ra để LoginScreen có thể bắt và hiển thị
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Hàm Đăng ký
  Future<void> register(String fullName, String email, String password) async {
    try {
      // Gọi API qua ApiClient
      final response = await _apiClient.post('auth/register', {
        'fullName': fullName,
        'email': email,
        'password': password,
      });

      _token = response['token'];
      if (_token == null) {
        throw Exception('Không nhận được token từ server');
      }

      _decodeToken(_token!); // Lấy role và id
      
      // Lưu token vào bộ nhớ máy
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);

      notifyListeners(); // Thông báo cho main.dart biết đã đăng ký thành công
    } catch (e) {
      // Ném lỗi ra để RegisterScreen có thể bắt và hiển thị
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Hàm Đăng xuất
  Future<void> logout() async {
    // Xóa dữ liệu local
    _token = null;
    _userId = null;
    _userRole = null;
    
    // Xóa token khỏi bộ nhớ máy
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    
    notifyListeners(); // Thông báo cho main.dart biết đã đăng xuất
  }
}