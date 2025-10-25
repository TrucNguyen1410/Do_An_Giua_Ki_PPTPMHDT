// lib/services/auth_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';
import '../models/user.dart'; // <-- THÊM IMPORT MODEL USER

class AuthService extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  
  String? _token;
  User? _currentUser; // <-- THÊM BIẾN LƯU THÔNG TIN USER
  bool _isAuthLoading = true;

  bool get isAuthenticated => _token != null;
  User? get currentUser => _currentUser; // <-- Getter cho UI lấy data
  String? get userRole => _currentUser?.role; // Lấy role từ user
  String? get userId => _currentUser?.id; // Lấy id từ user
  bool get isAuthLoading => _isAuthLoading;

  AuthService() {
    tryAutoLogin();
  }

  // Hàm mới để gọi API /api/auth/me
  Future<void> _getUserProfile() async {
    try {
      // ApiClient sẽ tự động đính kèm token
      final responseData = await _apiClient.get('auth/me'); 
      _currentUser = User.fromJson(responseData); // Lưu user object
    } catch (e) {
      print('Không thể tải thông tin user: $e');
      // Nếu lỗi (vd: token hết hạn), thì logout
      await logout(); 
    }
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('token')) {
      _isAuthLoading = false;
      notifyListeners();
      return;
    }

    _token = prefs.getString('token');
    if (_token == null) {
       _isAuthLoading = false;
      notifyListeners();
      return;
    }

    // Tải thông tin user
    await _getUserProfile();

    _isAuthLoading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await _apiClient.post('auth/login', {
        'email': email,
        'password': password,
      });

      _token = response['token'];
      if (_token == null) {
        throw Exception('Không nhận được token từ server');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);

      // Tải thông tin user ngay sau khi đăng nhập
      await _getUserProfile(); 

      notifyListeners();
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> register(String fullName, String email, String password) async {
    try {
      final response = await _apiClient.post('auth/register', {
        'fullName': fullName,
        'email': email,
        'password': password,
      });

      _token = response['token'];
      if (_token == null) {
        throw Exception('Không nhận được token từ server');
      }
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);

      // Tải thông tin user ngay sau khi đăng ký
      await _getUserProfile();

      notifyListeners();
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> logout() async {
    _token = null;
    _currentUser = null; // <-- XÓA USER KHI LOGOUT
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    
    notifyListeners();
  }
}