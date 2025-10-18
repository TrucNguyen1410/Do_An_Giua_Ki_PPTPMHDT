import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'student_home.dart';
import 'admin_home.dart';

class SplashScreen extends StatefulWidget {
  final void Function(bool)? onThemeToggle; // ✅ Nhận callback để đổi theme toàn app
  const SplashScreen({super.key, this.onThemeToggle});

  @override
  State<SplashScreen> createState() => _SplashState();
}

class _SplashState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<void> _decide() async {
    final sp = await SharedPreferences.getInstance();
    final token = sp.getString('token');
    final role = sp.getString('role');

    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    if (token != null && role == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AdminHome(onThemeToggle: widget.onThemeToggle),
        ),
      );
    } else if (token != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => StudentHome(onThemeToggle: widget.onThemeToggle),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LoginScreen(onThemeToggle: widget.onThemeToggle),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
