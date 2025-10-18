import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const CNITApp());
}

class CNITApp extends StatefulWidget {
  const CNITApp({super.key});

  @override
  State<CNITApp> createState() => _CNITAppState();
}

class _CNITAppState extends State<CNITApp> {
  // Chế độ hiển thị: sáng (light) hoặc tối (dark)
  ThemeMode _themeMode = ThemeMode.light;

  // Hàm đổi chế độ sáng/tối — được gọi từ các màn hình khác
  void toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CNIT Activities',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
      ),
      themeMode: _themeMode, // ✅ Áp dụng chế độ sáng/tối toàn app
      home: SplashScreen(onThemeToggle: toggleTheme), // ✅ Truyền callback xuống
    );
  }
}
