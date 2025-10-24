// lib/screens/student_home.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'setting_screen.dart'; // Dùng chung file setting

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ Sinh viên'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Điều hướng đến trang cài đặt
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => SettingScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Text('Chào mừng Sinh viên!', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Xem Hoạt động (Chưa làm)'),
              onPressed: () {
                // TODO: Hiển thị danh sách hoạt động
              },
            ),
             ElevatedButton(
              child: const Text('Quét QR điểm danh'),
              onPressed: () {
                // Điều hướng đến màn hình quét QR
                 Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => QrScannerScreen()), // Giả sử bạn đã có file này
                );
              },
            ),
          ],
        ),
      ),
      // (Bạn có thể thêm BottomNavigationBar ở đây nếu muốn)
    );
  }
}