import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'admin_scanner_screen.dart';
import 'admin_manage_activities.dart'; // ✅ Thêm màn hình quản lý hoạt động

class AdminHome extends StatefulWidget {
  final void Function(bool)? onThemeToggle;
  const AdminHome({super.key, this.onThemeToggle});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  bool isDarkMode = false;

  // Mở bảng cài đặt
  void _openSettings() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildSettingsSheet(),
    );
  }

  // Giao diện bảng cài đặt
  Widget _buildSettingsSheet() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("⚙️ Cài đặt",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Divider(),
          SwitchListTile(
            title: const Text("Chế độ tối (Dark Mode)"),
            value: isDarkMode,
            onChanged: (val) {
              setState(() => isDarkMode = val);
              widget.onThemeToggle?.call(val);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Thông tin cá nhân"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(
                    name: "Nguyen Le Anh Truc",
                    studentId: "1150080078",
                    email: "1150080078@sv.hcmnre.edu.vn",
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Giao diện chính
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản trị hoạt động'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              }
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          // ✅ Quản lý hoạt động
          ListTile(
            leading: const Icon(Icons.event_note),
            title: const Text('Quản lý hoạt động'),
            subtitle: const Text('Thêm, sửa, xóa hoạt động cho sinh viên'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminManageActivitiesScreen()),
              );
            },
          ),

          // ✅ Quét QR điểm danh
          ListTile(
            leading: const Icon(Icons.qr_code_scanner),
            title: const Text('Quét QR điểm danh'),
            subtitle: const Text('Quét mã QR của sinh viên để điểm danh'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminScannerScreen()),
              );
            },
          ),
        ],
      ),

      // ⚙️ Nút cài đặt góc phải dưới
      floatingActionButton: FloatingActionButton(
        onPressed: _openSettings,
        child: const Icon(Icons.settings),
      ),
    );
  }
}
