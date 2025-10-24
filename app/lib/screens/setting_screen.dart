// lib/screens/setting_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/auth_service.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
      ),
      body: ListView(
        children: [
          // Mục: Thông tin cá nhân (Chưa làm)
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Thông tin cá nhân'),
            onTap: () {
              // TODO: Điều hướng đến trang Profile
              // Navigator.of(context).push(
              //   MaterialPageRoute(builder: (context) => ProfileScreen()),
              // );
            },
          ),

          // Mục: Chuyển đổi Theme
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return SwitchListTile(
                secondary: Icon(themeProvider.themeMode == ThemeMode.dark
                    ? Icons.dark_mode
                    : Icons.light_mode),
                title: const Text('Chế độ tối'),
                value: themeProvider.themeMode == ThemeMode.dark,
                onChanged: (bool value) {
                  // Gọi hàm để thay đổi theme
                  themeProvider.toggleTheme(value);
                },
              );
            },
          ),
          
          const Divider(),

          // Mục: Đăng xuất
          ListTile(
            leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
            title: Text(
              'Đăng xuất',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: () {
              // Hiển thị dialog xác nhận
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Xác nhận đăng xuất'),
                  content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
                  actions: [
                    TextButton(
                      child: const Text('Hủy'),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                    ),
                    TextButton(
                      child: const Text('Đăng xuất'),
                      onPressed: () {
                        // 1. Tắt dialog
                        Navigator.of(ctx).pop(); 
                        
                        // 2. Gọi hàm logout
                        Provider.of<AuthService>(context, listen: false).logout();
                        
                        // 3. Quay về màn hình đăng nhập
                        // (Consumer trong main.dart sẽ tự xử lý việc này,
                        // nhưng chúng ta pop về root cho chắc)
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Giả lập file qr_scanner_screen.dart (vì StudentHome cần)
// Bạn hãy dùng code của bạn, đây chỉ là file giữ chỗ
class QrScannerScreen extends StatelessWidget {
  const QrScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quét QR')),
      body: const Center(child: Text('Giao diện quét QR của bạn ở đây')),
    );
  }
}