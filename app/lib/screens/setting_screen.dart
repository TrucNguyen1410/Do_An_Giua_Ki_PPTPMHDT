// lib/screens/setting_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/auth_service.dart';
import 'profile_screen.dart'; // <-- Dòng import cho trang Thông tin cá nhân

class SettingScreen extends StatelessWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cài đặt'),
      ),
      body: ListView(
        children: [
          // Mục: Thông tin cá nhân
          ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('Thông tin cá nhân'),
            onTap: () {
              // === ĐÃ CẬP NHẬT ===
              // Điều hướng đến trang Profile
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
          ),

          // Mục: Chuyển đổi Theme
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return SwitchListTile(
                secondary: Icon(themeProvider.themeMode == ThemeMode.dark
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined),
                title: Text('Chế độ tối'),
                value: themeProvider.themeMode == ThemeMode.dark,
                onChanged: (bool value) {
                  // Gọi hàm để thay đổi theme
                  themeProvider.toggleTheme(value);
                },
              );
            },
          ),
          
          Divider(), // Dòng kẻ ngang

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
                  title: Text('Xác nhận đăng xuất'),
                  content: Text('Bạn có chắc chắn muốn đăng xuất?'),
                  actions: [
                    // Nút Hủy
                    TextButton(
                      child: Text('Hủy'),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                    ),
                    // Nút Đăng xuất
                    TextButton(
                      child: Text('Đăng xuất'),
                      onPressed: () {
                        // 1. Tắt dialog
                        Navigator.of(ctx).pop(); 
                        
                        // 2. Gọi hàm logout từ AuthService
                        Provider.of<AuthService>(context, listen: false).logout();
                        
                        // 3. Quay về màn hình đăng nhập
                        // (Consumer trong main.dart sẽ tự xử lý việc này,
                        // nhưng chúng ta pop về root (trang đầu tiên) cho chắc)
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