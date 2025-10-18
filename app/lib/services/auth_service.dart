import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  final _api = ApiClient();

  Future<AppUser> login(String email, String password) async {
    final data = await _api.post('/auth/login', {'email': email, 'password': password});
    final sp = await SharedPreferences.getInstance();
    await sp.setString('token', data['token']);
    await sp.setString('role', data['user']['role']);
    await sp.setString('name', data['user']['name']);
    await sp.setString('userId', data['user']['id']);
    return AppUser.fromJson(data['user']);
    }

  Future<AppUser> register({required String name, required String studentId, required String email, required String password}) async {
    final data = await _api.post('/auth/register', { 'name': name, 'studentId': studentId, 'email': email, 'password': password });
    final sp = await SharedPreferences.getInstance();
    await sp.setString('token', data['token']);
    await sp.setString('role', data['user']['role']);
    await sp.setString('name', data['user']['name']);
    await sp.setString('userId', data['user']['id']);
    return AppUser.fromJson(data['user']);
  }

  Future<void> logout() async {
    final sp = await SharedPreferences.getInstance();
    await sp.clear();
  }

  Future<String?> role() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString('role');
  }
}
