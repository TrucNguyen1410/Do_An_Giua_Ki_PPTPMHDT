import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';
import '../models/user.dart';

class AuthService {
  final _api = ApiClient();

  Future<Map<String, dynamic>> _saveTokenUser(Map<String, dynamic> data) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('token', data['token']);
    final user = Map<String, dynamic>.from(data['user']);
    await sp.setString('role', user['role'] ?? 'student');
    await sp.setString('me', jsonEncode(user));
    return user;
  }

  Future<AppUser> login(String email, String password) async {
    final data = await _api.post('/auth/login', {'email': email, 'password': password});
    final u = await _saveTokenUser(data);
    return AppUser.fromJson(u);
  }

  Future<AppUser> register({required String name, required String studentId, required String email, required String password}) async {
    final data = await _api.post('/auth/register', {
      'name': name, 'studentId': studentId, 'email': email, 'password': password
    });
    final u = await _saveTokenUser(data);
    return AppUser.fromJson(u);
  }

  Future<void> logout() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove('token'); await sp.remove('role'); await sp.remove('me');
  }

  Future<Map<String, dynamic>> getProfile() async => await _api.get('/auth/me');
  Future<String> getMyQrData() async => (await _api.get('/auth/me/qr'))['qrData'] as String;

  Future<List<Map<String,dynamic>>> myRegistrations() async {
    final data = await _api.get('/activities/me/registrations');
    return (data as List).map((e)=> Map<String,dynamic>.from(e)).toList();
  }
}
