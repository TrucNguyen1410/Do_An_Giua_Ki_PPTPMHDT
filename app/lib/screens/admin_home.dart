// lib/screens/admin_home.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'setting_screen.dart';
import 'admin_manage_activities.dart';
import 'attendance_activity_list_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sử dụng TextStyle từ Theme
    final headlineStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600);
    
    // Style chuẩn cho các nút chính (sẽ lấy màu từ ThemeProvider)
    final buttonStyle = ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Cài đặt',
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () {
              Provider.of<AuthService>(context, listen: false).logout();
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0), // Tăng padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Chào mừng Admin!',
                style: headlineStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60), // Khoảng cách lớn hơn

              // Nút 1: Quản lý Hoạt động
              ElevatedButton.icon(
                icon: const Icon(Icons.list_alt, size: 28),
                label: const Text('Quản lý Hoạt động', style: TextStyle(fontSize: 18)),
                style: buttonStyle,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AdminManageActivitiesScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24), // Khoảng cách giữa các nút

              // Nút 2: Xem Danh sách Điểm danh
              ElevatedButton.icon(
                icon: const Icon(Icons.playlist_add_check, size: 28),
                label: const Text('Xem Danh sách Điểm danh', style: TextStyle(fontSize: 18)),
                style: buttonStyle,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AttendanceActivityListScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
