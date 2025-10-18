import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'student_home.dart';
import 'admin_home.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final void Function(bool)? onThemeToggle; // Nhận callback đổi theme từ main.dart
  const LoginScreen({super.key, this.onThemeToggle});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;
  final _auth = AuthService();

  void _submit() async {
    setState(() => _loading = true);
    try {
      final user = await _auth.login(_email.text.trim(), _pass.text.trim());
      if (user.role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AdminHome(onThemeToggle: widget.onThemeToggle),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => StudentHome(onThemeToggle: widget.onThemeToggle),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _email,
              decoration: const InputDecoration(
                labelText: 'Email @hcmunre.edu.vn',
              ),
            ),
            TextField(
              controller: _pass,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: Text(_loading ? 'Đang xử lý...' : 'Đăng nhập'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RegisterScreen(),
                  ),
                );
              },
              child: const Text('Chưa có tài khoản? Đăng ký'),
            ),
          ],
        ),
      ),
    );
  }
}
