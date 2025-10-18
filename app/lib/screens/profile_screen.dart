import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final String name;
  final String studentId;
  final String email;

  const ProfileScreen({
    super.key,
    required this.name,
    required this.studentId,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thông tin cá nhân")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/avatar.png'),
              ),
            ),
            const SizedBox(height: 20),
            Text("👤 Họ tên: $name", style: const TextStyle(fontSize: 18)),
            Text("🎓 MSSV: $studentId", style: const TextStyle(fontSize: 18)),
            Text("📧 Email: $email", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.logout),
                label: const Text("Đăng xuất"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
