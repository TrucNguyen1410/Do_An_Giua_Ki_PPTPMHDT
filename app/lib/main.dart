// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers
import 'providers/theme_provider.dart';
import 'services/auth_service.dart';
import 'services/activity_service.dart'; // <-- ĐÃ THÊM

// Screens
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/admin_home.dart';
import 'screens/student_home.dart';
import 'screens/register_screen.dart';
import 'screens/admin_manage_activities.dart'; // <-- ĐÃ THÊM
import 'screens/setting_screen.dart'; // <-- ĐÃ THÊM

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ActivityService()), // <-- ĐÃ THÊM
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Quản lý Hoạt động',
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,

      // Điều hướng chính của ứng dụng
      home: Consumer<AuthService>(
        builder: (context, authService, _) {
          if (authService.isAuthLoading) {
            // Đang kiểm tra token (tự động đăng nhập)
            return SplashScreen();
          }

          if (authService.isAuthenticated) {
            // Đã đăng nhập
            if (authService.userRole == 'admin') {
              return AdminHomeScreen(); // Điều hướng đến trang Admin
            } else {
              return StudentHomeScreen(); // Điều hướng đến trang Student
            }
          }

          // Chưa đăng nhập
          return LoginScreen();
        },
      ),

      // Định nghĩa các route (đường dẫn) để tiện điều hướng
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/admin_home': (context) => AdminHomeScreen(),
        '/student_home': (context) => StudentHomeScreen(),
        '/admin_manage_activities': (context) => AdminManageActivitiesScreen(), // <-- ĐÃ THÊM
        '/settings': (context) => SettingScreen(), // <-- ĐÃ THÊM
      },
    );
  }
}