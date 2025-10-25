// lib/screens/admin_home.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'setting_screen.dart'; // Import màn hình Cài đặt
import 'admin_manage_activities.dart';
// <-- CẦN IMPORT MÀN HÌNH MỚI NÀY
import 'attendance_activity_list_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Cài đặt', 
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingScreen()),
              );
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
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Chào mừng Admin!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // Nút Quản lý Hoạt động (không đổi)
              ElevatedButton.icon(
                icon: const Icon(Icons.list_alt),
                label: const Text('Quản lý Hoạt động'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AdminManageActivitiesScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // <-- NÚT MỚI: XEM DANH SÁCH ĐIỂM DANH -->
              ElevatedButton.icon(
                icon: const Icon(Icons.playlist_add_check), 
                label: const Text('Xem Danh sách Điểm danh'), 
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  // ĐIỀU HƯỚNG ĐẾN MÀN HÌNH MỚI
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