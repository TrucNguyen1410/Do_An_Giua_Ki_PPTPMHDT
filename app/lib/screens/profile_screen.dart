// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user.dart'; // Import model User

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Dùng Consumer để tự động cập nhật khi data thay đổi
    return Scaffold(
      appBar: AppBar(
        title: Text('Thông tin cá nhân'),
      ),
      body: Consumer<AuthService>(
        builder: (context, authService, child) {
          
          // Lấy user từ service
          final User? user = authService.currentUser;

          // Hiển thị loading nếu user chưa kịp tải
          if (user == null) {
            return Center(child: CircularProgressIndicator());
          }

          // Hiển thị thông tin
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Thông tin tài khoản',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(height: 24),
                ListTile(
                  leading: Icon(Icons.person_outline),
                  title: Text('Họ và tên'),
                  subtitle: Text(user.fullName), // <-- DỮ LIỆU THẬT
                ),
                ListTile(
                  leading: Icon(Icons.email_outlined),
                  title: Text('Email'),
                  subtitle: Text(user.email), // <-- DỮ LIỆU THẬT
                ),
                ListTile(
                  leading: Icon(Icons.badge_outlined),
                  title: Text('Vai trò'),
                  subtitle: Text(user.role), // <-- DỮ LIỆU THẬT
                ),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Thêm logic đổi mật khẩu
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Chức năng này chưa được code!')),
                    );
                  },
                  child: Text('Đổi mật khẩu'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}