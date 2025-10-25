// lib/screens/student_home.dart
import 'package:flutter/material.dart';
import 'activity_list_screen.dart'; // Màn hình mới
import 'history_screen.dart'; // Màn hình mới
import 'qr_scanner_screen.dart'; // Màn hình này của bạn
import 'setting_screen.dart'; // Màn hình này của bạn
import 'package:provider/provider.dart'; // Để dùng logout
import '../services/auth_service.dart'; // Để dùng logout

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin user từ provider
    final user = Provider.of<AuthService>(context, listen: false).currentUser;

    // Style cho các nút
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFF), // Màu nền nhạt
      appBar: AppBar(
        title: const Text('Trang chủ Sinh viên'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Thêm nút logout
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
                // Chào đúng tên sinh viên
                'Chào mừng, ${user?.fullName ?? 'Sinh viên'}!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 80),

              // Nút Xem Hoạt động
              ElevatedButton.icon(
                icon: Icon(Icons.list_alt, color: Colors.purple.shade300),
                label: const Text('Xem Hoạt động'),
                style: buttonStyle,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ActivityListScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Nút Xem Lịch sử
              ElevatedButton.icon(
                icon: Icon(Icons.history, color: Colors.blue.shade300),
                label: const Text('Xem Lịch sử đăng ký'),
                style: buttonStyle,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HistoryScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
              
              // Nút Quét QR
              ElevatedButton.icon(
                icon: Icon(Icons.qr_code_scanner, color: Colors.green.shade400),
                label: const Text('Quét QR điểm danh'),
                style: buttonStyle,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const QrScannerScreen()),
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