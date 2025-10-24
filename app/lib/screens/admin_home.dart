// lib/screens/admin_home.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'setting_screen.dart'; // Import màn hình Cài đặt
import 'admin_manage_activities.dart'; // <-- ĐÃ THÊM

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
            onPressed: () {
              // Điều hướng đến trang cài đặt
              Navigator.of(context).pushNamed('/settings');
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
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.list_alt),
                label: const Text('Quản lý Hoạt động'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  // <-- ĐÃ CẬP NHẬT
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AdminManageActivitiesScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Quét mã SV (Chưa làm)'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  // TODO: Navigator.push(...đến admin_scanner_screen.dart)
                  // Màn hình này dùng để quét mã của SV, khác với màn hình tạo QR
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}